## LPE sort02______!O-s18 -e0x510!	Etiketten met minimale leerlinggevens

## Example for AVERY Laser L7160 63.5 x 38.1 (7 x 3) op12 ol8
## Instelling printer: top = 0, bodem = 0, links = 0, regel = 300
##                     pagina = 85, cmd = lp -s -op12 -ol8 -onolm -odiac

# %W%	[%E%]

use PROCURA::Diac;

format TOP =
.

$l_def = "L7160-8";

		#    +-------------------------- aantal etiketten naast elkaar
		#    |  +----------------------- aantal etiketten onder elkaar
		#    |  |   +------------------- karakters per etiket
		#    |  |   |   +--------------- regels per etiket
		#    |  |   |   |  +------------ top marge
		#    |  |   |   |  |  +--------- linker marge
		#    |  |   |   |  |  |  +------ marge tussen labels
		#    |  |   |   |  |  |  |  +--- extra newline tussen tekst
%l_defs = (	#    |  |   |   |  |  |  |  |
    "L7160-8"	=> [ 3, 7, 27, 12, 3, 2, 4, 1],	# AVERY L7160 12 cpi, 8 lpi
    "L7160-6"	=> [ 3, 7, 38,  9, 3, 3, 5, 0],	# AVERY L7160 17 cpi, 6 lpi
    "L7163-8"	=> [ 2, 7, 43, 12, 3, 2, 4, 1],	# AVERY L7163 12 cpi, 8 lpi
    "L7163-6"	=> [ 2, 7, 60,  9, 3, 3, 8, 0],	# AVERY L7163 12 cpi, 6 lpi
    "HERMA-2x7"	=> [ 2, 7, 43, 13, 0, 2, 6, 1],	# HERMA 7 x 2 12 cpi, 8 lpi
						# LET OP: Het kleine randje moet
    						#	  aan de onderkant!
    "Custom"	=> [ 1, 1,  1,  1, 1, 1, 1, 0]
    );

my ($H_eti, $V_eti, $w_eti, $h_eti, $v_eti, $o_eti, $m_eti, $l_eti) =
    @{$l_defs{$l_def}};

my $x_eti =  0;
my $n_eti = $H_eti * $V_eti;
my @l_arr = ();
my $l_sep = " " x $m_eti;
my $l_off = " " x $o_eti;
my $l_end = $l_eti ? "\n" : "";
my $adovv = $fmt =~ m/_009/ ? 1 : 0;

push @fnc, "A01";
sub A01
{
    $l_arr[$x_eti++] = join "\n",
	" " x ($w_eti - 10) . $e180041,
	diac_substr ($e180012, 0, $w_eti),
	diac_substr ($e180152, 0, $w_eti),
	diac_substr ($e180212, 0, $w_eti);
    } # A01

my @adovv =
    (diac_substr ("Aan de ouder(s)/verzorger(s) van", 0, $w_eti)) x $H_eti;

sub print_labels
{
    my @l1, @l2, @l3, @l4, $sp;

    print "\n" x $v_eti;
    $- -= $v_eti;
    while (@l_arr > 0) {
	@l1 = @l2 = @l3 = @l4 = ();
	foreach my $l (1 .. $H_eti) {
	    my @l = split m/\n/, shift @l_arr;
	    push @l1, shift @l;
	    push @l2, shift @l;
	    push @l3, shift @l;
	    push @l4, shift @l;
	    }
	print $l_off, join ($l_sep, $adovv ? @adovv : @l1), "$l_end\n";
	print $l_off, join ($l_sep, @l2), "$l_end\n";
	print $l_off, join ($l_sep, @l3), "$l_end\n";
	print $l_off, join ($l_sep, @l4), "\n";
	print @l_arr == 0 ? "\f" : "\n" x ($h_eti - 4 - 3 x length $l_end);
	$- -= $h_eti;
	}
    } # print_labels

push @fnc, "EOR";
sub EOR
{
    $x_eti < $n_eti && return;
    print_labels ();
    $x_eti = 0;
    } # EOR

sub EOF
{
    print_labels ();
    } # EOF

push @fmt, "EOF";
format EOF =
.
