## LPE sort00x_____!O-Es1!	Geslachtstellingen

# @(#)lp_000.pl	3.2	[01/05/23]

push @fnc, "A01";
sub A01
{
    $cnt_sex{$e[1]{410}}++;
    } # A01

push @fmt, "EOF";
format EOF =
Aantal mannen   :@######
               $cnt_sex{"M"}
       vrouwen  :@######
               $cnt_sex{"V"}
       onbekend :@######
               $cnt_sex{"O"}
.

1;
