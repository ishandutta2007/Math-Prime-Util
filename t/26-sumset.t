#!/usr/bin/env perl
use strict;
use warnings;

use Test::More;
use Math::Prime::Util qw/sumset setbinop addint/;

plan tests => 14+17+1;

###### sumset
my $pr200 = [qw/2 3 5 7 11 13 17 19 23 29 31 37 41 43 47 53 59 61 67 71 73 79 83 89 97 101 103 107 109 113 127 131 137 139 149 151 157 163 167 173 179 181 191 193 197 199/];
my $sumset_pr200 = [qw/4 5 6 7 8 9 10 12 13 14 15 16 18 19 20 21 22 24 25 26 28 30 31 32 33 34 36 38 39 40 42 43 44 45 46 48 49 50 52 54 55 56 58 60 61 62 63 64 66 68 69 70 72 73 74 75 76 78 80 81 82 84 85 86 88 90 91 92 94 96 98 99 100 102 103 104 105 106 108 109 110 111 112 114 115 116 118 120 122 124 126 128 129 130 132 133 134 136 138 139 140 141 142 144 146 148 150 151 152 153 154 156 158 159 160 162 164 165 166 168 169 170 172 174 175 176 178 180 181 182 183 184 186 188 190 192 193 194 195 196 198 199 200 201 202 204 206 208 210 212 214 216 218 220 222 224 226 228 230 232 234 236 238 240 242 244 246 248 250 252 254 256 258 260 262 264 266 268 270 272 274 276 278 280 282 284 286 288 290 292 294 296 298 300 302 304 306 308 310 312 314 316 318 320 322 324 326 328 330 332 334 336 338 340 342 344 346 348 350 352 354 356 358 360 362 364 366 370 372 374 376 378 380 382 384 386 388 390 392 394 396 398/];

is_deeply([sumset($pr200)],$sumset_pr200,"sumset of primes under 200");
{ my $s = sumset($pr200); is($s,scalar(@$sumset_pr200),"scalar sumset of primes uder 200"); }

is_deeply([sumset [2,4,6,8],[3,5,7]], [5,7,9,11,13,15], "sumset([2,4,6,8],[3,5,7])");
is_deeply([sumset [1,2,3]], [2,3,4,5,6], "sumset([1,2,3])");
is_deeply([sumset [1,2,3],[2,3,4]], [3,4,5,6,7], "sumset([1,2,3],[2,3,4])");
is_deeply([sumset([1],[2])], [3], "sumset([1],[2])");
is_deeply([sumset([1],[])], [], "sumset([1],[])");
is_deeply([sumset([],[2])], [], "sumset([],[2])");

is_deeply([sumset([map {2*$_} 1..10])], [4,6,8,10,12,14,16,18,20,22,24,26,28,30,32,34,36,38,40], "sumset of evens 2-20");
{ my $s = sumset([map {2*$_} 1..10]); is($s,19,"sumset of evens 2-20 makes only 19 entries"); }
is_deeply([sumset([map {3*$_} 1..10])], [6,9,12,15,18,21,24,27,30,33,36,39,42,45,48,51,54,57,60], "sumset of 3x x=1..10");
{ my $s = sumset([map {1<<$_} 1..10]); is($s,55,"sumset of powers of 2 1..10 has 55 entries"); }

is_deeply([sumset([0,3,7,12],[2,4,11,14])], [2,4,5,7,9,11,14,16,17,18,21,23,26], "sumset of two sets");

# from Granville and Roesler
{
  my @s = grep { /^[124]{2}$/ } 1..99;
  #my $s = sumset(\@s);
  is(scalar(sumset(\@s)), 36, "[124]{2} has 3^2 elements, A+A has 6^2 elements");
  # A-A should have 7^2 elements
}

# Specific combination tests
testsumset([1,2],[3,4], "sumset ANY ANY ok");
testsumset([1,2],[3,4,"18446744073709551615"], "sumset ANY POS overflow");
testsumset([1,2],[3,4,"18446744073709551605"], "sumset ANY POS ok");
testsumset([1,2,"18446744073709551615"],[3,4], "sumset POS ANY overflow");
testsumset([1,2,"18446744073709551605"],[3,4], "sumset POS ANY ok");
testsumset([1,2,"9223372036854775808"],[3,4,"9223372036854775808"], "sumset POS POS overflow");

testsumset([-1,"4611686018427387904"], [3,"9911686018427387905"], "sumset NEG POS overflow");
testsumset([-100,-99], ["9223372036854775808","9223372036854775809"], "sumset NEG POS with sumset ANY");
testsumset([-1,1], [3,"9911686018427387905"], "sumset NEG POS with sumset POS");

testsumset([-1,"4611686018427387904"], [3,"4611686018427387905"], "sumset NEG ANY overflow");
testsumset([-1,"4611686018427387904"], [-3,"4611686018427387905"], "sumset NEG NEG overflow");
testsumset([1,2,"-4611686018427387904"], [3,4,"-4611686018427387904"], "sumset NEG NEG ok");
testsumset([1,2,"-4611686018427387905"], [3,4,"-4611686018427387905"], "sumset NEG NEG undeflow");
testsumset([-1,2], [3,4], "sumset NEG ANY with sumset ANY");
testsumset([-6,2], [3,4], "sumset NEG ANY with sumset NEG");
testsumset([-6,2], [-3,4], "sumset NEG NEG with sumset NEG");
testsumset([-6,-2], [-4,-3], "sumset NEG NEG with sumset NEG");

# bigint
is_deeply( [sumset([1,2],[3,4,"73786976294838206464"])],
           [qw/4 5 6 73786976294838206465 73786976294838206466/],
           "sumset with bigint element" );

sub testsumset {
  my($ra, $rb, $name) = @_;

  my @sumset1 = sumset($ra,$rb);
  my @sumset2 = setbinop { addint($a,$b) } $ra, $rb;
  is_deeply(\@sumset1, \@sumset2, $name);
}

