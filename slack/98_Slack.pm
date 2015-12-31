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

=pod
=begin html

<a name="Slack"></a>
<h3>Slack</h3>
<ul>
  This module allows FHEM to communicate to a Slack channel as a bot.
  <br>
  <br>
  You have to create a bot for your team first and obtain the API token.
  
  <br><br>
  <a name="Slackdefine"></a>
  <b>Define</b>
  <ul>
    <code>define &lt;name&gt; Slack &lt;token&gt; &lt;user&gt; &lt;channel&gt;</code>
  <br>
  <br>
  &lt;token&gt; is the API token
  <br>
  &lt;user&gt; is the user name
  <br>
  &lt;channel&gt; is the channel to post to (without #)
=end html

=begin html_DE

<a name="Slack"></a>
<h3>Slack</h3>
<ul>
  Dieses Modul erlaubt es FHEM, über Slack als Bot zu kommunizieren.
  <br>
  <br>
  Es muss zuvor ein Bot angelegt worden sein und der API-Key wird benötigt.
  
  <br><br>
  <a name="Slackdefine"></a>
  <b>Define</b>
  <ul>
    <code>define &lt;name&gt; Slack &lt;token&gt; &lt;user&gt; &lt;channel&gt;</code>
  <br>
  <br>
  &lt;token&gt; ist das API-Token
  <br>
  &lt;user&gt; ist der Name
  <br>
  &lt;channel&gt; ist der Channel (ohne #)

=end html_DE

=cut
