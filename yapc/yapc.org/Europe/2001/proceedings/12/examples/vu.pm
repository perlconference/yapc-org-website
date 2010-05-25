
# File: vu.pm
# Mark Overmeer, AT Computing bv, The Netherlands
# Example for YAPC::Europe 2001

package vu;

# Implementation of an object which displays a set of values on a
# bar, just like the row of leds on a tuner.

use Tk::Derived;
use Tk::Canvas;

# vu can be parented by any widget, for instance $mw->vu()
Construct Tk::Widget 'vu';

# vu is a specialization of a canvas-object.  The Tk::Derived inheritance
# is an obligatory first entry in the @ISA, because it has to overrule
# some functionality of the super-class.
@ISA = qw(Tk::Derived Tk::Canvas);

use strict;

# Populate is called when the object is initialized (called by
# InitObject)  $args is a ref to hash with the user's options.

sub Populate($$)
{   my ($self, $args) = @_;

    # The ConfigSpecs (man Tk::configspec) are overruled by the user's
    # options on creation of the object.  After Initiation, Tk will call
    # all methods with the default or overruled value.

    # Format:
    # -option => [ kind,      dbName,    dbClass,    default                ]
    #     dbName and dbClass are used to find defaults from X11's resources.

    $self->ConfigSpecs
    ( -colors => [ 'PASSIVE', 'vuColors','VuColors', [ qw(red blue green) ] ]
    , -values => [ 'METHOD',  '',        '',         [ 0,0,0 ]              ]
    , -maxsum => [ 'PASSIVE', 'maxSum',  'MaxSum',   100                    ]
    );

    # Also the superclass must be populated.  Do not forget!
    $self->SUPER::Populate($args);
}

sub values($)
{   my $self   = shift;
    my $values = shift;

    # $w->cget() call to get the values? [ otherwise $w->configure() ]
    # Cannot call cget() here myself: endless recursion... Happily, the
    # internal structures are well-defined and within reach.

    return $self->{Configure}{-values}   # cget() call
        unless $values;

    my @values = @$values;               # configure() call

    # Some difficulties before the window is realized: don't know what
    # size we will have on the screen.  Ignoring value update is without
    # problems in this case.

    my ($width, $height) = ($self->width, $self->height);
    return if $width == 1;               # not realized yet.

    # Use cget() within the widget for its own specs when possible to
    # facilitate extention of the object itself, later.

    my @colors = @{$self->cget('-colors')};
    die @values." colors required, by only have ".@colors.".\n"
        if @values > @colors;

    # To make vspace and hspace configurable is left as excercise.

    my ($vspace, $hspace) = (5,5);
    my $scale  = ($height-$vspace-$vspace) / $self->cget('-maxsum');
    my $y      = $height - $vspace;      # draw bottom-up.

    $self->delete('all');                # remove current bar.

    # Draw each value as a rectangle, just next to the previous
    # rectangle.

    foreach (@values)
    {   my $color     = shift @colors;
        my $barheight = int($_ * $scale) || 1;

        $self->createRectangle
           ( $hspace,$y-$barheight, $width-$hspace,$y
           , -fill => $color
           );
        $y -= $barheight;
    }

    $self;
}

1;
