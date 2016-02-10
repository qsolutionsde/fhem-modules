###############################################

package main;
use LWP::UserAgent;
use HTTP::Request::Common qw(GET);
use URI::Encode qw(uri_encode uri_decode);
use JSON;

# Kommandos
# showURL <url>
# startDaydream
# say <text>
# setAlarm
# deleteAlarm

sub
AutoRemote_Initialize($)
{
  my ($hash) = @_;

  $hash->{DefFn}   = "AutoRemote_Define";
  $hash->{SetFn}   = "AutoRemote_Set";
}

#####################################
sub
AutoRemote_Define($$)
{
  my ($hash, $def) = @_;
  my @args = split("[ \t]+", $def);

  my $name = shift @args;
  my $devtype = shift @args;
 
  $hash->{key} = shift @args;
 
  $hash->{STATE} = 'Initialized';
  return undef; 
}

#####################################
sub
AutoRemote_Set($@)
{
  my ($hash, $name, $cmd, @args) = @_;
	my %sets = ('msg' => 1);
	if(!defined($sets{$cmd})) {
		return "Unknown argument ". $cmd . ", choose one of " . join(" ", sort keys %sets);
	}
    return AutoRemote_send($hash, @args);
}
#####################################
sub
AutoRemote_send
{
	my ($hash,$command,@vals) = @_;
	my $key = $hash->{key};
	my $msg = uri_encode(join(' ', @vals) . '=:=' . $command);
	
	my $url = "https://autoremotejoaomgcd.appspot.com/sendmessage?key=$key&message=$msg";
	my $ua = LWP::UserAgent->new;
	$ua->timeout(15);

	my $resp = $ua->get($url);
  
	if ($resp->is_success) {
	  	Log3 $hash->{NAME}, 4, "Success in sending AutoRemote message $url: ". $resp->content;
		return;
	}
	 else {
	  	Log3 $hash->{NAME}, 2, "Error sending AutoRemote message $url: ". $resp->status_line;
	}
}

1;
