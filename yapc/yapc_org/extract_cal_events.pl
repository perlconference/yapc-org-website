#!/usr/bin/perl

use strict;
use warnings;
use Data::Dumper;
use DateTime;
use Getopt::Std;
use Net::Google::Calendar;
use XML::Atom::Util 'iso2dt';

my %opt;
get_args(\%opt);
my (%data, %seen);

my $cal = Net::Google::Calendar->new(url => $opt{url});

# Google Calendar supports OR'd category queries
# Google Calendar supports AND'd search string queries
# Multiple fetches are required for OR'd search string queries
# A different approach would be to pull all events and filter in perl land

for my $item (get_items($opt{search})) {

    for my $event ($cal->get_events('q' => $item, 'start-min' => $opt{datetime})) {

        # Since the same event may be found from different search strings
        # Store only one copy of the meta data but sym link as appropriate
        my $id = $event->id;
        if ($seen{$id}) {
            $data{$item}{$id} = $seen{$id};
        }
        else {
            $data{$item}{$id} = {};
            $seen{$id} = $data{$item}{$id};
        }

        my $entry = $data{$item}{$id};
        $entry->{title}       = $event->title         || 'Unknown Title';
        $entry->{description} = $event->content->body || 'Unknown Description';
        $entry->{status}      = get_status($event)    || 'Unknown Status';
        $entry->{where}       = get_location($event)  || 'Unknown Location';
        $entry->{author}      = get_author($event)    || {};
        $entry->{when}        = get_when($event)      || {};
    }

}

print Dumper(\%data);

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
    my $ns   = XML::Atom::Namespace->new(gd => 'http://schemas.google.com/g/2005');
    my $elem = $event->elem;
    my $node = ($elem->getElementsByTagNameNS($ns->{uri}, 'eventStatus'))[0];
    my $val  = $node->getAttribute('value');
    $val =~ s!^http://schemas.google.com/g/2005#event\.!!;
    return $val;
}

sub get_location {
    my ($event) = @_;
    my $ns   = XML::Atom::Namespace->new(gd => 'http://schemas.google.com/g/2005');
    my $elem = $event->elem;
    my $node = ($elem->getElementsByTagNameNS($ns->{uri}, 'where'))[0];
    my $val  = $node->getAttribute('valueString');
    return $val;
}

sub get_when {
    my ($event) = @_;
    my $ns   = XML::Atom::Namespace->new(gd => 'http://schemas.google.com/g/2005');
    my $elem = $event->elem;
    my $node = ($elem->getElementsByTagNameNS($ns->{uri}, 'when'))[0];
    my $beg  = $node->getAttribute('startTime');
    my $end  = $node->getAttribute('endTime');
    for ($beg, $end) {
        $_ = defined($_) ? iso2dt($_)->strftime("%Y-%m-%d") : 'Unknown';
    }
    return {start => $beg, end => $end};
}

sub get_items {
    my ($search_string) = @_;
    return grep {defined($_) && length($_)} split /\|/, $search_string;
}

sub get_args {
    my ($opt) = @_;
    my $Usage = qq{Usage: $0 [options]
        -h : This help message

        -u : The (u)rl of the calendar to fetch
             Default: Full feed of The Perl Review

        -s : The date/time (s)tamp of when to fetch from
             Format:  RFC 3339. For example: 2005-08-09T10:57:00-08:00
             Default: now

        -i : The (i)tems to query
             Format:  'item1|item2|item3'
             Default: 'YAPC|workshop|conference|hackathon'

    } . "\n";
    getopts('hu:s:', $opt) or die $Usage;
    die $Usage if $opt->{h};
    $opt->{datetime} = $opt->{s} || DateTime->now();
    $opt->{url}      = $opt->{u} || 'http://www.google.com/calendar/feeds/ngctmrd1cac35061mrjt3hpgng%40group.calendar.google.com/public/full';
    $opt->{search}   = $opt->{i} || 'YAPC|workshop|conference|hackathon'
}
__END__
TODO
1.  Support parsing various different strings for -s
2.  Support advanced query items '(item1&item2)|item3'
3.  Provide patches to Net::Google::Calendar
4.  Provide more better tests to Net::Google::Calender (use test only)
5.  Extract links from the description when available
6.  Use Template for the output
