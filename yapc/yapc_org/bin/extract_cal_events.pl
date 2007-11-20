#!/usr/bin/perl
use strict;
use warnings;
use DateTime;
use Getopt::Std;
use Net::Google::Calendar;
use Template;
use XML::Atom::Util 'iso2dt';
use HTML::TextToHTML;

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
        $entry->{description} = get_description($_) || '';
        $entry->{status}      = get_status($_)    || '';
        $entry->{where}       = get_location($_)  || '';
        $entry->{author}      = get_author($_)    || {};
        my $when              = get_when($_)      || {};
        $entry->{start}       = $when->{start}    || '';
        $entry->{end}         = $when->{end}      || '';
	$entry->{gcal_url}    = $_->_generic_url('alternate') || '';
    }
}

my $tt = Template->new(PRE_CHOMP => 1,
		       POST_CHOMP =>1,);
my $template = <<"TT";
[%- BLOCK entry -%]
    <div class="post">
        <h4><a href='[% event.gcal_url %]'>[% event.title %]</a></h4>
        <div class="contentarea">
            <p>
                Where: [% event.where %]
                <br />
                Start: [% event.start %]
                <br />
                End: [% event.end %]
            </p>
            <p>
                Details: [% event.description %]
            </p>
        </div>
    </div>
    <div class="divider2"></div>
[%- END -%]

[%- SET entries = [] -%]

[% FOREACH item = data.keys %]
    [% IF tree %]
        <h3>[% item %]</h3>
    [% END %]
    [% SET subitems = data.\$item.values %]
    [% FOREACH event IN subitems.sort('start') %]
        [% IF tree %]
            [% PROCESS entry %]
        [% ELSE %]
            [% entries.push(event) %]
        [% END %]
    [% END %]
[% END %]

[% UNLESS tree %]
    [% FOREACH event IN entries.sort('start') %]
        [% PROCESS entry %]
    [% END %]
[% END %]
TT

$tt->process(\$template, {data => \%data,
			  tree => $opt{tree}},
	     $opt{f} ? $opt{f} : ())
  or die $tt->error;

sub get_description {
    my ($event) = @_;
    my $conv = new HTML::TextToHTML(explicit_headings => 1,
				   lowercase_tags => 1);
    my $desc = $event->content->body;
    return $conv->process_chunk($desc);
}

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
        $_ = defined($_) ? iso2dt($_) : 'Unknown';
    }

    if( $beg->dmy() eq $end->dmy() ){

      # This is a one day event, so end is correct.
      $beg = $beg->strftime("%Y-%m-%d");
      $end = $end->strftime("%Y-%m-%d");
    }
    else{
      # endTime comes back one day late,
      # so subtrack a day from end.
      $beg = $beg->strftime("%Y-%m-%d");
      $end->subtract( days => 1 );
      $end = $end->strftime("%Y-%m-%d");
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

        -t : To produce output as a (t)ree or flat 
             Format:  0 for flat, 1 for tree
             Default: 0 

        -u : The (u)rl of the calendar to fetch
             Default: Full feed of The Perl Review
    } . "\n";
    getopts('d:e:f:hi:m:s:t:u:', $opt) or die $Usage;
    die $Usage if $opt->{h};
    $opt->{dups}   = $opt->{d} || 0;
    $opt->{tree}   = $opt->{t} || 0;
    $opt->{start}  = get_stamp($opt->{s} || 'now');
    $opt->{end}    = get_stamp($opt->{e} || '2038'); 
    $opt->{url}    = $opt->{u} || 'http://www.google.com/calendar/feeds/ngctmrd1cac35061mrjt3hpgng%40group.calendar.google.com/public/full';
    $opt->{search} = $opt->{i} || 'YAPC|workshop|conference|hackathon|OSCON|OSDC';
    $opt->{max}    = $opt->{m} || 1000;
}
__END__
TODO
1.  Support parsing various different strings for -s and -e
2.  Provide patches and tests to Net::Google::Calendar
3.  Extract and/or linkify links from the description when available
4.  Better documentation - POD and query strings for instance
5.  Provide -o option to change orderby clause (hardcoded to start ascending now)
