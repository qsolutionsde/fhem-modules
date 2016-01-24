package main;

use strict;
use warnings;
use POSIX;
use Date::Calc qw(:all);

sub
calviewrg_Initialize($$)
{
  my ($hash) = @_;
}

sub
calviewrg_getRgDef
{
    my ($view) = @_;
    
    my $n = ReadingsVal($view,"c-term", 0);
    my $r = '<Datum>,<>,<> ';
    
    for(my $i = 1; $i <= $n; $i++) {
        my $j = sprintf('%03d', $i);
        $r .= "$view:<{calviewrg_getWeekday('$view','$j')}>,t_" . $j . '_bdate' . ',t_' . $j. '_summary ';
    }
    
    return $r;
}

sub
calviewrg_getAllDayRgDef
{
    my ($view) = @_;
    
    my $n = ReadingsVal($view,"c-term", 0);
    my $r = '<Datum>,<>,<>,<> ';
    
    for(my $i = 1; $i <= $n; $i++) {
        my $j = sprintf('%03d', $i);
		my $jt = 't_' . $j . '_';
		if ( (ReadingsVal($view,'t_' . $j . '_btime', '00:00:00') eq '00:00:00') and (ReadingsVal($view,'t_' . $j . '_etime', '00:00:00') eq '00:00:00') ) 
		{	$r .= "$view:<{calviewrg_getWeekday('$view','$j')}>," . $jt . 'bdate' . ',' . $jt . 'edate' . ',' . $jt. 'summary '; }
    }
    
    return $r;
}

sub
calviewrg_getTimeRgDef
{
    my ($view) = @_;
    
    my $n = ReadingsVal($view,"c-term", 0);
    my $r = '<Datum>,<>,<>,<>,<> ';
    
    for(my $i = 1; $i <= $n; $i++) {
        my $j = sprintf('%03d', $i);
		my $jt = 't_' . $j . '_';
        $r .= "$view:<{calviewrg_getWeekday('$view','$j')}>," . $jt . 'bdate,' . $jt . 'btime,' . $jt . 'etime,' . $jt . 'summary ';
    }
    
    return $r;
}

sub calviewrg_getWeekday
{
    my ($view,$j) = @_;
    my $d = ReadingsVal($view,'t_' . $j . '_bdate',0);
    my ($d,$m,$y) = split(/\./,$d);
    my $dow = Day_of_Week($y,$m,$d);
    
    my @wd = ('So','Mo','Di','Mi','Do','Fr','Sa','So');
    
    return  $wd[$dow];
}

sub
calviewrg_createRg
{
    my ($view,$rg) = @_;
    
    fhem("set $view update");
    my $i;
    
    my $def = calviewrg_getRgDef($view);
    
    fhem("defmod $rg readingsGroup $def");
}

sub
calviewrg_createAllDayRg
{
    my ($view,$rg) = @_;
    
    fhem("set $view update");
    my $i;
    
    my $def = calviewrg_getAllDayRgDef($view);
    
    fhem("defmod $rg readingsGroup $def");
}

sub
calviewrg_createTimeRg
{
    my ($view,$rg) = @_;
    
    fhem("set $view update");
    my $i;
    
    my $def = calviewrg_getTimeRgDef($view);
    
    fhem("defmod $rg readingsGroup $def");
}

1;