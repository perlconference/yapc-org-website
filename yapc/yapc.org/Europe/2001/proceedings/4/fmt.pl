#!/usr/bin/perl -w

use strict;

my ($e010101, $e020202) = ("Value 1", "Value 2");
my @e;

$e[1][101] = $e010101;
$e[2]{202} = $e020202;
sub e { $e[2]{$_[0]} };

my %test = qw(
    a_PLAIN $e010101
    b_ARRAY $e[1][101]
    c_HASH  $e[2]{202}
    d_CAT   $e[1][101]."\54\40".$e[2]{202}
    e_FUNC  e(202)
    f_IPOLP "$e010101"
    g_IPOLA "$e[1][101]"
    h_IPOLH "$e[1]{101}"
    i_IPOLF "@{[e(202)]}"
    m_SQ    'x'
    n_SQA   '[x]'
    o_SQH   '{x}'
    p_DQ    "x"
    q_DQA   "[x]"
    r_DQH   "{x}"
    s_SQV   '$test{m_SQ}'
    t_DQV   "$test{m_DQ}"
    u_QQV   qq/$test{m_DQ}/
    v_QV    q/$test{m_DQ}/
    );
foreach (sort keys %test) {
    $~ = $_;
    printf "%-10s", $_;
#   print "format $_ =\n\@<<<<<<<<<<<<<<<<<\n$test{$_}\n.\n";
    eval  "format $_ =\n\@<<<<<<<<<<<<<<<<<\n$test{$_}\n.\n";
    $@ or write, next;
    print $@;
    }
