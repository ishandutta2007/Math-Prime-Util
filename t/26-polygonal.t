#!/usr/bin/env perl
use strict;
use warnings;

use Test::More;
use Math::Prime::Util qw/is_polygonal/;
#my $usexs = Math::Prime::Util::prime_get_config->{'xs'};
#my $usegmp = Math::Prime::Util::prime_get_config->{'gmp'};
#my $extra = defined $ENV{EXTENDED_TESTING} && $ENV{EXTENDED_TESTING};

my @expect = (
  [1,3,6,10,15,21,28,36,45,55],
  [1,4,9,16,25,36,49,64,81,100],
  [1,5,12,22,35,51,70,92,117,145],
  [1,6,15,28,45,66,91,120,153,190],
  [1,7,18,34,55,81,112,148,189,235],
  [1,8,21,40,65,96,133,176,225,280],
  [1,9,24,46,75,111,154,204,261,325],
  [1,10,27,52,85,126,175,232,297,370],
  [1,11,30,58,95,141,196,260,333,415],
  [1,12,33,64,105,156,217,288,369,460],
  [1,13,36,70,115,171,238,316,405,505],
  [1,14,39,76,125,186,259,344,441,550],
  [1,15,42,82,135,201,280,372,477,595],
  [1,16,45,88,145,216,301,400,513,640],
  [1,17,48,94,155,231,322,428,549,685],
  [1,18,51,100,165,246,343,456,585,730],
  [1,19,54,106,175,261,364,484,621,775],
  [1,20,57,112,185,276,385,512,657,820],
  [1,21,60,118,195,291,406,540,693,865],
  [1,22,63,124,205,306,427,568,729,910],
  [1,23,66,130,215,321,448,596,765,955],
  [1,24,69,136,225,336,469,624,801,1000],
  [1,25,72,142,235,351,490,652,837,1045],
);

plan tests => 0
            + 2*scalar(@expect)
            + 2
            + 5;
            ;

for my $k (3 .. 25) {
  my ($n, @p) = (0);
  while (@p < 10) {
    fail "seems broken" if $n > 10000;
    next unless is_polygonal(++$n, $k);
    push @p, $n;
  }
  is_deeply( \@p, $expect[$k-3], "is_polygonal finds first 10 $k-gonal numbers");
}

for my $k (3 .. 25) {
  my ($n, $r, @r) = (0);
  while (@r < 10) {
    fail "seems broken" if $n > 10000;
    next unless is_polygonal(++$n, $k, \$r);
    push @r, $r;
  }
  is_deeply( \@r, [1,2,3,4,5,6,7,8,9,10], "is_polygonal correct $k-gonal n");
}

ok(!is_polygonal("724424175519274711242",3), "724424175519274711242 is not a triangular number");
ok(is_polygonal("510622052816898545467859772308206986101878",3), "510622052816898545467859772308206986101878 is a triangular number");

{
  my($is,$r);
  $is = is_polygonal(0, 4294967297, \$r);
  ok( $is, "0 is a polygonal number" );
  is( $r, 0, "is_polygonal with 0 sets r to 0" );
  $is = is_polygonal(1, 4294967297, \$r);
  ok( $is, "1 is a polygonal number" );
  is( $r, 1, "is_polygonal with 1 sets r to 1" );
  ok( !is_polygonal(-1, 3), "-1 is not a polygonal number" );
}
