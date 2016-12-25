##########################################################
# 98_Skype.pm
# -----------
# Implements a skype bot based on Microsoft Bot Framework 
# Author andreas@schmidt.name
##########################################################

package main;
use LWP::UserAgent;
use HTTP::Request::Common qw(POST);
use JSON;
use MIME::Base64;
use strict;
use vars qw(%data);

sub
Skype_Initialize($)
{
  my ($hash) = @_;

  $hash->{DefFn}   = "Skype_Define";
  $hash->{SetFn}   = "Skype_Set";
}

#####################################
sub
Skype_Define($$)
{
  my ($hash, $def) = @_;
  my @args = split("[ \t]+", $def);

  my $name = shift @args;
  my $devtype = shift @args;
 
  $hash->{appid} = shift @args;
  $hash->{appsecret} = shift @args;
  $hash->{user} = shift @args;
  $hash->{serviceurl} = 'https://skype.botframework.com';
 
  $hash->{STATE} = 'Initialized';
	 
  return undef; 
}

#####################################
sub
Skype_Set($@)
{
  my ($hash, $name, $cmd, @args) = @_;
	my %sets = ('message' => 1, 'image' => 2, 'imageLink' => 3, 'incoming' => 4, 'incomingFull' => 5);
	
	return "Unknown argument ". $cmd . ", choose one of " . join(" ", sort keys %sets) unless defined($sets{$cmd});
	
	return Skype_Incoming($hash,@args) if ($cmd eq 'incoming');
	return Skype_IncomingFull($hash,@args) if ($cmd eq 'incomingFull');

	my $a = shift @args;
	my $user = $hash->{user};

	if ($a =~ /^@/)
	{
		$user = substr($a,1);
		$user = '29:' . $user unless $user =~ /^[0-9][0-9]?\:/;
		$a = '';
	}
	
	$a .= join(" ", @args);	
	$a =~ s/\<br \/\>/\n/g;
	
	$a = eval($a) if ($a =~ /^{/);

	return Skype_Send_Message($hash, $user, $a) if ($cmd eq 'message');
	return Skype_Send_Image($hash, $user, $a) if ($cmd eq 'image');
	return Skype_Send_ImageLink($hash, $user, $a) if ($cmd eq 'imageLink');
}

#####################################
sub
Skype_Send_Message
{
	my ($hash, $user, $msg) = @_; 	
	my $content = qq ( { "type" : "message", "text" : "$msg"} } );
	Skype_sendRequest($hash,$user,'/v3/conversations/$user/activities',$content);
}

sub
Skype_Send_Image
{
	my ($hash, $user, $file) = @_; 	

	eval {
		my $image;
		{
			local $/;
			open my $fh, '<', $file or die "Error opening file $file";
			$image = <$fh>;	
		}
		
		my $imagebase64 = encode_base64($image);
		
		my $content = qq ({ "contentUrl": "$imagebase64", "type" : "message/image"	});
			
		Skype_sendRequest($hash,$user,'/v3/conversations/$user/attachments',$content);
	} or do {
		my $e = $@;
		Log3 $hash->{NAME}, 2, "Skype: Something went wrong sending image: $e\n";
		return 0;
	};
}

sub
Skype_Send_ImageLink
{
	my ($hash, $user, $msg) = @_; 	
	
	my $content = qq {
		{
			"type":"message",
			"summary":"Eingangstür",
			"attachments":[
				{	
					"contentType":"application/vnd.microsoft.card.hero",
					"content":{
							"title":"Kamera",
							"images":[ { "image":"$msg"	} ]
					}
				}
			]
		}
    };
	Skype_sendRequest($hash,$user,'/v3/conversations/$user/activities',$content);
}

sub 
Skype_sendRequest
{
	my ($hash, $user, $urlpath, $content) = @_;
	
	eval {
		$user = uri_escape($user);
		$urlpath =~ s/\$user/$user/g;

		my $bearer = Skype_getToken($hash);
			
		Log3 $hash->{NAME}, 4, "Bearer: ". $bearer;
	
		my $ua = LWP::UserAgent->new;
		$ua->timeout(15);
		push @{ $ua->requests_redirectable }, 'POST';
			
		my $req = POST "$hash->{serviceurl}$urlpath", Content => $content;
		$req->header('Authorization' => "Bearer $bearer");
		$req->header('content-type' => 'application/json');
		
		Log3 $hash->{NAME}, 4, "Skype message request: " . $req->as_string();
			
		my $resp = $ua->request($req);
		  
		if ($resp->is_success) {
			Log3 $hash->{NAME}, 4, "Skype: Success in sending Skype message: ". $resp->content;
			return 1;
		}
		else {
			Log3 $hash->{NAME}, 2, "Skype: Error sending Skype message: ". $resp->status_line . $resp->as_string();
			return 0;
		}
	} or do {
		my $e = $@;
		Log3 $hash->{NAME}, 2, "Skype: Something went wrong: $e\n";
		return 0;
	};
}

sub
Skype_Incoming
{
	my $hash = shift;
	my $serviceUrl = shift;
	my $user = shift;
	my $msg = join(" ", @_);	
	$msg =~ s/^Edited previous message: (.*)<.*>$/$1/g;
	
	readingsBeginUpdate($hash);
	readingsBulkUpdate($hash,'incoming-message',$msg);
	readingsBulkUpdate($hash,'incoming-message-from','@' . $user);
	readingsBulkUpdate($hash,'incoming-message-service',$serviceUrl);
	readingsEndUpdate($hash, 1);
}

sub
Skype_IncomingFull
{
	my $hash = shift;
	my $msg = join(" ", @_);	

	readingsBeginUpdate($hash);
	readingsBulkUpdate($hash,'incomingFull',$msg);
	readingsEndUpdate($hash, 1);
}

sub 
Skype_getToken
{
	my $hash = shift;
	
	if (defined($hash->{access_token_expires}))
	{
		return $hash->{access_token} if (time() < $hash->{access_token_expires});
	}
	
	my $ua = LWP::UserAgent->new;
	$ua->timeout(15);

	my $client_id = $hash->{appid};
	my $client_secret = $hash->{appsecret};
	Log3 $hash->{NAME}, 2, $client_id . "|" . $client_secret;

	my $req = POST 'https://login.microsoftonline.com/common/oauth2/v2.0/token' , [ client_id => $client_id, client_secret => $client_secret, grant_type => 'client_credentials', scope => 'https://graph.microsoft.com/.default' ];
	$req->header('content-type' => 'application/x-www-form-urlencoded');	 
	Log3 $hash->{NAME}, 4, "Skype OAUTH request: " . $req->as_string();
	
	my $resp = $ua->request($req);
	
	if ($resp->is_success) {
		my $message = $resp->content();
		Log3 $hash->{NAME}, 4, "Received reply: $message\n";
		my $j = decode_json($message);
		$hash->{access_token_expires} = $j->{'expires_in'} + time();
		$hash->{access_token} = $j->{access_token};
		return $hash->{access_token};
	}
	else {
		Log3 $hash->{NAME}, 2, "HTTP POST error code: " . $resp->code . "\n";
		Log3 $hash->{NAME}, 2, "HTTP POST error " . $resp->code . $resp->message . "\n" . $resp->as_string();
	}
}

1;