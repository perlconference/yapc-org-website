#!/pro/bin/perl

# Replaces RPT for generating reports from lpe output
#
# lpepl format-file [page-length [top-margin [bottom-margin [left-margin]]]]
#
#	lpe 1 | lpepl lp_102.pl
#	lpe -Es1 xx.L | lpepl lp_000
#
# Called from lperpt, which is the default user interface

# %W%	[%E%]

use strict;

format BLAH =
Blah
.

sub has_format ($)
{
    my $fmt = shift;
    exists $::{$fmt} or return 0;
    $^O eq "MSWin32" or return defined *{$::{$fmt}}{FORMAT};
    open my $null, "> /dev/null" or die;
    my $fh = select $null;
    local $~ = $fmt;
    eval "write";
    select $fh;
    $@?0:1;
    } # has_format

if (has_format ("BLAH")) {
    local $~ = "BLAH";
    write;
    }
