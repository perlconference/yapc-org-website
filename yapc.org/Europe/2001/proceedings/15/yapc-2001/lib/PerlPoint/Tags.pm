

# = HISTORY SECTION =====================================================================

# ---------------------------------------------------------------------------------------
# version | date     | author   | changes
# ---------------------------------------------------------------------------------------
# 0.01    |19.03.2001| JSTENZEL | new.
# ---------------------------------------------------------------------------------------

# = POD SECTION =========================================================================

=head1 NAME

B<PerlPoint::Tags::Basic> - processes PerlPoint tag declarations

=head1 VERSION

This manual describes version B<0.01>.

=head1 SYNOPSIS

  # declare a tag declaration package
  package PerlPoint::Tags::New;

  # declare base "class"
  use base qw(PerlPoint::Tags);


=head1 DESCRIPTION

PerlPoint is built a modularized way. The base packages provide parsing
and stream processing for I<all> translators into target formats and are
therefore intended to be as general as possible. That's why they not even
define tags, because every translator author may wish to provide own tags
special to the addressed target projector (or format, respectively). On
the other hand, the parser I<needs> to know about tags to recognize them
correctly. That is where this module comes in. It serves as a base of
tag declaration modules by providing a general C<import()> method to be
inherited by them. This method scans the invoking module for certain data
structures containing tag declarations and imports these data into a
structure in its own namespace. The parser knows about this B<PerlPoint::Tags>
collection and makes it the base of its tag handling.

It is recommended to have a "top level" tag declaration module for each
PerlPoint translator, so there could be a C<PerlPoint::Tags::HTML>, a
C<PerlPoint::Tags::Latex>, C<PerlPoint::Tags::SDF>, a C<PerlPoint::Tags::XML>
and so on. (These modules of course may simply invoke lower level declarations.)

Note: We are speaking in terms of "classes" here but of course we are actually
only using the mechanism of C<import()> together with inheritance to provide
an intuitive and easy to use way of declaration.

As an additional feature, the module provides a method B<addTagSets()> to
allow translator users to declare tags additionally. See below for details.


=head2 Tag declaration by subclasses

So to declare tags, just write a module in the B<PerlPoint::Tags> namespace
and make it a subclass of B<PerlPoint::Tags>:

  # declare a tag declaration package
  package PerlPoint::Tags::New;

  # declare base "class"
  use base qw(PerlPoint::Tags);

Now the tags can be declared. Tag declarations are expected in a global hash
named B<%tags>. Each key is the name of a tag, while descriptions are nested
structures stored as values.

  # pragmata
  use strict;
  use vars qw(%tags %sets);

  # tag declarations
  %tags=(
         EMPHASIZE => {
                       # options
                       options => TAGS_OPTIONAL,

                       # don't miss the body!
                       body    => TAGS_MANDATORY,
                      },

         COLORIZE => {...},

         FONTIFY  => {...},

         ...
        );

This looks complicated but is easy to understand. Each option is decribed by a
hash. The I<body> slot just expresses if the body is obsolete,
optional or mandatory. This is done by using constants provided by
B<PerlPoint::Constants>. Obsolete bodies will not be recognized by the parser.

The I<body> slot may be omitted. This means the body is I<optional>.

There are the same choices for I<options> in general: they may be obsolete,
optional or mandatory. If the slot is omitted this means that the tag does
not need any options. The parser will I<not> accept a tag option part in this
case.

To sum it up, options and body of a tag can be declared as mandatory by TAGS_MANDATORY,
optional by TAGS_OPTIONAL, or obsolete by TAGS_DISABLED.

If you need further checks you can hook into the parser by using the
C<"hook"> ley:

  %tags=(
         EMPHASIZE => {
                       # options
                       options => TAGS_OPTIONAL,

                       # perform special checks
                       hook => sub {
                                    # get parameters
                                    my ($tagname, $options, @body)=@_;

                                    # checks
                                    $rc=...

                                    reply results
                                    $rc;
                                   }
                      },

         COLORIZE => {...},

         FONTIFY  => {...},

         ...
        );

An option hook function receives the tag name, a reference to a hash of
option name / value pairs to check, and a body array. Using the option
hash reference, I<the hook can modify the options>. The body array is
I<a copy> of the body part of the stream. The hook therefore cannot
modify the body part on parsers side.

The following return codes are defined:

=over 4

=item PARSING_COMPLETED

Parsing will be stopped successfully.

=item PARSING_ERROR

A semantic error occurred. This error will be counted, but parsing will be
continued to possibly detect even more errors.

=item PARSING_FAILED

A syntactic error occured. Parsing will be stopped immediately.

=item PARSING_OK

The checked object is declared to be OK, parsing will be continued.

=back

Hooks are an interesting way to extend document parsing, but
please take into consideration that tag hooks might be called quite often.
So, if checks have to be performed, users will be glad if they are
performed quickly.


=head2 Tag activation

Now, in a translator software where a parser object should be built, tag
declarations can be accessed by simply loading the declaration modules,
just as usual (there is no need to load B<PerlPoint::Tags> directly there):

  # declare all the tags to recognize
  use PerlPoint::Tags::New;

This updates a structure in the B<PerlPoint::Tags> namespace. The parser
knows about this structure and will automatically evaluate it.

Several declaration modules can be loaded subsequently. Each I<new> tag is
added to the internal structure, while I<predeclared> tags are overwritten
by new declarations.

  # declare all the tags to recognize
  use PerlPoint::Tags::Basic;
  use PerlPoint::Tags::HTML;
  use PerlPoint::Tags::SDF;
  use PerlPoint::Tags::New;


=head2 Activating certain tags

Certain translators might only want to support I<subsets> of tags declared in a
B<PerlPoint::Parser> submodule. This is possible as well, similar to the usual
importing mechanism:

  # declare all the tags to recognize
  use PerlPoint::Tags::New qw(COLORIZE);

This does only declare the C<COLORIZE> tag, but ignores C<EMPHASIZE> and C<FONTIFY>.


=head2 Tag sets

To simplify activation of certain but numerous tags a declaration module can group
them by setting up a global hash named C<%sets>.

  %sets=(
         pointto => [qw(EMPHASIZE COLORIZE)],
        );

This allows a translator autor to activate C<EMPHASIZE> and C<COLORIZE> at once:

  # declare all the tags to recognize
  use PerlPoint::Tags::New qw(:pointto);

The syntax is borrowed from the usual import mechanism.

Tag sets can overlap:

  %sets=(
         pointto => [qw(EMPHASIZE COLORIZE)],
         set2    => [qw(COLORIZE FONTIFY)],
        );

And of course they can be nested:

  %sets=(
         pointto => [qw(EMPHASIZE COLORIZE)],
         all     => [(':pointto', qw(FONTIFY))],
        );


=head2 Allowing translator users to import foreign tag declarations

As PerlPoint provides a flexible way to write translators, PerlPoint documents might
be written with tags for a certain translator and later then be processed by another
translator which does not support all the original tags. Of course, the second
translator does not need to handle these tags, but the parser needs to know they
should be recognized. On the other hand, it cannot know this from the declarations
made by the second translator itself, because they of course do not contain the
tags of the first translator.

The problem could be solved if there would be a way to inform the parser about the
tags initially used. That's why this module provides B<addTagSets()>, a method that
imports foreign declarations at run time. Suppose a translator provides an option
C<-tagset> to let a user specify which tag sets the document was initially written
for. Then the following code makes them known to the parser, addtionally to the
declarations the translator itself already made as usual (see above):

  # load module to access the function
  use PerlPoint::Tags;

  # get options
  ...

  # import foreign tags
  PerlPoint::Tags::addTagSets(@{$options{tagset}})
    if exists $options{tagset};

(Note: this example is based on the B<Getopt::Long> option access interface.
Other interfaces might need adaptations.)

Tags imported via C<addTagSets()> do I<not> overwrite original definitions.

A "tag set", in this context, is the set of tag declarations a certain translator
makes. So, the attributes to B<addTagSets()> are expected to be target languages
corresponding to the translators name, making usage easy for the user. So, pp2I<sdf>
is expected to provide a "tag set" declaration module PerlPoint::Tags::B<SDF>,
pp2html PerlPoint::Tags::B<HTML>, pp2xml PerlPoint::Tags::B<XML> and so on.

If all translators provide this same interface, usage should be easy. A user
who wrote a document with C<pp2html> in mind, passing it to C<pp2sdf> which provides
significantly less tags, only has to add the option C<"-tagset HTML"> to the
C<pp2sdf> call to make his document pass the PerlPoint parser.

=cut




# check perl version
require 5.00503;

# = PACKAGE SECTION (internal helper package) ==========================================

# declare package
package PerlPoint::Tags;

# declare package version (as a STRING!!)
$VERSION="0.01";



# = PRAGMA SECTION =======================================================================

# set pragmata
use strict;
use vars qw($tagdefs $multiplicityIgnored);

# = LIBRARY SECTION ======================================================================

# load modules
use Carp;
use PerlPoint::Constants 0.13 qw(:tags);


# = CODE SECTION =========================================================================

sub import
 {
  # get class name and extract it from arguments
  my $class=shift;

  # declare variables
  my ($tags, $sets);

  # build shortcuts
  {
   no strict qw(refs);
   $tags=\%{join('::', $class, 'tags')};
   $sets=\%{join('::', $class, 'sets')};
  }

  # process *all* the tags by default
  @_=sort keys %$tags unless @_;

  # process all declared symbols
  while (my $declared=uc(shift))
    {
     # set?
     if ($declared=~s/^:(.+)$/$1/)
       {
        # check if this set was declared (and declared as expected)
        confess "Use of undeclared tag set $declared in class $class" unless exists $sets->{$declared};
        confess "Set $declared of class $class was not declared by an array reference" unless ref($sets->{$declared}) eq 'ARRAY';

        # add all set tags to the list
        unshift(@_, sort @{$sets->{$declared}});

        # next turn
        next;
       }

     # ok, this is a tag - first, check if it was declared
     confess "Use of undeclared tag $declared in class $class" unless exists $tags->{$declared};

     # does the new tag overwrite an earlier declaration?
     if (exists $tagdefs->{$declared})
       {
        # ignore new settings, if necessary
        next if $multiplicityIgnored;

        # earlier settings will be overwritten, inform user
        carp "[Warn] Tag $declared declared multiply, replacing data!\n";
       }

     # all right, register it
     $tagdefs->{$declared}=$tags->{$declared};

     # immediately research it and make internal shortcuts
     $tagdefs->{$declared}{__flags__}{__body__}=                 # body flag:
       (
           not exists $tagdefs->{$declared}{body}                # lazy declaration: default is to expect a body;
        or not $tagdefs->{$declared}{body} & TAGS_DISABLED       # no explicitly disabled body;
       );
     

     $tagdefs->{$declared}{__flags__}{__options__}=              # option flags:
       (
            exists $tagdefs->{$declared}{options}                # default is to skip options;
        and not $tagdefs->{$declared}{options} & TAGS_DISABLED   # no explicitly disabled options;
       );
    }
 }


# import tagsets
sub addTagSets
 {
  # accept multiplicity
  local($multiplicityIgnored)=1;

  # process all arguments
  foreach my $set (@_)
    {
     eval join('::', 'use PerlPoint::Tags', $set);
     warn "[Warn] Could not import declarations of PerlPoint::Tags::$set.\n" if $@;
    }
 }



# flag successful loading
1;

# = POD TRAILER SECTION =================================================================

=pod

=head1 NOTES

The form of tag declaration provided by this module is designed to make
tag activation intuitive to write and read. Ideally, declarations are
written by one author, but used by several others.

Each tag declaration module should provide a tag description in PerlPoint.
This allows translator authors to easily integrate tag descriptions into
their own documentations.

Tag declarations have nothing to do with the way backends (translators) handle
recognized tags. They only enable tag detection and a few simple semantic checks
by the parser. A translator has still to implement its tag handling itself.

There are no tag namespaces. Although Perl modules are used to declare the
tags, tags declared by various C<PerlPoint::Tags::Xyz> share the same one
global scope. This means that different tags should be I<named> different.
B<PerlPoint::Tags> displays a warning if a tag is overwritten by another one.


=head1 SEE ALSO

=over 4

=item B<PerlPoint::Parser>

The parser module working on base of the declarations.

=item B<PerlPoint::Tags::xyz>

Various declaration modules.

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

