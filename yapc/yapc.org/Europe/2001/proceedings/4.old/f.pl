#!/pro/bin/perl -w
my %e = ( a => 1 );
write;
format STDOUT =
@<<<<
$e{a}
.
#"$e{a}"
