## LPE sort00x_____!O-Es18!	Geslachtstellingen

# %W%	[%E%]

format TOP =
.

push @fnc, "A01";
sub A01
{
    $cnt_sex{$e180050}++;
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
