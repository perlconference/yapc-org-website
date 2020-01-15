

# = HISTORY SECTION =====================================================================

# ---------------------------------------------------------------------------------------
# version | date     | author   | changes
# ---------------------------------------------------------------------------------------
# 0.01    |19.03.2001| JSTENZEL | new.
# ---------------------------------------------------------------------------------------

# = POD SECTION =========================================================================

=head1 NAME

B<PerlPoint::Tags::Basic> - declares basic PerlPoint tags

=head1 VERSION

This manual describes version B<0.01>.

=head1 SYNOPSIS

  # declare basic tags
  use PerlPoint::Tags::Basic;

=head1 DESCRIPTION

This module declares several basic PerlPoint tags. Tag declarations
are used by the parser to determine if a used tag is valid, if it needs
options, if it needs a body and so on. Please see
\B<PerlPoint::Tags> for a detailed description of tag declaration.

Every PerlPoint translator willing to handle the tags of this module
can declare this by using the module in the scope where it built the
parser object.

  # declare basic tags
  use PerlPoint::Tags::Basic;

  # load parser module
  use PerlPoint::Parser;

  ...

  # build parser
  my $parser=new PerlPoint::Parser(...);

  ...

It is also possible to select certain declarations.

  # declare basic tags
  use PerlPoint::Tags::Basic qw(I C);


A set name is provided as well to declare all the flags at once.

  # declare basic tags
  use PerlPoint::Tags::Basic qw(:basic);


=head1 TAGS

=over 4

=item B

Marks text as I<bold>. No options, but a mandatory tag body.

=item C

Marks text as I<code>. No options, but a mandatory tag body.

=item I

Marks text as I<italic>. No options, but a mandatory tag body.

=item IMAGE

includes an I<image>. No tag body, but a mandatory option "src" to pass
the image file, and an optional option "alt" to store text alternatively
to be displayed. The option set is open - there can be more options
but they will not be checked by the parser.

The image source file name will be supplied I<absolutely> in the stream.

=item READY

declares the document to be read completely. No options, no body. Works
instantly. Not even the current paragraph will become part of the result.
I<This tag is still experimental, and its behaviour may change in future versions.>
It is suggested to use it in a single text paragraph, usually embedded
into conditions.

  ? ready

C<>

  \READY

C<>

  ? 1

=back

=head1 TAG SETS

There is only one set "basic" including all the tags.

=cut


# check perl version
require 5.00503;

# = PACKAGE SECTION (internal helper package) ==========================================

# declare package
package PerlPoint::Tags::Basic;

# declare package version (as a STRING!!)
$VERSION="0.01";

# declare base "class"
use base qw(PerlPoint::Tags);


# = PRAGMA SECTION =======================================================================

# set pragmata
use strict;
use vars qw(%tags %sets);

# = LIBRARY SECTION ======================================================================

# load modules
use File::Basename;
use Cwd qw(cwd abs_path);
use PerlPoint::Constants 0.14 qw(:parsing :tags);


# = CODE SECTION =========================================================================

%tags=(
       # base fomatting tags: no options, mandatory body
       B     => {body => TAGS_MANDATORY,},
       C     => {body => TAGS_MANDATORY,},
       I     => {body => TAGS_MANDATORY,},

       # image: no body, but several mandatory options
       IMAGE => {
                 # mandatory options
                 options => TAGS_MANDATORY,

                 # no body required
                 body    => TAGS_DISABLED,

                 # hook!
                 hook    => sub
                             {
                              # declare and init variable
                              my $ok=PARSING_OK;

                              # take parameters
                              my ($tagLine, $options)=@_;

                              # check them
                              $ok=PARSING_FAILED, warn qq(\n\n[Error] Missing "src" option in IMAGE tag, line $tagLine.\n) unless exists $options->{src};
                              $ok=PARSING_ERROR,  warn qq(\n\n[Error] Image file "$options->{src}" does not exist or is no file in IMAGE tag, line $tagLine.\n) if $ok==PARSING_OK and not (-e $options->{src} and not -d _);

                              # add current path to options, if necessary (deprecated)
                              $options->{__loaderpath__}=cwd() if $ok==PARSING_OK;

                              # absolutify the image source path (should work on UNIX and DOS, but other systems?)
                              my ($base, $path, $type)=fileparse($options->{src});
                              $options->{src}=join('/', abs_path($path), basename($options->{src})) if $ok==PARSING_OK;

                              # supply status
                              $ok;
                             },
                },

       # declare document to be complete
       READY => {
                 # no options required
                 options => TAGS_DISABLED,

                 # no body required
                 body    => TAGS_DISABLED,

                 # hook!
                 hook    => sub
                             {
                              # flag that parsing is completed
                              PARSING_COMPLETED;
                             },
                },

      );


%sets=(
       basic => [qw(B C I IMAGE READY)],
      );


1;


# = POD TRAILER SECTION =================================================================

=pod

=head1 SEE ALSO

=over 4

=item B<PerlPoint::Tags>

The tag declaration base "class".

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

