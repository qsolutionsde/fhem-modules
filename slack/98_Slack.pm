###############################################

package main;
use LWP::UserAgent;
use HTTP::Request::Common qw(POST);
use LWP::UserAgent;
use JSON;

sub
Slack_Initialize($)
{
  my ($hash) = @_;

  $hash->{DefFn}   = "Slack_Define";
  $hash->{SetFn}   = "Slack_Set";
}

#####################################
sub
Slack_Define($$)
{
  my ($hash, $def) = @_;
  my @args = split("[ \t]+", $def);

  my $name = shift @args;
  my $devtype = shift @args;
 
  $hash->{token} = shift @args;
  $hash->{user} = shift @args;
  $hash->{channel} = shift @args;
 
  Log3 $hash->{NAME},3, "['token' => '$hash->{token}', 'username' => '$hash->{user}', 'channel' => '$hash->{channel}']";
 
  $hash->{STATE} = 'Initialized';
  return undef; 
}

#####################################
sub
Slack_Set($@)
{
  my ($hash, $name, $cmd, @args) = @_;
	my %sets = ('message' => 1);
	if(!defined($sets{$cmd})) {
		return "Unknown argument ". $cmd . ", choose one of " . join(" ", sort keys %sets);
	}
    return Slack_Send_Message($hash, @args);
}
#####################################
sub
Slack_Send_Message
{
	my $hash = shift;
	my $msg = join(" ", @_);
	$msg =~ s/\_/\n/g;

	my $ua = LWP::UserAgent->new;
	$ua->timeout(15);

	my $token = $hash->{token};
	my $user = $hash->{user};
	my $channel = $hash->{channel};
	
	my $resp = $ua->post("https://slack.com/api/chat.postMessage", ['token' => $token, 'username' => $user, 'channel' => "#$channel", 'text' => $msg]);
  
	if ($resp->is_success) {
	  	Log3 $hash->{NAME}, 4, "Success in sending slack message: ". $resp->content;
		return;
	}
	 else {
	  	Log3 $hash->{NAME}, 2, "Error sending slack message: ". $resp->status_line;
	}
}

1;

###############################################################################
