###############################################

package main;
use LWP::UserAgent;
use HTTP::Request::Common qw(POST);
use HTTP::Request::Common qw(POST);
use LWP::UserAgent;
use JSON;

sub
IFTTT_Initialize($)
{
  my ($hash) = @_;

  $hash->{DefFn}   = "IFTTT_Define";
  $hash->{SetFn}   = "IFTTT_Set";
}

#####################################
sub
IFTTT_Define($$)
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
IFTTT_Set($@)
{
  my ($hash, $name, $cmd, @args) = @_;
	my %sets = ('event' => 1);
	if(!defined($sets{$cmd})) {
		return "Unknown argument ". $cmd . ", choose one of " . join(" ", sort keys %sets);
	}
    return IFTTT_TriggerEvent($hash, @args);
}
#####################################
sub
IFTTT_TriggerEvent
{
	my ($hash,$event,$val) = @_;
	my $key = $hash->{key};
    
	my $url = "https://maker.ifttt.com/trigger/$event/with/key/$key";
	my $ua = LWP::UserAgent->new;
	$ua->timeout(15);

	my $resp;
	
	if ($val)
	{
		$resp = $ua->post($url, ['value1' => $val]);
	}
	else
	{
		$resp = $ua->get($url);
	}
  
	if ($resp->is_success) {
	  	Log3 $hash->{NAME}, 4, "Success in sending IFTTT message $url: ". $resp->content;
		return;
	}
	 else {
	  	Log3 $hash->{NAME}, 2, "Error sending IFTTT message $url: ". $resp->status_line;
	}
}

1;

###############################################################################

=pod
=begin html

<a name="IFTTT"></a>
<h3>Slack</h3>
<ul>
  This module allows FHEM to communicate to a IFTTT maker channel.
  <br>
  
  <br><br>
  <a name="IFTTTdefine"></a>
  <b>Define</b>
  <ul>
    <code>define &lt;name&gt; IFTTT &lt;key&gt;</code>
  <br>
  <br>
  &lt;key&gt; is the API key
=end html

=begin html_DE

<a name="IFTTT"></a>
<h3>Slack</h3>
<ul>
  Dieses Modul erlaubt es FHEM, mit IFTTT zu kommunizieren.
  <br>
  <br>
  
  <br><br>
  <a name="IFTTTdefine"></a>
  <b>Define</b>
  <ul>
    <code>define &lt;name&gt; IFTTT &lt;key&gt;</code>
  <br>
  <br>
  &lt;key&gt; ist der API-Key

=end html_DE

=cut
