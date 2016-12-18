############################################################
# 99_insolation
#
# Helper methods for calculation insolation on walls, windows, and roofs based on sun position
# 
# Author andreas@schmidt.name
###########################################################
package main;

use strict;
use warnings;
use POSIX;
use Math::Trig;
use Math::Trig ':radial';

sub
insolation_Initialize($$)
{
  my ($hash) = @_;
}

# Returns the insolation for a plane with the normal vector
# described by azimuth angle $d (clockwise) and elevation angle (90 = zenith) in degrees
# and the sun position described by azimuth and elevation (with north = 0)
# as provided by the Twilight module
# and the global insolation (adjusted by cloud cover) $i

sub
getInsolationForPlane
{ 
   my ($d,$b,$a,$e,$i) = @_;
   my ($x1,$y1,$z1) = spherical_to_cartesian(1, deg2rad(360 - $d), deg2rad(90-$b));
   my ($x2,$y2,$z2) = spherical_to_cartesian(1, deg2rad(360 - $a), deg2rad(90-$e));
   my $g = $x1*$x2+$y1*$y2+$z1*$z2;
   return max(0,$i * $g) if ($e >= 0);
}

sub
getInsolationGlobal
{
  my $cloudCover = shift;
  return 1367 * 0.75 * $cloudCover;
}

1;