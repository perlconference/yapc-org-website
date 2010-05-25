

# = HISTORY SECTION =====================================================================

# ---------------------------------------------------------------------------------------
# version | date     | author   | changes
# ---------------------------------------------------------------------------------------
# 0.14    |28.05.2001| JSTENZEL | added DIRECTIVE_VARRESET;
#         |12.06.2001| JSTENZEL | added PARSER_... constants;
# 0.13    |18.03.2001| JSTENZEL | added tag constants;
# 0.12    |14.03.2001| JSTENZEL | added mailing list hint to POD;
# 0.11    |20.01.2001| JSTENZEL | added new constant DIRECTIVE_VARSET;
# 0.10    |07.12.2000| JSTENZEL | new namespace PerlPoint;
# 0.09    |18.11.2000| JSTENZEL | added new CACHE constants;
# 0.08    |28.10.2000| JSTENZEL | added new constant TRACE_ACTIVE;
# 0.07    |07.10.2000| JSTENZEL | added new constant DIRECTIVE_NEW_LINE;
#         |          | JSTENZEL | sligthly improved POD;
# 0.06    |27.05.2000| JSTENZEL | updated POD;
# 0.05    |11.04.2000| JSTENZEL | added new paragraph constants: xxx_DPOINT;
# 0.04    |07.04.2000| JSTENZEL | added new paragraph constants: xxx_UPOINT, xxx_OPOINT;
#         |08.04.2000| JSTENZEL | added new paragraph constants: xxx_xSHIFT;
#         |09.04.2000| JSTENZEL | START/STOP constants are now in the same range as
#         |          |          | directives to avoid comparison trouble in tests;
#         |14.04.2000| JSTENZEL | new directives: list envelopes;
# 0.03    |13.10.1999| JSTENZEL | updated POD;
# 0.02    |11.10.1999| JSTENZEL | renamed into PP::Constants;
#         |          | JSTENZEL | adapted POD to pod2text (needs more blank lines);
#         |          | JSTENZEL | added backend constants;
# 0.01    |09.10.1999| JSTENZEL | derived from the PP::Parser draft.
# ---------------------------------------------------------------------------------------

# = POD SECTION =========================================================================

=head1 NAME

B<PerlPoint::Constants> - public PerlPoint::... module constants

=head1 VERSION

This manual describes version B<0.14>.

=head1 DESCRIPTION

The module declares a number of constants shared between other
B<PerlPoint::...> modules.

=head1 SYNOPSIS

The I<usage> of the provided constants is described in the manuals
of the using modules B<PerlPoint::Parser> and B<PerlPoint::Backend>.

=head1 CONSTANTS

=cut

# declare package
package PerlPoint::Constants;

# declare version
$VERSION=$VERSION=0.14;

# startup actions
BEGIN
 {
  # declare startup helper function
  sub startupGenerateConstants
    {
     # init counter
     my $c=0;

     # and generate constants
     foreach my $constant (@_)
       {eval "use constant $constant => $c"; $c++;}
    }

=pod

=head2 Stream directive constants

These constants are built into I<directives> which the parser produces
in its output (that is, the representation format it translates an ASCII
text in to be subsequently processed by a backend).

=over 4

=item DIRECTIVE_BLOCK

flags a block paragraph;

=item DIRECTIVE_COMMENT

flags a comment;

=item DIRECTIVE_COMPLETE

a format entity is completed;

=item DIRECTIVE_DOCUMENT

flags a complete document (made from one ASCII file);

=item DIRECTIVE_DLIST

flags a "definition list";

=item DIRECTIVE_DPOINT

flags a "definition point" paragraph;

=item DIRECTIVE_DPOINT_ITEM

flags a "definition point" item (the stuff to be defined);

=item DIRECTIVE_HEADLINE

flags a headline;

=item DIRECTIVE_LIST_LSHIFT

control directive, shift a list left;

=item DIRECTIVE_LIST_RSHIFT

control directive, shift a list right;

=item DIRECTIVE_NEW_LINE

a backend hint to inform about a new source line;

=item DIRECTIVE_OLIST

flags an "ordered list";

=item DIRECTIVE_OPOINT

flags an "ordered point" paragraph;

=item DIRECTIVE_SIMLPE

a pseudo directive, used to flag simple strings in backends;

=item DIRECTIVE_START

a format entity starts;

=item DIRECTIVE_TAG

flags a tag;

=item DIRECTIVE_TEXT

flags a text paragraph;

=item DIRECTIVE_ULIST

flags an "unordered list";

=item DIRECTIVE_UPOINT

flags an "unordered point" paragraph;

=item DIRECTIVE_VARRESET

a backend hint flagging that I<all> variables are deleted;

=item DIRECTIVE_VARSET

a backend hint propagating a variable setting;

=item DIRECTIVE_VERBATIM

flags a verbatim block paragraph;

=back

=cut

  # directive constants
  startupGenerateConstants(
                           'DIRECTIVE_START',        # entity start;
                           'DIRECTIVE_COMPLETE',     # entity complete;

                           'DIRECTIVE_BLOCK',        # block;
                           'DIRECTIVE_COMMENT',      # comment;
                           'DIRECTIVE_DLIST',        # definition list;
                           'DIRECTIVE_DOCUMENT',     # document;
                           'DIRECTIVE_DPOINT',       # definition list point;
                           'DIRECTIVE_DPOINT_ITEM',  # definition list point;
                           'DIRECTIVE_HEADLINE',     # headline;
                           'DIRECTIVE_LIST_LSHIFT',  # shift list left;
                           'DIRECTIVE_LIST_RSHIFT',  # shift list right;
                           'DIRECTIVE_NEW_LINE',     # backend line hint;
                           'DIRECTIVE_OLIST',        # ordered list;
                           'DIRECTIVE_OPOINT',       # ordered list point;
                           'DIRECTIVE_TAG',          # tag;
                           'DIRECTIVE_TEXT',         # text;
                           'DIRECTIVE_ULIST',        # unordered list;
                           'DIRECTIVE_UPOINT',       # unordered list point;
                           'DIRECTIVE_VARSET',       # backend hint: variable setting;
                           'DIRECTIVE_VARRESET',     # backend hint: reset *all* variables;
                           'DIRECTIVE_VERBATIM',     # verbatim;

                           'DIRECTIVE_SIMPLE',       # a pseudo directive (never used directly - MUST be the last here!);
                          );

  # parser constants
  startupGenerateConstants(
                           'PARSING_OK',             # all right, proceed;
                           'PARSING_COMPLETED',      # we know without further parsing that the input was perfect;
                           'PARSING_ERROR',          # a semantic error occured;
                           'PARSING_FAILED',         # a syntactical error occured;
                          );

  # tag constants
  startupGenerateConstants(
                           'TAGS_OPTIONAL',          # something is optional;
                           'TAGS_MANDATORY',         # something is mandatory;
                           'TAGS_DISABLED',          # something is disabled (not necessary);
                          );

  # release memory
  undef &startupGenerateConstants;


=pod

=head2 Parser constants

control how the parser continues processing, usually used by tag hooks.

=over 4

=item PARSING_COMPLETED

We read all we need. Stop parsing successfully.

=item PARSING_ERROR

A semantic error occurred. Parsing will usually be continued to possibly detect even more errors.

=item PARSING_FAILED

A syntactic error occured. Parsing will be stopped immediately.

=item PARSING_OK

Input ok, parsing can be continued.

=back


=head2 Trace constants

They activate trace code.

=over 4

=item TRACE_BACKEND

activates backend traces;

=item TRACE_LEXER

activates the traces of the lexical analysis.

=item TRACE_NOTHING

deactivates all trace codes. (In fact, it I<does not activate> any trace.
If you decide to combine it with other trace constants, it will cause nothing.)

=item TRACE_PARAGRAPHS

activates traces which show the paragraphs recognized when they are entered
or completed.

=item TRACE_PARSER

activates the traces of the syntactical analysis.

=item TRACE_SEMANTIC

activates the traces of the semantic analysis.

=item TRACE_ACTIVE

activates the traces of active contents evaluation.

=back

=cut

  # declare trace constants (take care of correct values)
  use constant 'TRACE_NOTHING'    =>  0;            # MUST be 0!
  use constant 'TRACE_PARAGRAPHS' =>  1;
  use constant 'TRACE_LEXER'      =>  2;
  use constant 'TRACE_PARSER'     =>  4;
  use constant 'TRACE_SEMANTIC'   =>  8;
  use constant 'TRACE_ACTIVE'     => 16;
  use constant 'TRACE_BACKEND'    => 32;

=pod

=head2 Display constants

determine if information messages should be suppressed.

=over 4

=item DISPLAY_ALL

all messages are displayed. (More correctly, no message is suppressed.
If you combine this constant with other display constants, it will take
no effect.)

=item DISPLAY_NOINFO

suppresses information messages;

=item DISPLAY_NOWARN

suppresses warnings;

=back

=cut

  # declare display constants
  use constant 'DISPLAY_ALL'      => 0;            # MUST be 0!
  use constant 'DISPLAY_NOINFO'   => 1;            # suppress informations;
  use constant 'DISPLAY_NOWARN'   => 2;            # suppress warnings;

=pod

=head2 Cache constants

specify how presentation files shall be cached.

=over 4

=item CACHE_OFF

Files are reparsed completely regardless of cache data. Existing cache data
remain untouched.

=item CACHE_ON

While reading the presentation descriptions, cached and unchanged paragraphs
are reloaded from the cache if possible. New or modified paragraphs are stored
to accelerate repeated reading.

Please note that this will not overwrite or remove previously stored cache data for modified
or deleted paragraphs. Old cache data remains in the cache, while new data is added - the
cache size continously grows.

=item CACHE_CLEANUP

Cleans up an existing cache before the parser starts (and possibly rebuilds it).

=back

=cut

  # declare display constants
  use constant 'CACHE_OFF'        => 0;            # MUST be 0! Deactivates the cache.
  use constant 'CACHE_ON'         => 1;            # activates the cache;
  use constant 'CACHE_CLEANUP'    => 2;            # cache cleanup;
 }

# modules
use Exporter;
@ISA=qw(Exporter);

# declare exports
@EXPORT=qw(
           DIRECTIVE_START
           DIRECTIVE_COMPLETE

           DIRECTIVE_BLOCK
           DIRECTIVE_COMMENT
           DIRECTIVE_DLIST
           DIRECTIVE_DOCUMENT
           DIRECTIVE_DPOINT
           DIRECTIVE_DPOINT_ITEM
           DIRECTIVE_HEADLINE
           DIRECTIVE_LIST_LSHIFT
           DIRECTIVE_LIST_RSHIFT
           DIRECTIVE_NEW_LINE
           DIRECTIVE_OLIST
           DIRECTIVE_OPOINT
           DIRECTIVE_VARRESET
           DIRECTIVE_TAG
           DIRECTIVE_TEXT
           DIRECTIVE_ULIST
           DIRECTIVE_UPOINT
           DIRECTIVE_VARSET
           DIRECTIVE_VERBATIM

           DIRECTIVE_SIMPLE

           TRACE_NOTHING
           TRACE_PARAGRAPHS
           TRACE_LEXER
           TRACE_PARSER
           TRACE_SEMANTIC
           TRACE_ACTIVE
           TRACE_BACKEND

           DISPLAY_ALL
           DISPLAY_NOINFO
           DISPLAY_NOWARN

	   CACHE_OFF
	   CACHE_ON
	   CACHE_CLEANUP
          );

%EXPORT_TAGS=(
              parsing => [qw(PARSING_OK PARSING_COMPLETED PARSING_ERROR PARSING_FAILED)],
              tags    => [qw(TAGS_OPTIONAL TAGS_MANDATORY TAGS_DISABLED)],
             );

Exporter::export_ok_tags(
                         qw(
                            parsing
                            tags
                           )
                        );

1;


# = POD TRAILER SECTION =================================================================

=pod

=head1 SEE ALSO

=over 4

=item B<PerlPoint::Parser>

A parser for Perl Point ASCII texts.

=item B<PerlPoint::Backend>

A frame class to write Perl Point backends.

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
