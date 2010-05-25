

# = HISTORY SECTION =====================================================================

# ---------------------------------------------------------------------------------------
# version | date     | author   | changes
# ---------------------------------------------------------------------------------------
# 0.09    |14.03.2001| JSTENZEL | added stream processing time report;
#         |          | JSTENZEL | slight code optimizations;
# 0.08    |13.03.2001| JSTENZEL | simplified code slightly;
#         |          | JSTENZEL | added visibility feature to visualize processing;
#         |14.03.2001| JSTENZEL | added mailing list hint to POD;
# 0.07    |07.12.2000| JSTENZEL | new namespace PerlPoint;
# 0.06    |19.11.2000| JSTENZEL | updated POD;
# 0.05    |13.10.2000| JSTENZEL | slight changes;
# 0.04    |30.09.2000| JSTENZEL | updated POD;
# 0.03    |27.05.2000| JSTENZEL | updated POD;
#         |          | JSTENZEL | added $VERSION;
# 0.02    |13.10.1999| JSTENZEL | added real POD;
#         |          | JSTENZEL | constants went out, so I could remove the could to generate
#         |          |          | them at compile time;
# 0.01    |11.10.1999| JSTENZEL | new.
# ---------------------------------------------------------------------------------------

# = POD SECTION =========================================================================

=head1 NAME

B<PerlPoint::Backend> - frame class to transform PerlPoint::Parser output

=head1 VERSION

This manual describes version B<0.09>.

=head1 SYNOPSIS

  # load the module:
  use PerlPoint::Backend;

  # build the backend
  my ($backend)=new PerlPoint::Backend(name=>'synopsis');

  # register handlers
  $backend->register(DIRECTIVE_BLOCK, \&handleBlock);
  $backend->register(DIRECTIVE_COMMENT, \&handleComment);
  $backend->register(DIRECTIVE_DOCUMENT, \&handleDocument);
  $backend->register(DIRECTIVE_HEADLINE, \&handleHeadline);
  $backend->register(DIRECTIVE_POINT, \&handlePoint);
  $backend->register(DIRECTIVE_SIMPLE, \&handleSimple);
  $backend->register(DIRECTIVE_TAG, \&handleTag);
  $backend->register(DIRECTIVE_TEXT, \&handleText);
  $backend->register(DIRECTIVE_VERBATIM, \&handleVerbatim);

  # finally run the backend
  $backend->run(\@streamData);

=head1 DESCRIPTION

After an ASCII text is parsed by an B<PerlPoint::Parser> object, the original text is transformed
into stream data hold in a Perl array. To process this intermediate stream further (mostly
to generate output in a certain document description language), a program has to walk through
the stream and to process its tokens.

Well, B<PerlPoint::Backend> provides a class which encapsulates this walk in objects which deal with
the stream, while the translator programmer is focussed on generating the final representation
of the original text. This is done by registering I<handlers> which will be called when their
target objects are discovered in the intermediate stream.

=head1 METHODS

=cut


# declare package
package PerlPoint::Backend;

# declare version
$VERSION=$VERSION="0.09";

# pragmata
use strict;

# declare class members
use fields qw(
              display
              handler
              name
              statistics
              trace
              vis
             );

# load modules
use Carp;
use PerlPoint::Constants;


=pod

=head2 new()

The constructor builds and prepares a new backend object. You may
have more than one object at a certain time, they work independently.

B<Parameters:>
All parameters except of the I<class> parameter are named (pass them by hash).

=over 4

=item class

The class name.

=item name

Because there can be more than exactly one backend object, your object
should be named. This is not necessarily a need but helpful reading traces. 

=item trace

This parameter is optional. It is intended to activate trace code while the
object methods run. You may pass any of the "TRACE_..." constants declared
in B<PerlPoint::Constants>, combined by addition as in the following example:

  trace => TRACE_NOTHING+TRACE_BACKEND,

In fact, only I<TRACE_NOTHING> and I<TRACE_BACKEND> take effect to backend
objects.

If you omit this parameter or pass TRACE_NOTHING, no traces will be displayed.

=item display

This parameter is optional. It controls the display of runtime messages
like informations or warnings in all object methods. By default, all
messages are displayed. You can suppress these informations partially
or completely by passing one or more of the "DISPLAY_..." variables
declared in B<PerlPoint::Constants>.

Constants can be combined by addition.

=item vispro

activates "process visualization" which simply means that a user will see
progress messages while the backend processes the stream. The I<numerical>
value of this setting determines how often the progress message shall be
updated by a I<chapter interval>:

  # inform every five chapters
  vispro => 5,

Process visualization is automatically suppressed unless STDERR is
connected to a terminal, if this option is omitted, I<display> was set
to C<DISPLAY_NOINFO> or backend I<trace>s are activated.

=back

B<Returns:>
the new object.

B<Example:>

  my ($parser)=new PerlPoint::Backend(name=>'example');

=cut
sub new
 {
  # get parameter
  my ($class, @pars)=@_;

  # build parameter hash
  confess "[BUG] The number of parameters should be even - use named parameters, please.\n" if @pars%2;
  my %pars=@pars;

  # check parameters
  confess "[BUG] Missing class name.\n" unless $class;
  confess "[BUG] Missing name parameter.\n" unless exists $pars{name};

  # build object
  my $me;
  {
   no strict 'refs';
   $me=bless([\%{"$class\::FIELDS"}], $class);
  }

  # init object
  $me->{handler}={};
  $me->{name}=$pars{name};

  # store trace and display settings
  $me->{trace}=defined $pars{trace} ? $pars{trace} : TRACE_NOTHING;
  $me->{display}=defined $pars{display} ? $pars{display} : DISPLAY_ALL;
  $me->{vis}=(
                  defined $pars{vispro} 
              and not $me->{display} & &DISPLAY_NOINFO
              and not $me->{trace}>TRACE_NOTHING
              and -t STDERR
             ) ? $pars{vispro} : 0;

  # reply the new object
  $me;
 }



=pod

=head2 register()

After building a new object by I<new()> the object can be prepared
by calls of the register method.

If the object walks through the data stream generated by B<PerlPoint::Parser>,
it will find several directives. A directive is a data struture flagging
that a certain document part (or even formatting) starts or is completed.
E.g. a headline is represented by headline start directive followed by
tokens for the headline contents followed by a headline completion directive.

By using this method, you can register directive specific functions which
should be called when the related directives are discovered. The idea is
that such a function can produce a target language construct representing
exactly the same document token that is modelled by the directive. E.g. if
your target language is HTML and you register a headline handler and a
headline start is found, this handler can generate a "<HEAD>" tag. This
is quite simple.

According to this design, the object will pass the following data to
a registered function:

=over 4

=item directive

the directive detected, this should be the same the function was
registered for. See B<PerlPoint::Constants> for a list of directives.

=item start/stop flag

The document stream generated by the parser is strictly synchronous.
Everything except of plain strings is represented by an open directive
and a close directive, which may embed other parts of the document.
A headline begins, something is in, then it is complete. It's the
same for every tag or paragraph and even for the whole document.

So well, because of this structure, a handler registered for a certain
directive is called for opening directives as well as for closing
directives. To decide which case is true, a callback receives this
parameter. It's always one of the constants DIRECTIVE_START or
DIRECTIVE_COMPLETED.

For simple strings (words, spaces etc.) and line number hints, the
callback will always be called with DIRECTIVE_START.

=item directive values, if available

Certain directives provide additional data such as the headline level or the
original documents name which are passed to their callbacks additionally.
See the following list:

=over 4

=item Documents

transfer the I<basename> of the original ASCII document being parsed;

=item Headlines

transfer the headline level;

=item Ordered list points

  optionally transfer a fix point number;

=item Tags

transfer the tag name ("I", "B" etc.).

=back

=back

To express this by a prototype, all registered functions should have
an interface of "$$:@".

B<Parameters:>

=over 4

=item object

a backend object as made by I<new()>;

=item directive

the directive this handler is registered for. See B<PerlPoint::Constants> for a
list of directives.

=item handler

the function to be called if a pointed directive is entered while the
I<run()> method walks through the document stream.

=back

B<Returns:>
no certain value;

B<Example:>

  $backend->register(DIRECTIVE_HEADLINE, \&handleHeadline);

where handleHeadline could be something like

  sub handleDocument
   {
    my ($directive, $startStop, $level)=@_;
    confess "Something is wrong\n"
      unless $directive==DIRECTIVE_HEADLINE;
    if ($startStop==DIRECTIVE_START)
      {print "<head$level>";}
    else
      {print "</head>";}
   }


=cut
sub register
 {
  # get and check parameters
  my ($me, $directive, $handler)=@_;
  confess "[BUG] Missing object parameter.\n" unless $me;
  confess "[BUG] Object parameter is no ", __PACKAGE__, " object.\n" unless ref $me and ref $me eq __PACKAGE__;
  confess "[BUG] Missing directive parameter.\n" unless defined $directive;
  confess "[BUG] Invalid directive parameter, use one of the directive constants.\n" unless $directive<=DIRECTIVE_SIMPLE;
  confess "[BUG] Missing handler parameter.\n" unless $handler;
  confess "[BUG] Handler parameter is no code reference.\n" unless ref($handler) and ref($handler) eq 'CODE';

  # check for an already existing handler
  warn "[Trace] Removing earlier handler setting (for directive $directive).\n" if $me->{trace} & TRACE_BACKEND and exists $me->{handler}{$directive};

  # well, all right, store the handler
  $me->{handler}{$directive}=$handler;
  warn "[Trace] Stored new handler (for directive $directive).\n" if $me->{trace} & TRACE_BACKEND;
 }

# the walker
sub run
 {
  # get parameters
  my ($me, $stream)=@_;

  # and check parameters
  confess "[BUG] Missing object parameter.\n" unless $me;
  confess "[BUG] Object parameter is no ", __PACKAGE__, " object.\n" unless ref $me and ref $me eq __PACKAGE__;
  confess "[BUG] Missing stream parameter.\n" unless $stream;
  confess "[BUG] Stream parameter is no array reference.\n" unless ref($stream) and ref($stream) eq 'ARRAY';

  # welcome user
  warn "[Info] Perl Point backend \"$me->{name}\" starts.\n" unless $me->{display} & DISPLAY_NOINFO;

  # declare variables
  my ($tokenNr, $started)=(0, time);

  # init counter
  $me->{statistics}{&DIRECTIVE_HEADLINE}=0;

  # now start your walk
  foreach my $token (@$stream)
    {
     # update token counter
     $tokenNr++;

     # check token type
     unless (ref($token))
       {
        # trace, if necessary
        warn "[Trace] Token $tokenNr is a simple string.\n" if $me->{trace} & TRACE_BACKEND;

        # now check if there was a handler declared
        if (exists $me->{handler}{DIRECTIVE_SIMPLE()})
          {
           # trace, if necessary
           warn "[Trace] Using user defined handler.\n" if $me->{trace} & TRACE_BACKEND;

           # call the handler passing the string
           &{$me->{handler}{DIRECTIVE_SIMPLE()}}(DIRECTIVE_SIMPLE, DIRECTIVE_START, $token);
          }
        else
          {
           # trace, if necessary
           warn "[Trace] Using default handler.\n" if $me->{trace} & TRACE_BACKEND;

           # well, the default is to just print it out
           print $token;
          }
       }
     else
       {
        # trace, if necessary
        warn "[Trace] Token $tokenNr is a directive.\n" if $me->{trace} & TRACE_BACKEND;

        # new headline?
        if ($token->[0]==DIRECTIVE_HEADLINE and $token->[1]==DIRECTIVE_START)
          {
           # update "statistics"
           $me->{statistics}{&DIRECTIVE_HEADLINE}++ if $token->[0]==DIRECTIVE_HEADLINE;

           # let the user know that something is going on
           print STDERR "\r", ' ' x length('[Info] '), '... ', $me->{statistics}{&DIRECTIVE_HEADLINE}, " chapters processed."
             if $me->{vis} and not $me->{statistics}{&DIRECTIVE_HEADLINE} % $me->{vis};
          }

        # now check if there was a handler declared
        if (exists $me->{handler}{$token->[0]})
          {
           # trace, if necessary
           warn "[Trace] Using user defined handler.\n" if $me->{trace} & TRACE_BACKEND;

           # call the handler passing additional informations, if any
           &{$me->{handler}{$token->[0]}}(@$token);
          }
        else
          {
           # trace, if necessary
           warn "[Trace] Acting by default (ignoring token).\n" if $me->{trace} & TRACE_BACKEND;

           # well, the default is to ignore it
          }
       }
    }

  # inform user
  warn(
       ($me->{vis} ? "\n" : ''), "       Stream processed in ", time-$started, " seconds.\n\n",
                                 "[Info] Backend \"$me->{name}\" is ready.\n\n"
      ) unless $me->{display} & DISPLAY_NOINFO;
 }

1;


# = POD TRAILER SECTION =================================================================

=pod

=head1 SEE ALSO

=over 4

=item B<PerlPoint::Parser>

A parser for Perl Point ASCII texts.

=item B<PerlPoint::Constants>

Public PerlPoint::... module constants.

=back


=head1 SUPPORT

A PerlPoint mailing list is set up to discuss usage, ideas,
bugs, suggestions and translator development. To subscribe,
please send an empty message to perlpoint-subscribe@perl.org.

If you prefer, you can contact me via perl@jochen-stenzel.de
as well.

=head1 AUTHOR

Copyright (c) Jochen Stenzel (perl@jochen-stenzel.de), 1999-2001.
All rights reserved.

This module is free software, you can redistribute it and/or modify it
under the terms of the Artistic License distributed with Perl version
5.003 or (at your option) any later version. Please refer to the
Artistic License that came with your Perl distribution for more
details.

The Artistic License should have been included in your distribution of
Perl. It resides in the file named "Artistic" at the top-level of the
Perl source tree (where Perl was downloaded/unpacked - ask your
system administrator if you dont know where this is).  Alternatively,
the current version of the Artistic License distributed with Perl can
be viewed on-line on the World-Wide Web (WWW) from the following URL:
http://www.perl.com/perl/misc/Artistic.html


=head1 DISCLAIMER

This software is distributed in the hope that it will be useful, but
is provided "AS IS" WITHOUT WARRANTY OF ANY KIND, either expressed or
implied, INCLUDING, without limitation, the implied warranties of
MERCHANTABILITY and FITNESS FOR A PARTICULAR PURPOSE.

The ENTIRE RISK as to the quality and performance of the software
IS WITH YOU (the holder of the software).  Should the software prove
defective, YOU ASSUME THE COST OF ALL NECESSARY SERVICING, REPAIR OR
CORRECTION.

IN NO EVENT WILL ANY COPYRIGHT HOLDER OR ANY OTHER PARTY WHO MAY CREATE,
MODIFY, OR DISTRIBUTE THE SOFTWARE BE LIABLE OR RESPONSIBLE TO YOU OR TO
ANY OTHER ENTITY FOR ANY KIND OF DAMAGES (no matter how awful - not even
if they arise from known or unknown flaws in the software).

Please refer to the Artistic License that came with your Perl
distribution for more details.

=cut
