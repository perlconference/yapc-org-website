## LPE sort02______!O-s1 -e0x510!	Etiketten met minimale leerlinggevens

## Example for AVERY Laser L7160 63.5 x 38.1 (7 x 3) op12 ol8
## Instelling printer: top = 0, bodem = 0, links = 0, regel = 300
##                     pagina = 85, cmd = lp -s -op12 -ol8 -onolm -odiac

# @(#)lp_005.pl	3.2	[01/05/23]

use PROCURA::Diac;
use PROCURA::SQL;

		#    +-------------------------- aantal etiketten naast elkaar
		#    |  +----------------------- aantal etiketten onder elkaar
		#    |  |                        1 indicates stream (ketting)
		#    |  |   +------------------- karakters per etiket
		#    |  |   |   +--------------- regels per etiket
		#    |  |   |   |  +------------ top marge
		#    |  |   |   |  |  +--------- linker marge
		#    |  |   |   |  |  |  +------ marge tussen labels (horiz.)
		#    |  |   |   |  |  |  |  +--- extra newline tussen tekst
my %l_def = (	#    |  |   |   |  |  |  |  |
    "L7160-8"	=> [ 3, 7, 27, 12, 3, 2, 4, 1],	# AVERY L7160 12 cpi, 8 lpi
    "L7160-6"	=> [ 3, 7, 38,  9, 3, 3, 5, 0],	# AVERY L7160 17 cpi, 6 lpi
    "L7163-8"	=> [ 2, 7, 43, 12, 3, 2, 4, 1],	# AVERY L7163 12 cpi, 8 lpi
    "L7163-6"	=> [ 2, 7, 60,  9, 3, 3, 8, 0],	# AVERY L7163 17 cpi, 6 lpi
    "HERMA-2x7"	=> [ 2, 7, 43, 13, 0, 2, 6, 1],	# HERMA 7 x 2 12 cpi, 8 lpi
						# LET OP: Het kleine randje moet
    						#	  aan de onderkant!
    "K-2x37x15"	=> [ 2, 1, 33,  8, 1, 2, 4, 0],	# Ketting 2 x 3.7 x 1½ inch
    );
#                    A  B   C   D  E  F  G  H
#
# |<-F-><-------C------><-G-><-----C----  # C + G = Afstand etiketranden in CPI
# |    +----------------+   +---------
# |    |                |   |       ^
# |    |                |   |       |
# |    |                |   |       D
# |    |                |   |       |
# |    |                |   |       v
# |    +----------------+   +--------^
# |                                  E    # D + E = Afstand etiketranden in LPI
# |    +----------------+   +--------v
# |    |                |   |
# |    |

# Select what label type
#	lperpt [-e<label>]
#	 1  <label> = numeric:	set LabelType to
#				    select omschr
#				    from   parm
#				    where  parm = 'label*' and
#					   waarde = <label>
#	 2  <label> = string:	set LabelType to
#				    select omschr
#				    from   parm
#				    where  parm = 'label*' and
#					   omschr like <label>
#	 3  <label> = pattern:	set LabelType to
#				    select key
#				    from   available-types
#				    where  key like <label>
#	 4  			set LabelType to
#				    select omschr
#				    from   parm
#				    where  parm = 'label*' and
#					   min (waarde)
#	 5			set LabelType to "L7163-6"
my $opt_e = $ENV{OPT_E};
defined $opt_e and print STDERR "Try to honour -e$opt_e to format script\n";
foreach (local_sql ("select   parm, waarde, omschr",
		    "from     parm",
		    "order by waarde")) {
    m/^label/i	or next;
    chomp;
    my ($parm, $waarde, $oms) = split m/\s*\|\s*/;
    if (!defined $opt_e or
	($opt_e =~ m/^\d+$/ ? $waarde == $opt_e : $oms =~ m/$opt_e/i)) {
	($l_def = $oms) =~ s/\s.*//;			# Enable comment
	last;
	}
    }
$opt_e ne "" and !defined $l_def and $l_def = (grep m/$opt_e/i, keys %l_def)[0];
exists $l_def{$l_def} or $l_def = "L7163-6";	# Last resort
print STDERR "Label type: $l_def\n";

my ($H_eti, $V_eti, $w_eti, $h_eti, $v_eti, $o_eti, $m_eti, $l_eti) =
    @{$l_def{$l_def}};

my $x_eti =  0;
my $n_eti = $H_eti * $V_eti;
my @l_arr = ();
my $l_sep = " " x $m_eti;
my $l_off = " " x $o_eti;
my $l_end = $l_eti ? "\n" : "";

# Aan de ouders ...
my $adovv = $fmt =~ m/_009/ ? 1 : 0;
my $adovs = $adovv			# Blank line after adovv
    ? $ENV{C_GEM} == 392
	? "\n"
	: ""
    : "";
my @adovv =
    (diac_substr ("Aan de ouder(s)/verzorger(s) van", 0, $w_eti)) x $H_eti;

push @fnc, "A01";
sub A01
{
    $ENV{C_GEM} == 392 and $adovv and $e[1]{1025} .= "      $e[1]{311}";

    $l_arr[$x_eti++] = join "\n",
	" " x ($w_eti - 10) . $e[1]{311} . $adovs,
	diac_substr ($e[1]{200},  0, $w_eti),
	diac_substr ($e[1]{1100}, 0, $w_eti),
	diac_substr ($e[1]{1025}, 0, $w_eti),
	"",
	"";
    } # A01

sub print_labels
{
    my @l1, @l2, @l3, @l4, @l5, $sp;

    print "\n" x $v_eti;
    $- -= $v_eti;
    while (@l_arr > 0) {
	@l1 = @l2 = @l3 = @l4 = @l5 = ();
	foreach my $l (1 .. $H_eti) {
	    my @l = split m/\n/, shift @l_arr;
	    push @l1, shift @l;
	    push @l2, shift @l;
	    push @l3, shift @l;
	    push @l4, shift @l;
	    push @l5, shift @l;
	    }
	print $l_off, join ($l_sep, $adovv ? @adovv : @l1), "$l_end\n";
	print $l_off, join ($l_sep, @l2), "$l_end\n";
	print $l_off, join ($l_sep, @l3), "$l_end\n";
	print $l_off, join ($l_sep, @l4), "$l_end\n";
	print $l_off, join ($l_sep, @l5), "\n";
	print @l_arr == 0  && $V_eti > 1
	    ? "\f"
	    : "\n" x ($h_eti - 5 - 4 x length $l_end);
	$- -= $h_eti;
	}
    } # print_labels

push @fnc, "EOR";
sub EOR
{
    $x_eti < $n_eti and return;
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
