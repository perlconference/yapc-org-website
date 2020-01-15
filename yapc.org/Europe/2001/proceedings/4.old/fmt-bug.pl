#!/usr/bin/perl -w

# use strict;

# use diagnostics;

my $e0101 = "Value 1";
my @e = (0, { 101 => $e0101 });

format OLD0 =
@<<<<<<<<<<
$e0101
.

format NEW0 =
@<<<<<<<<<<
$e[1]{101}
.

format NEW0 =
@<<<<<<<<<<
"$e[1]{101}"
.
