#!/usr/bin/perl
use strict;
use warnings;
use DateTime;
use Getopt::Std;
use Net::Google::Calendar;
use Template;
use XML::Atom::Util 'iso2dt';

my %opt;
get_args(\%opt);
my (%data, %seen);
my $cal = Net::Google::Calendar->new(url => $opt{url});
for my $item (get_items($opt{search})) {
    my @event = $cal->get_events(
        'q'         => $item,       'max-results' => $opt{max},
        'start-min' => $opt{start}, 'start-max'   => $opt{end}
    );
    for (@event) {
        my $id = $_->id;
        if ($seen{$id}) {
            $data{$item}{$id} = $seen{$id} if $opt{dups};
            next;
        }
        $seen{$id} = $data{$item}{$id} = {};
        my $entry  = $seen{$id};
        $entry->{title}       = $_->title         || '';
        $entry->{description} = $_->content->body || '';
        $entry->{status}      = get_status($_)    || '';
        $entry->{where}       = get_location($_)  || '';
        $entry->{author}      = get_author($_)    || {};
        $entry->{when}        = get_when($_)      || {};
    }
}

my $tt = Template->new();
my $template = <<"TT";
<html>
<head><title>The Perl Review: Community Events Calendar</title></head>
<body>
<h1>The Perl Review: Community Events Calendar</h1>
[% FOREACH item = data.keys %]
    <h3>[% item %]</h3>
    [% FOREACH id = data.\$item.keys %]
       [% SET event = data.\$item.\$id %]
       <p>
       <b>Title:</b> [% event.title %]
       <br /> 
       <b>Description:</b> [% event.description %]
       <br /> 
       <b>Status:</b> [% event.status %]
       <br /> 
       <b>Where:</b> [% event.where %]
       <br /> 
       <b>Start:</b> [% event.when.start %]
       <br /> 
       <b>End:</b> [% event.when.end %]
       <br /> 
       <b>Author:</b> [% event.author.name %]
       </p>
    [% END %]
[% END %]
</body>
</html>
TT
 
$tt->process(\$template, {data => \%data}, $opt{f} ? $opt{f} : ()) or die $tt->error;

sub get_author {
    my ($event) = @_;
    my $author = $event->author;
    my $name   = $author->name     || 'Unknown';
    my $email  = $author->email    || 'Unknown';
    my $weburl = $author->homepage || 'Unknown';
    return {name => $name, email => $email, homepage => $weburl};
}

sub get_status {
    my ($event) = @_;
    my $node = get_node($event, 'eventStatus');
    my $val  = $node->getAttribute('value');
    $val =~ s'^http://schemas.google.com/g/2005#event\.'';
    return $val;
}

sub get_location {
    my ($event) = @_;
    my $node = get_node($event, 'where');
    return $node->getAttribute('valueString');
}

sub get_when {
    my ($event) = @_;
    my $node = get_node($event, 'when');
    my $beg  = $node->getAttribute('startTime');
    my $end  = $node->getAttribute('endTime');
    for ($beg, $end) {
        $_ = defined($_) ? iso2dt($_)->strftime("%Y-%m-%d") : 'Unknown';
    }
    return {start => $beg, end => $end};
}

sub get_node {
    my ($event, $node) = @_;
    my $ns   = XML::Atom::Namespace->new(gd => 'http://schemas.google.com/g/2005');
    my $elem = $event->elem;
    return ($elem->getElementsByTagNameNS($ns->{uri}, $node))[0];
}

sub get_items {
    my ($search_string) = @_;
    return grep {defined($_) && length($_)} split /\|/, $search_string;
}

sub get_stamp {
    my ($stamp) = @_;
    return '1970-01-01T00:00:00-00:00' if $stamp eq 'epoch';
    return DateTime->now               if $stamp eq 'now';
    return '2038-01-19T03:14:07-00:00' if $stamp eq '2038';
    return $stamp;
}

sub get_args {
    my ($opt) = @_;
    my $Usage = qq{Usage: $0 [options]
        -d : What to do with (d)uplicates
             Format:  0 for exclude, 1 for include
             Default: 0

        -e : The date-time stamp to (e)nd fetching
             Format:
                 epoch (shortcut for 1970-01-01T00:00:00-00:00)
                 now   (shortcut for appropriately formatted localtime)
                 2038  (shortcut for 2038-01-19T03:14:07-00:00)
                 YYYY-MM-DDTHH:MM:SS-HH:MM (see RFC 3339 for details)
             Default: 2038

        -f : The (f)ile to output to
             Default: STDOUT

        -h : This help message

        -i : The (i)tems to query
             Format:  'item1|item2|item3'
             Default: 'YAPC|workshop|conference|hackathon'

        -m : The (m)aximum number of results to fetch 
             Default: 1000 

        -s : The date-time stamp to (s)tart fetching from
             Format:
                 epoch (shortcut for 1970-01-01T00:00:00-00:00)
                 now   (shortcut for appropriately formatted localtime)
                 2038  (shortcut for 2038-01-19T03:14:07-00:00)
                 YYYY-MM-DDTHH:MM:SS-HH:MM (see RFC 3339 for details)
             Default: now

        -u : The (u)rl of the calendar to fetch
             Default: Full feed of The Perl Review
    } . "\n";
    getopts('d:e:f:hi:m:s:u:', $opt) or die $Usage;
    die $Usage if $opt->{h};
    $opt->{dups}   = $opt->{d} || 0;
    $opt->{start}  = get_stamp($opt->{s} || 'now');
    $opt->{end}    = get_stamp($opt->{e} || '2038'); 
    $opt->{url}    = $opt->{u} || 'http://www.google.com/calendar/feeds/ngctmrd1cac35061mrjt3hpgng%40group.calendar.google.com/public/full';
    $opt->{search} = $opt->{i} || 'YAPC|workshop|conference|hackathon';
    $opt->{max}    = $opt->{m} || 1000;
}
__END__
TODO
1.  Support parsing various different strings for -s and -e
2.  Provide patches and tests to Net::Google::Calendar
3.  Extract and/or linkify links from the description when available
4.  Better documentation - POD and query strings for instance
