
# File: vumeter.pm
# Mark Overmeer, AT Computing bv, The Netherlands
# Example for YAPC::Europe 2001

package vumeter;

# The vumeter combines a lot of vu(-bars).  Each time a new set of
# values is added, the older values are shifted one bar to the
# left.

use vu;
use Tk::Frame;
@ISA = qw(Tk::Frame);

use strict;

# Widget can be part of any composite widget.
Construct Tk::Widget 'vumeter';

# Give all the bars a name.
my $nr_bars  = 20;
my @barnames = map {"bar$_"} 0..$nr_bars-1;

# A mega-widget is a new object, not just an extention.  You have to
# create an InitObject function, although a Populate will do in most
# case.

sub InitObject($$)
{   my ($self, $args) = @_;

    $self->ConfigSpecs
    ( -addValues => [ 'METHOD', '','', [ 0,0,0 ]]
    , DEFAULT    => [ 'DESCENDANTS' ]
    );

    # Create the vu-bars.
    # Creating a component combines the creation and advertising of
    # the widget; just make life a bit easier.

    map {$self->Component('vu', $_, -width => 20)
              ->pack( qw/-side left -fill both/ )
        } @barnames;

    # Do not forget this!
    $self->SUPER::InitObject($args);
}

#
# ADDVALUES
# Called with a reference to a list of new values.  It is not possible
# to give a list with one option, because  -option => 1,2,3  would be
# interpreted as  -option => 1, 2 => 3
# That's why we have to write  -option => [1,2,3]

sub addValues($)
{   my ($self, $newvalues) = @_;  # $values is ref to array with new values.

    #
    # Pass values from each widget to left neighbour.
    #

    my @new = map { $self->Subwidget($_)
                         ->cget('-values') }
                  @barnames;      # get current values-sets for each 'vu'.

    shift @new;                   # remove first set of values.
    push @new, $newvalues;        # add new set at the end.

    map { $self->Subwidget($_)
               ->configure(-values => shift @new) }
        @barnames;                # set new values for each 'vu'

    $self;
}

1;
