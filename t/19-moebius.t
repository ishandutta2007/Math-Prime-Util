#!/usr/bin/env perl
use strict;
use warnings;

use Test::More;
use Math::Prime::Util
   qw/moebius mertens euler_phi jordan_totient divisor_sum exp_mangoldt
      chebyshev_theta chebyshev_psi carmichael_lambda/;

my $extra = defined $ENV{EXTENDED_TESTING} && $ENV{EXTENDED_TESTING};
my $use64 = Math::Prime::Util::prime_get_config->{'maxbits'} > 32;
my $broken64 = (18446744073709550592 == ~0);
$use64 = 0 if $broken64;

my @moeb_vals = (qw/ 1 -1 -1 0 -1 1 -1 0 0 1 -1 0 -1 1 1 0 -1 0 -1 0 /);
my %mertens = (
        1 =>    1,
        2 =>    0,
        3 =>   -1,
        4 =>   -1,
        5 =>   -2,
       10 =>   -1,
      100 =>    1,
     1000 =>    2,
    10000 =>  -23,
        8 =>   -2,
       16 =>   -1,
       32 =>   -4,
       64 =>   -1,
      128 =>   -2,
      256 =>   -1,
      512 =>   -4,
     1024 =>   -4,
     2048 =>    7,
     4096 =>  -19,
     8192 =>   22,
);
my %big_mertens = (
   100000 =>  -48,
  1000000 =>  212,
 10000000 => 1037,
);
if ($extra && $use64) {
  %big_mertens = ( %big_mertens,
          2 =>  0,      # A087987, mertens at primorials
          6 => -1,
         30 => -3,
        210 => -1,
       2310 => -1,
      30030 => 16,
     510510 => -25,
    9699690 => 278,
  223092870 => 3516,

    6433477 => 900,     # 30^2
  109851909 => -4096,   # A084235, 2^12  

      2**14 =>  -32,    # A084236
      2**15 =>   26,
      2**16 =>   14,
      2**17 =>  -20,
      2**18 =>   24,
      2**19 => -125,
      2**20 =>  257,
      2**21 => -362,
      2**22 =>  228,
      2**23 =>  -10,

     10**8  => 1928,
     10**9  => -222,
#  1*10**10 => -33722,  # From Deleglise and Rivat
#  2*10**10 => -48723,  # Too slow with current method
  );
}

my %totients = (
     123456 => 41088, 
     123457 => 123456,
  123456789 => 82260072,
);
my @A000010 = (0,1,1,2,2,4,2,6,4,6,4,10,4,12,6,8,8,16,6,18,8,12,10,22,8,20,12,18,12,28,8,30,16,20,16,24,12,36,18,24,16,40,12,42,20,24,22,46,16,42,20,32,24,52,18,40,24,36,28,58,16,60,30,36,32,48,20,66,32,44);
#@totients{0..$#A000010} = @A000010;

my @A001615 = (1,3,4,6,6,12,8,12,12,18,12,24,14,24,24,24,18,36,20,36,32,36,24,48,30,42,36,48,30,72,32,48,48,54,48,72,38,60,56,72,42,96,44,72,72,72,48,96,56,90,72,84,54,108,72,96,80,90,60,144,62,96,96,96,84,144,68,108,96);

my %jordan_totients = (
  # A000010
  1 => [1, 1, 2, 2, 4, 2, 6, 4, 6, 4, 10, 4, 12, 6, 8, 8, 16, 6, 18, 8, 12, 10, 22, 8, 20, 12, 18, 12, 28, 8, 30, 16, 20, 16, 24, 12, 36, 18, 24, 16, 40, 12, 42, 20, 24, 22, 46, 16, 42, 20, 32, 24, 52, 18, 40, 24, 36, 28, 58, 16, 60, 30, 36, 32, 48, 20, 66, 32, 44],
  # A007434
  2 => [1, 3, 8, 12, 24, 24, 48, 48, 72, 72, 120, 96, 168, 144, 192, 192, 288, 216, 360, 288, 384, 360, 528, 384, 600, 504, 648, 576, 840, 576, 960, 768, 960, 864, 1152, 864, 1368, 1080, 1344, 1152, 1680, 1152, 1848, 1440, 1728, 1584, 2208, 1536],
  # A059376
  3 => [1, 7, 26, 56, 124, 182, 342, 448, 702, 868, 1330, 1456, 2196, 2394, 3224, 3584, 4912, 4914, 6858, 6944, 8892, 9310, 12166, 11648, 15500, 15372, 18954, 19152, 24388, 22568, 29790, 28672, 34580, 34384, 42408, 39312, 50652, 48006, 57096],
  # A059377
  4 => [1, 15, 80, 240, 624, 1200, 2400, 3840, 6480, 9360, 14640, 19200, 28560, 36000, 49920, 61440, 83520, 97200, 130320, 149760, 192000, 219600, 279840, 307200, 390000, 428400, 524880, 576000, 707280, 748800, 923520, 983040, 1171200],
  # A059378
  5 => [1, 31, 242, 992, 3124, 7502, 16806, 31744, 58806, 96844, 161050, 240064, 371292, 520986, 756008, 1015808, 1419856, 1822986, 2476098, 3099008, 4067052, 4992550, 6436342, 7682048, 9762500, 11510052, 14289858, 16671552, 20511148],
  # A069091
  6 => [1, 63, 728, 4032, 15624, 45864, 117648, 258048, 530712, 984312, 1771560, 2935296, 4826808, 7411824, 11374272, 16515072, 24137568, 33434856, 47045880, 62995968, 85647744, 111608280, 148035888, 187858944, 244125000, 304088904, 386889048],
  # A069092
  7 => [1, 127, 2186, 16256, 78124, 277622, 823542, 2080768, 4780782, 9921748, 19487170, 35535616, 62748516, 104589834, 170779064, 266338304, 410338672, 607159314, 893871738, 1269983744, 1800262812, 2474870590, 3404825446],
);

my %sigmak = (
  # A0000005
  0 => [1,2,2,3,2,4,2,4,3,4,2,6,2,4,4,5,2,6,2,6,4,4,2,8,3,4,4,6,2,8,2,6,4,4,4,9,2,4,4,8,2,8,2,6,6,4,2,10,3,6,4,6,2,8,4,8,4,4,2,12,2,4,6,7,4,8,2,6,4,8,2,12,2,4,6,6,4,8,2,10,5,4,2,12,4,4,4,8,2,12,4,6,4,4,4,12,2,6,6,9,2,8,2,8],
  # A000203
  1 => [1, 3, 4, 7, 6, 12, 8, 15, 13, 18, 12, 28, 14, 24, 24, 31, 18, 39, 20, 42, 32, 36, 24, 60, 31, 42, 40, 56, 30, 72, 32, 63, 48, 54, 48, 91, 38, 60, 56, 90, 42, 96, 44, 84, 78, 72, 48, 124, 57, 93, 72, 98, 54, 120, 72, 120, 80, 90, 60, 168, 62, 96, 104, 127, 84, 144, 68, 126, 96, 144],
  # A001157
  2 => [1, 5, 10, 21, 26, 50, 50, 85, 91, 130, 122, 210, 170, 250, 260, 341, 290, 455, 362, 546, 500, 610, 530, 850, 651, 850, 820, 1050, 842, 1300, 962, 1365, 1220, 1450, 1300, 1911, 1370, 1810, 1700, 2210, 1682, 2500, 1850, 2562, 2366, 2650, 2210, 3410, 2451, 3255],
  # A001158
  3 => [1, 9, 28, 73, 126, 252, 344, 585, 757, 1134, 1332, 2044, 2198, 3096, 3528, 4681, 4914, 6813, 6860, 9198, 9632, 11988, 12168, 16380, 15751, 19782, 20440, 25112, 24390, 31752, 29792, 37449, 37296, 44226, 43344, 55261, 50654, 61740, 61544],
);

my %mangoldt = (
  0 => 1,
  1 => 1,
  2 => 2,
  3 => 3,
  4 => 2,
  5 => 5,
  6 => 1,
  7 => 7,
  8 => 2,
  9 => 3,
 10 => 1,
 11 => 11,
 25 => 5,
 27 => 3,
 399981 => 1,
 399982 => 1,
 399983 => 399983,
 823543 => 7,
 83521 => 17,
 130321 => 19,
);

my %chebyshev1 = (
       0 =>       0,
       1 =>       0,
       2 =>       0.693147180559945,
       3 =>       1.79175946922805,
       4 =>       1.79175946922805,
       5 =>       3.40119738166216,
     243 =>     226.593507136467,
 1234567 => 1233272.80087825,
);
my %chebyshev2 = (
       0 =>       0,
       1 =>       0,
       2 =>       0.693147180559945,
       3 =>       1.79175946922805,
       4 =>       2.484906649788,
       5 =>       4.0943445622221,
     243 =>     245.274469978683,
 1234567 => 1234515.17962833,
);

my @A002322 = (0,1,1,2,2,4,2,6,2,6,4,10,2,12,6,4,4,16,6,18,4,6,10,22,2,20,12,18,6,28,4,30,8,10,16,12,6,36,18,12,4,40,6,42,10,12,22,46,4,42,20,16,12,52,18,20,6,18,28,58,4,60,30,6,16,12,10,66,16,22,12,70,6,72,36,20,18,30,12,78,4,54,40,82,6,16,42,28,10,88,12,12,22,30,46,36,8,96,42,30,20,100,16,102,12,12,52,106,18,108,20,36,12,112,18,44,28,12,58,48,4,110,60,40,30,100,6,126,32,42,12,130,10,18,66,36,16,136,22,138,12,46,70,60,12,28,72,42,36,148,20,150,18,48,30,60,12,156,78,52,8,66,54,162,40,20,82,166,6,156,16,18,42,172,28,60,20,58,88,178,12,180,12,60,22,36,30,80,46,18,36,190,16,192,96,12,42,196,30,198,20);


plan tests => 0 + 1
                + 1 # Small Moebius
                + 3*scalar(keys %mertens)
                + 1*scalar(keys %big_mertens)
                + 2 # Small Phi
                + 7 + scalar(keys %totients)
                + 1 # Small Carmichael Lambda
                + scalar(keys %jordan_totients)
                + 2  # Dedekind psi calculated two ways
                + 1  # Calculate J5 two different ways
                + 2 * $use64 # Jordan totient example
                + 1 + scalar(keys %sigmak)
                + scalar(keys %mangoldt)
                + scalar(keys %chebyshev1)
                + scalar(keys %chebyshev2);

ok(!eval { moebius(0); }, "moebius(0)");

{
  my @moebius = map { moebius($_) } (1 .. scalar @moeb_vals);
  is_deeply( \@moebius, \@moeb_vals, "moebius 1 .. " . scalar @moeb_vals );
}

while (my($n, $mertens) = each (%mertens)) {
  my $M = 0;
  $M += moebius($_) for (1 .. $n);
  is( $M, $mertens, "sum(moebius(k) for k=1..$n) == $mertens" );
  # Calculate using ranged moebius
  $M = 0;
  $M += $_ for moebius(1,$n);
  is( $M, $mertens, "sum(moebius(1..$n) == $mertens" );
  # Now with mertens function
  is( mertens($n), $mertens, "mertens($n) == $mertens" );
}
while (my($n, $mertens) = each (%big_mertens)) {
  is( mertens($n), $mertens, "mertens($n)" );
}

{
  my @phi = map { euler_phi($_) } (0 .. $#A000010);
  is_deeply( \@phi, \@A000010, "euler_phi 0 .. $#A000010" );
}
{
  my @phi = euler_phi(0, $#A000010);
  is_deeply( \@phi, \@A000010, "euler_phi with range: 0, $#A000010" );
}
while (my($n, $phi) = each (%totients)) {
  is( euler_phi($n), $phi, "euler_phi($n) == $phi" );
}
is_deeply( [euler_phi(0,0)], [0],     "euler_phi(0,0)" );
is_deeply( [euler_phi(1,0)], [],      "euler_phi with end < start" );
is_deeply( [euler_phi(0,1)], [0,1],   "euler_phi 0-1" );
is_deeply( [euler_phi(1,2)], [1,1],   "euler_phi 1-2" );
is_deeply( [euler_phi(1,3)], [1,1,2], "euler_phi 1-3" );
is_deeply( [euler_phi(2,3)], [1,2],   "euler_phi 2-3" );
is_deeply( [euler_phi(10,20)], [4,10,4,12,6,8,8,16,6,18,8], "euler_phi 10-20" );

###### Jordan Totient
while (my($k, $tref) = each (%jordan_totients)) {
  my @tlist;
  foreach my $n (1 .. scalar @$tref) {
    push @tlist, jordan_totient($k, $n);
  }
  is_deeply( \@tlist, $tref, "Jordan's Totient J_$k" );
}

{
  my @psi_viaj;
  my @psi_viamobius;
  foreach my $n (1 .. scalar @A001615) {
    push @psi_viaj, int(jordan_totient(2, $n) / jordan_totient(1, $n));
    push @psi_viamobius, int($n * divisor_sum( $n, sub { moebius($_[0])**2 / $_[0] } ) + 0.5);
  }
  is_deeply( \@psi_viaj, \@A001615, "Dedikind psi(n) = J_2(n)/J_1(n)" );
  is_deeply( \@psi_viamobius, \@A001615, "Dedikind psi(n) = divisor_sum(n, moebius(d)^2 / d)" );
}

{
  my @J5_moebius = map { divisor_sum($_, sub { my $d=shift; $d**5 * moebius($_/$d); }) } (0 .. 100);
  my @J5_jordan = map { jordan_totient(5, $_) } (0 .. 100);
  is_deeply( \@J5_moebius, \@J5_jordan, "Calculate J5 two different ways");
}

if ($use64) {
  is( jordan_totient(4, 12345), 22902026746060800, "J_4(12345)" );
  # Apostal page 48, 17a.
  is( divisor_sum( 12345, sub { jordan_totient(4,$_[0]) } ),
      # was int(12345 ** 4), but Perl 5.8.2 gets it wrong.
      int(12345*12345*12345*12345),
      "n=12345, k=4  :   n**k = divisor_sum(n, jordan_totient(k, d))" );
}

###### Divisor sum
while (my($k, $sigmaref) = each (%sigmak)) {
  my @slist;
  foreach my $n (1 .. scalar @$sigmaref) {
    push @slist, divisor_sum( $n, sub { int($_[0] ** $k) } );
  }
  is_deeply( \@slist, $sigmaref, "Sum of divisors to the ${k}th power: Sigma_$k" );
}
# k=1 standard sum -- much faster
{
  my @slist = map { divisor_sum($_) } 1 .. scalar @{$sigmak{1}};
  is_deeply(\@slist, $sigmak{1}, "divisor_sum(n)");
}

###### Exponential of von Mangoldt
while (my($n, $em) = each (%mangoldt)) {
  is( exp_mangoldt($n), $em, "exp_mangoldt($n) == $em" );
}

###### first Chebyshev function
while (my($n, $c1) = each (%chebyshev1)) {
  cmp_closeto( chebyshev_theta($n), $c1, 1e-9*abs($n), "chebyshev_theta($n)" );
}
###### second Chebyshev function
while (my($n, $c2) = each (%chebyshev2)) {
  cmp_closeto( chebyshev_psi($n), $c2, 1e-9*abs($n), "chebyshev_psi($n)" );
}

###### Carmichael Lambda
{
  my @lambda = map { carmichael_lambda($_) } (0 .. $#A002322);
  is_deeply( \@lambda, \@A002322, "carmichael_lambda with range: 0, $#A000010" );
}


sub cmp_closeto {
  my $got = shift;
  my $expect = shift;
  my $tolerance = shift;
  my $message = shift;
  cmp_ok( abs($got - $expect), '<=', $tolerance, $message );
}
