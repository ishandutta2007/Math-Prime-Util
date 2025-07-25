#!/usr/bin/env perl
use strict;
use warnings;

use Test::More;
use Math::Prime::Util qw/lucasu    lucasv    lucasuv
                         lucasumod lucasvmod lucasuvmod
                         foroddcomposites modint/;

#my $use64 = Math::Prime::Util::prime_get_config->{'maxbits'} > 32;
my $extra = defined $ENV{EXTENDED_TESTING} && $ENV{EXTENDED_TESTING};
my $usexs = Math::Prime::Util::prime_get_config->{'xs'};
my $usegmp = Math::Prime::Util::prime_get_config->{'gmp'};

# Values taken from the OEIS pages.
my @lucas_seqs = (
  [ [1, -1], 0, "U", "Fibonacci numbers",
    [0, 1, 1, 2, 3, 5, 8, 13, 21, 34, 55, 89, 144, 233, 377, 610] ],
  [ [1, -1], 0, "V", "Lucas numbers",
    [2, 1, 3, 4, 7, 11, 18, 29, 47, 76, 123, 199, 322, 521, 843] ],
  [ [2, -1], 0, "U", "Pell numbers",
    [0, 1, 2, 5, 12, 29, 70, 169, 408, 985, 2378, 5741, 13860, 33461, 80782] ],
  [ [2, -1], 0, "V", "Pell-Lucas numbers",
    [2, 2, 6, 14, 34, 82, 198, 478, 1154, 2786, 6726, 16238, 39202, 94642] ],
  [ [1, -2], 0, "U", "Jacobsthal numbers",
    [0, 1, 1, 3, 5, 11, 21, 43, 85, 171, 341, 683, 1365, 2731, 5461, 10923] ],
  [ [1, -2], 0, "V", "Jacobsthal-Lucas numbers",
    [2, 1, 5, 7, 17, 31, 65, 127, 257, 511, 1025, 2047, 4097, 8191, 16385] ],
  [ [2, 2], 1, "U", "sin(x)*exp(x)",
    [0, 1, 2, 2, 0, -4, -8, -8, 0, 16, 32, 32, 0, -64, -128, -128, 0, 256] ],
  [ [2, 2], 1, "V", "offset sin(x)*exp(x)",
    [2, 2, 0, -4, -8, -8, 0, 16, 32, 32, 0, -64, -128, -128, 0, 256, 512,512] ],
  [ [2, 5], 1, "U", "A045873",
    [0, 1, 2, -1, -12, -19, 22, 139, 168, -359, -1558, -1321, 5148, 16901] ],
  [ [3,-5], 0, "U", "3*a(n-1)+5*a(n-2) [0,1]",
    [0, 1, 3, 14, 57, 241, 1008, 4229, 17727, 74326, 311613, 1306469] ],
  [ [3,-5], 0, "V", "3*a(n-1)+5*a(n-2) [2,3]",
    [2, 3, 19, 72, 311, 1293, 5434, 22767, 95471, 400248, 1678099, 7035537] ],
  [ [3,-4], 0, "U", "3*a(n-1)+4*a(n-2) [0,1]",
    [0, 1, 3, 13, 51, 205, 819, 3277, 13107, 52429, 209715, 838861, 3355443] ],
  [ [3,-4], 0, "V", "3*a(n-1)+4*a(n-2) [2,3]",
    [2, 3, 17, 63, 257, 1023, 4097, 16383, 65537, 262143, 1048577, 4194303] ],
  [ [3,-1], 0, "U", "A006190",
    [0, 1, 3, 10, 33, 109, 360, 1189, 3927, 12970, 42837, 141481, 467280] ],
  [ [3,-1], 0, "V", "A006497",
    [2, 3, 11, 36, 119, 393, 1298, 4287, 14159, 46764, 154451, 510117,1684802]],
  [ [3, 1], 0, "U", "Fibonacci(2n)",
    [0, 1, 3, 8, 21, 55, 144, 377, 987, 2584, 6765, 17711, 46368, 121393] ],
  [ [3, 1], 0, "V", "Lucas(2n)",
    [2, 3, 7, 18, 47, 123, 322, 843, 2207, 5778, 15127, 39603, 103682, 271443]],
  [ [3, 2], 0, "U", "2^n-1 Mersenne numbers (prime and composite)",
    [0, 1, 3, 7, 15, 31, 63, 127, 255, 511, 1023, 2047, 4095, 8191, 16383] ],
  [ [3, 2], 0, "V", "2^n+1",
    [2, 3, 5, 9, 17, 33, 65, 129, 257, 513, 1025, 2049, 4097, 8193, 16385] ],
  [ [4,-1], 0, "U", "Denominators of continued fraction convergents to sqrt(5)",
    [0, 1, 4, 17, 72, 305, 1292, 5473, 23184, 98209, 416020, 1762289, 7465176]],
  [ [4,-1], 0, "V", "Even Lucas numbers Lucas(3n)",
    [2, 4, 18, 76, 322, 1364, 5778, 24476, 103682, 439204, 1860498, 7881196] ],
  [ [4, 1], 0, "U", "A001353",
    [0, 1, 4, 15, 56, 209, 780, 2911, 10864, 40545, 151316, 564719, 2107560] ],
  [ [4, 1], 0, "V", "A003500",
    [2, 4, 14, 52, 194, 724, 2702, 10084, 37634, 140452, 524174, 1956244] ],
  [ [5, 4], 0, "U", "(4^n-1)/3",
    [0, 1, 5, 21, 85, 341, 1365, 5461, 21845, 87381, 349525, 1398101, 5592405]],
);

# 4,4 has D=0.  Old GMP won't handle that.
if ($usexs || !$usegmp || $Math::Prime::Util::GMP::VERSION >= 0.53) {
  push @lucas_seqs,
  [ [4, 4], 0, "U", "n*2^(n-1)",
    [0, 1, 4, 12, 32, 80, 192, 448, 1024, 2304, 5120, 11264, 24576, 53248] ],
}

my %lucas_sequences = (
  "323 1 1 324" => [0,2],
  "323 4 1 324" => [170,308],
  "323 4 5 324" => [194,156],
  "323 3 1 324" => [0,2],
  "323 3 1  81" => [0,287],
  "323 5 -1 81" => [153,195],
  "49001 25 117 24501" => [20933,18744],
  "18971 10001 -1 4743" => [5866,14421],
  "18971 10001 -1 4743" => [5866,14421],
  "3613982123 1 -1 3613982124" => [0,3613982121],
  "3613982121 1 -1 3613982122" => [2586640546,2746447323],
  "3613982121 1 -1 1806991061" => [3535079342,1187662808],
  "547968611 1 -1 547968612" => [1,3],
  "547968611 1 -1 136992153" => [27044236,448467899],
);

my %lucas_dcheck = ();
if ($usexs || !$usegmp || $Math::Prime::Util::GMP::VERSION >= 0.53) {
  %lucas_dcheck = (
    "7777 -6 9 77"   => [5467,4624],   # D=0
    "7777 -6 7 77"   => [2521,4663],   # D=8
    "7777 4 3 77"    => [2732,5466],   # D=4
    "7777 4 4 77"    => [6237,6889],   # D=0
    "7777 3 5834 77" => [  30,4509],   # D=4 mod n
    "7777 3 5835 77" => [4004,2883],   # D=0 mod n
    "7777 1 5833 77" => [ 385,4449],   # D=0 mod n
    "7777 2 1 77"    => [  77,   2],   # D=0 mod n
    "7777 -8882 1 77"=> [6964, 687],   # D=32 mod n

    "7778 7776 1 32" => [7746,   2],   # D=0 mod n and not invertible
    "7778 7776 1 33" => [  33,7776],   # D=0 mod n and not invertible
    "7778 1976 5 32" => [7764,1080],   # D=0 mod n and not invertible
    "7778 1976 5 33" => [6153,1454],   # D=0 mod n and not invertible
  );
}
my %lucas_large = ();
if (!$usegmp || $Math::Prime::Util::GMP::VERSION >= 0.53) {
  $lucas_large{"10891238901329801329843210 8823012438914798 7334809241809243190243 37"} = [qw/9793462298071844822738199 7806353955219259067966732/];
  if ($extra) {
    $lucas_large{"10891238901329801329801234 9823092438924798 9234809243809243890243 390"} = [qw/6124196139840885691066464 8614669321673340197867400/];
  }
}


my @oeis_81264 = (323, 377, 1891, 3827, 4181, 5777, 6601, 6721, 8149, 10877, 11663, 13201, 13981, 15251, 17119, 17711, 18407, 19043, 23407, 25877, 27323, 30889, 34561, 34943, 35207, 39203, 40501, 50183, 51841, 51983, 52701, 53663, 60377, 64079, 64681);
# The PP lucas sequence is really slow.
$#oeis_81264 = 2 unless $usexs || $usegmp;

my @issue47 = (
  [4,1,-1,951, "2 0"],
  [4,2,-1,951, "1 2"],
  [8,1,-1,47, "1 7"],
  [8,2,-1,47, "1 6"],
  [5,1,-1,0, "0 2"],
  [5,2,-1,0, "0 2"],
  [5,1,-1,66, "3 3"],
  [5,2,-1,66, "0 3"],
  [1001,-4,4,50, "173 827"],
  [1001,-4,7,50, "87 457"],
  [1001,1,-1,50, "330 486"],
  [5,1,-1,4, "3 2"],
  [3,6,9,36, "0 0"],
  [5,10,25,101, "0 0"],
  [6,10,25,101, "5 4"],
  [3,-6,9,0, "0 2"],
  [1,30,1,15, "0 0"],
  [3,3,3,1, "1 0"],
  [3,-30,-30,1, "1 0"],
  [1,9,5,0, "0 0"],      # Everything mod 1
  [104,-14,49,0, "0 2"],
  [104,-14,49,1, "1 90"],
  [8,2,1,1, "1 2"],
  [16,0,0,1, "1 0"],
  [2,11,-27,0, "0 0"],
  [3,30,-2,1, "1 0"],
);

plan tests => 0 + 2*scalar(@lucas_seqs) + 1
                + 3
                + 3 * scalar(keys %lucas_sequences)
                + 6 * scalar(keys %lucas_dcheck)
                + 6 * scalar(keys %lucas_large)
                + scalar(@issue47)
                + 3
                + 3;    # large inputs

foreach my $seqs (@lucas_seqs) {
  my($apq, $isneg, $uorv, $name, $exp) = @$seqs;
  my($P,$Q) = @$apq;
  my $idx = ($uorv eq 'U') ? 0 : 1;
  my @seq = map { (lucasuvmod($P,$Q,$_,2**32-1))[$idx] } 0 .. $#$exp;
  do { for (@seq) { $_ -= (2**32-1) if $_ > 2**31; } } if $isneg;
  is_deeply( [@seq], $exp, "lucas_sequence ${uorv}_n(@$apq) -- $name" );
}

foreach my $seqs (@lucas_seqs) {
  my($apq, $isneg, $uorv, $name, $exp) = @$seqs;
  my($P,$Q) = @$apq;
  if ($uorv eq 'U') {
    is_deeply([map { lucasu($P,$Q,$_) } 0..$#$exp], $exp, "lucasu(@$apq) -- $name");
  } else {
    is_deeply([map { lucasv($P,$Q,$_) } 0..$#$exp], $exp, "lucasv(@$apq) -- $name");
  }
}

{
  my @p;
  foroddcomposites {
    my $t = (($_%5)==2||($_%5)==3) ? $_+1 : $_-1;
    push @p, $_ if lucasumod(1,-1,$t,$_) == 0;
  } $oeis_81264[-1];
  is_deeply( \@p, \@oeis_81264, "OEIS 81264: Odd Fibonacci pseudoprimes" );
}

{
  my $n = 8539786;
  my $e = (0,-1,1,1,-1)[$n%5];
  my($U,$V) = lucasuvmod(1, -1, $n+$e, $n);
  is_deeply( [$U,$V], [0,5466722], "First entry of OEIS A141137: Even Fibonacci pseudoprimes" );
  is(lucasumod(1, -1, $n+$e, $n), 0, "lucasumod agrees");
  is(lucasvmod(1, -1, $n+$e, $n), 5466722, "lucasvmod agrees");
}

# Simple Lucas sequences
while (my($params, $expect) = each (%lucas_sequences)) {
  my($n,$P,$Q,$k) = split(' ', $params);

  is_deeply( [lucasuvmod($P,$Q,$k,$n)], $expect, "lucasuvmod($P,$Q,$k,$n)" );
  is_deeply( lucasumod($P,$Q,$k,$n), $expect->[0], "lucasumod($P,$Q,$k,$n)" );
  is_deeply( lucasvmod($P,$Q,$k,$n), $expect->[1], "lucasvmod($P,$Q,$k,$n)" );

  # Don't run these through lucasuv, lucasu, lucasv
}

# Check D values
my %allcheck = (%lucas_dcheck, %lucas_large);
while (my($params, $expect) = each %allcheck) {
  my($n,$P,$Q,$k) = split(' ', $params);

  is_deeply( [lucasuvmod($P,$Q,$k,$n)], $expect, "lucasuvmod($P,$Q,$k,$n)" );
  is_deeply( lucasumod($P,$Q,$k,$n), $expect->[0], "lucasumod($P,$Q,$k,$n)" );
  is_deeply( lucasvmod($P,$Q,$k,$n), $expect->[1], "lucasvmod($P,$Q,$k,$n)" );

  is_deeply( [map { $_ % $n } lucasuv($P,$Q,$k)], $expect, "lucasuv($P,$Q,$k) % $n" );
  is_deeply( lucasu($P,$Q,$k) % $n, $expect->[0], "lucasu($P,$Q,$k) % $n" );
  is_deeply( lucasv($P,$Q,$k) % $n, $expect->[1], "lucasv($P,$Q,$k) % $n" );
}


for my $i (@issue47) {
  my($n,$P,$Q,$k,$expstr) = @$i;
  is( join(" ",lucasuvmod($P,$Q,$k,$n)), $expstr, "lucasuvmod($P,$Q,$k,$n) = $expstr");
}

{
  my $n = 257;
  my @u1 = map { lucasumod(1,-1,$_,$n) } 0 .. 100;
  my @v1 = map { lucasvmod(1,-1,$_,$n) } 0 .. 100;

  my @u2 = map { modint(lucasu(1,-1,$_),$n) } 0 .. 100;
  my @v2 = map { modint(lucasv(1,-1,$_),$n) } 0 .. 100;

  my @uv1 = map { [lucasuvmod(1,-1,$_,$n)] } 0 .. 100;
  my @uv2 = map { [map { modint($_,$n) } lucasuv(1,-1,$_)] } 0 .. 100;

  is_deeply(\@u1, \@u2, "lucasumod comparison with modint lucasu");
  is_deeply(\@v1, \@v2, "lucasvmod comparison with modint lucasv");
  is_deeply(\@uv1, \@uv2, "lucasuvmod comparison with modint lucasuv");
}

# Arbitrary large inputs
is_deeply( [lucasuvmod("98230984092384092384", "-2938094809238420923423423234", 1777, "398908340943094334094290237")],
           [qw/281234951900970815965553779 286001090644956921206996074/],
           "lucasuvmod with all large bigint inputs" );
is_deeply( [lucasumod("98230984092384092384", "-2938094809238420923423423234", 1777, "398908340943094334094290237")],
           [qw/281234951900970815965553779/],
           "lucasumod with all large bigint inputs" );
is_deeply( [lucasvmod("98230984092384092384", "-2938094809238420923423423234", 1777, "398908340943094334094290237")],
           [qw/286001090644956921206996074/],
           "lucasvmod with all large bigint inputs" );
