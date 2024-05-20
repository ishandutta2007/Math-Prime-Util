#!/usr/bin/env perl
use strict;
use warnings;

use Test::More;
use Math::Prime::Util qw/is_powerfree powerfree_count powerfree_sum
                         powerfree_part powerfree_part_sum nth_powerfree
                         is_square_free vecsum vecmax factor_exp/;

my @simple = (0 .. 16,
              758096738,434420340,870589313,695486396,602721315,418431087,
              752518565,723570005,506916483,617459403);

plan tests => 3     # simple is square free
            + 11*2  # powerfree_count, powerfree_sum
            + 6+2   # ""
            + 7     # nth_powerfree
            + 1+8   # powerfree_part
            + 8*2;  # powerfree_part_sum

##### is_powerfree

is_deeply( [map { is_powerfree($_)   } @simple],
           [map { is_square_free($_) } @simple],
           "is_powerfree(n) matches is_square_free(n)" );
is_deeply( [map { is_powerfree($_)   } @simple],
           [map { ipf($_)            } @simple],
           "is_powerfree(n) works for simple inputs" );
is_deeply( [map { is_powerfree($_,3) } @simple],
           [map { ipf($_,3)          } @simple],
           "is_powerfree(n,3) works for simple inputs" );

##### powerfree_count and powerfree_sum

foreach my $k (0..10) {
    my $n = 100;
    is_deeply(
        [map { powerfree_count($_, $k) } 0..$n],
        [map { scalar grep { is_powerfree($_, $k) } 1..$_ } 0..$n],
        "powerfree_count(0..$n, $k)"
    );
    is_deeply(
        [map { powerfree_sum($_, $k) } 0..$n],
        [map { vecsum(grep { is_powerfree($_, $k) } 1..$_) } 0..$n],
        "powerfree_sum(0..$n, $k)"
    );
}

is( powerfree_count(12345,2),  7503, "powerfree_count(12345,2) = 7503");
is( powerfree_count(12345,3), 10272, "powerfree_count(12345,3) = 10272");
is( powerfree_count(12345,4), 11408, "powerfree_count(12345,4) = 11408");
is( powerfree_sum(12345,2), 46286859, "powerfree_sum(12345,2) = 46286859");
is( powerfree_sum(12345,3), 63404053, "powerfree_sum(12345,3) = 63404053");
is( powerfree_sum(12345,4), 70415676, "powerfree_sum(12345,4) = 70415676");

is( powerfree_count(123456,32), 123456, "powerfree_count(123456,32) = 123456");
is( powerfree_sum(123456,32), 7620753696, "powerfree_sum(123456,32) = 7620753696");

##### nth_powerfree
is(nth_powerfree(7503), 12345, "nth_powerfree(7503) = 12345");
is(nth_powerfree(10272,3), 12345, "nth_powerfree(10272,3) = 12345");
is(nth_powerfree(11408,4), 12345, "nth_powerfree(11408,4) = 12345");
is(nth_powerfree(915099,3), 1099999, "nth_powerfree(915099,3) = 1099999");
is(nth_powerfree("1000000",2), 1644918, "nth_powerfree(10^6,2) = 1644918");
is(nth_powerfree("1000000",3), 1202057, "nth_powerfree(10^6,3) = 1202057");
is(nth_powerfree("100000000",5), 103692775, "nth_powerfree(10^8,5) = 103692775");


##### powerfree_part

is_deeply( [map { powerfree_part($_) } 0..30],
           [0,1,2,3,1,5,6,7,2,1,10,11,3,13,14,15,1,17,2,19,5,21,22,23,6,1,26,3,7,29,30],
           "powerfree_part(0..30)" );

{
  my $n = "3709362688507618309707310743757146859608351353598858915828644464895074572939593330420817674692554750";
  is(powerfree_part($n,0), 0, "powerfree_part(n,0) = 0");
  is(powerfree_part($n,1), 0, "powerfree_part(n,1) = 0");
  is(powerfree_part($n,2), 1333310, "powerfree_part(n,2) = 1333310");
  is(powerfree_part($n,3), "2607554680038", "powerfree_part(n,3)");
  is(powerfree_part($n,4), "11841796277238534750", "powerfree_part(n,4)");
  is(powerfree_part($n,5), "1653305696539190388308250", "powerfree_part(n,5)");
  is(powerfree_part($n,6), "1315461663807740740160892737772750", "powerfree_part(n,6)");
  is(powerfree_part($n,7), "65926023382783093515719030419129876118250", "powerfree_part(n,7)");
}

##### powerfree_part

my @pfpst = (1,1,140859826282,181173729990,198592475728,206650589642,210471526468,212309099991);
for my $k (0 .. 7) {
  is_deeply(
      [map { powerfree_part_sum($_, $k) } 0..32],
      [map { vecsum(map { powerfree_part($_, $k) } 1..$_) } 0..32],
      "powerfree_part_sum(0..64, $k)"
  );
  is( powerfree_part_sum(654321,$k), $pfpst[$k], "powerfree_part_sum(654321,$k) = $pfpst[$k]" );
}

##### subs

sub ipf {
  my($n,$k) = @_;
  $k = 2 unless defined $k;
  $n = -$n if $n < 0;
  return 0 if $n == 0;
  return 1 if $n == 1;

  (vecmax(map { $_->[1] } factor_exp($n)) < $k) ? 1 : 0;
}
