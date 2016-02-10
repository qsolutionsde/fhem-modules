###############################################

package main;
use LWP::UserAgent;
use HTTP::Request;
use HTTP::Request::Common qw(POST);
use LWP::UserAgent;
use JSON;

sub
Numerous_Initialize($)
{
  my ($hash) = @_;

  $hash->{DefFn}   = "Numerous_Define";
  $hash->{SetFn}   = "Numerous_Set";
  $hash->{GetFn}   = "Numerous_Get";
}

#####################################
sub
Numerous_Define($$)
{
  my ($hash, $def) = @_;
  my @args = split("[ \t]+", $def);

  my ($name, $type, $apikey, $metricid) = @args;
  
  $hash->{STATE} = 'Initialized';

  if(defined($apikey)) {
	  $hash->{apikey} = $apikey;
	  $hash->{metricid} = $metricid;

	return undef; 
  }
}

#####################################
sub
Numerous_Set($@)
{
  my ($hash, $name, $cmd, @args) = @_;
	my %sets = ('update' => 1);
	if(!defined($sets{$cmd})) {
		return "Unknown argument ". $cmd . ", choose one of " . join(" ", sort keys %sets);
	}
    return Numerous_Send($hash, @args);
}
#####################################
sub
Numerous_Send
{
  my $hash = shift;
  my $msg = shift;

  my $req = HTTP::Request->new(POST => "https://" . $hash->{apikey} . ":\@api.numerousapp.com/v2/metrics/" . $hash->{metricid} . "/events");
  $req->content_type('application/json');
  $req->content('{"value":' . $msg . '}');
  
  my $ua = LWP::UserAgent->new;
  $ua->timeout(15);

  my $resp = $ua->request($req);

	if ($resp->is_success) {
	  Log3 $hash->{NAME},4,$resp->decoded_content;
	}
	 else {
	  	  Log3 $hash->{NAME},2,"Error accessing numerous: " . $resp->status_line . ": https://" . $hash->{apikey} . ":\@api.numerousapp.com/v2/metrics/" . $hash->{metricid} . "/events ";
	}
}

sub
Numerous_Get($@)
{
  my ($hash, @a) = @_;
  my $name = shift @a;

  my $req = HTTP::Request->new(GET => "https://" . $hash->{apikey} . ":\@api.numerousapp.com/v2/metrics/" . $hash->{metricid});

}
1;

###############################################################################
