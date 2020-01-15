
// vim: set filetype=pp2html:

// macros
+PP:PerlPoint

+IB:\I<\B<__body__>>

+BC:\B<\C<__body__>>


=Introduction

OK, there's this special cool multiplatform presenter software you want to use, but currently \PP cannot be translated into its format. This situation can be changed - just write a \PP converter. A \PP converter takes a \PP source and translates it into another format.

The target format can be almost everything. There's no restriction to formats used by presentation \I<software>. Documents can be presented in many ways: on a wall, on screen or printed, in the Web or intranet - and there are many formats out there meeting many special needs. Think of the \PP converters already there: they address \I<HTML> (for browser presentations, online documentations, training materials, ...), \I<Clinton Pierce's Perl Projector> (for traditional presentations), \I<LaTex> (for high quality prints) and \I<SDF> (as an intermediate format to generate PDF, PostScript, POD, text and more easily). \IB<Once you know the target format, you can write a \PP converter to it.>

Usually, there's one converter for every target format. This is no strict rule - you may want to implement features which are not provided by an already existing \C<pp2anything> converter, so feel free to implement your own version. Nevertheless, to avoid confusion, it may be worth a try to cooperate with the original author before you start. Maybe you can join his team.

In this document, it is assumed that you are familiar with the \PP language and its element, which is explained in ...


=The architecture of a converter

All \PP converters are basically built the same way.

==The base design

To relieve converter authors, the CPAN distribution \C<\PP::Package> provides a framework to write converters. The simple idea is that because all converters have to process \PP sources (and should do this the same way), there's no need to implement this parsing again and again. So the framework provides a \I<parser> which reads the sources and generates data which contain the source contents. Please have a look at the following image.

\IMAGE{src="../images/pp-src-stream-e.png"}

The parser reads \PP sources and checks them for integrity. Valid sources are translated into intermediate data which is called a "stream", so all converters will be fed with correct input. The parser is provided by the framework class \B<\PP::Parser>. It implements the \PP base language definition to recognize paragraphs, macros, variables, tags, and so on.

Once we have the intermediate data, there's another job all converters need to perform the same way: these data need to be processed as well. It's seems to be a good idea to encapsulate this processing by another general interface. This relieves converter authors even more, freeing them from the need of dealing with the details of the stream implementation. (Which may occasionally change.) So there's another framework class called \B<\PP::Backend>. Its objects can walk through the stream, calling user defined functions to provide its elements. And these callbacks are the place where the target format is produced.

\IMAGE{src="../images/pp-stream-result-e.png"}

With this framework, a converter author can focus just on target format generation. That's the part naturally most interesting to him.

==The language implementation

Let's go back to the parser. It was said that it implements the "\PP base language definition to recognize paragraphs, macros, variables, tags, and so on". Does this mean that the complete language is implemented there? No, that's not the case. Instead of this, there is an important part left to the converter author to make the design as flexible as possible. This point is the definition of tags.

Tags are very converter specific. They usually reflect a feature of the target format or a special feature the converter author wants to provide.

  Hyperlinks, for example, are essential if converting
  to HTML. They can be used in PDF as well. But if you
  are writing a converter to \I<pure text>, they might
  be useless.

  Or: one author wants to provide footnotes, while another
  one does not.

To implement all wished tags in the parser would make the converter framework very inflexible and hard to maintain. Such an approach could end up with a huge, difficult to maintain or even unusable tag library. All tag implementation details of all converters would need to be well coordinated. So that's no real alternative.

Instead of this, \PP (or its \I<base> definition) only defines the \I<syntax> of a tag (and reserves a small set of tags implementing base features like tables or image integration). \I<The definition of concrete tags, however, is a task of the several converters.> So you are free to define all the tags you want, and you can modify this set without changes to the framework. A definition currently includes the tag name, option and body declarations, and controls how the parser handles tag occurences. It's even possible to hook into the parsers tag processing.

Tags are defined by \I<Perl modules>, for a simple reason: I looked for a way to make their usage as easy as possible. And what could be easier than to write something like

  use \PP::Tags::\B<MyFormat>;

\? Hardly nothing.

But there are even more advantages. Defining tags by modules provides a simple way to \I<combine> definitions, to publish them in a central tag repository (CPAN) and to use them in various converters. \PP even offers a way to say the parser "We do not implement the tags of target language SuperDooper, but please treat them as tags anywhere (we will ignore them in the backend running subsequently)." - which makes it easy to process one and the same source by numerous converters defining completely different tag sets.

==The whole picture

So there are two main tasks to perform when writing a converter: define the tags you want to use and write backend callbacks which generate one or more documents in the target format. These pieces are then put together by an application that loads tag definitions, runs the parser and calls the backend (which invokes your callbacks).


The following chapters will describe this work in detail.


=Tag definition

It's up to you to define your tag meanings. Tags are usually used to mark up text. This may be a logical markup (index entry, code sequence, ...) or a formatting one (bold, italics, ...), for example.

  \B<\\B<something\>> marks "something" to
  be formatted bold.

  The pp2html tag \B<\\X> declares index entries
  like \B<\\X<here>>.

Note that the common (and recommended) way of markup is to expect the marked text part in the tags body. However, it is also possible to declare begin and end tags which enclose the marked parts, like the builtin \C<\\TABLE> and \C<\\END_TABLE> do. This allows to enclose even empty lines (and therefore several paragraphs).

  \\TABLE

  Column   | Column
  contents | contents

  \\END_TABLE

Note that a tag does note necessarily need to have a body part. \C<\\END_TABLE>, for example, has not.

Depending on the tag meaning (or "semantics"), a tag may need options. These are parameters passed to the tag, specifying how it shall be evaluated. Tag options can be optional or mandatory.

  The \\IMAGE tag uses options to specify
  what file should be loaded, as in

  \\IMAGE{src="image.png"}

As a general rule, tag options control tag processing, while the tag body contains parts of the document. Keep in mind that your tags might be processed by \I<other> converters as well which do not handle them. In such a case, only the tag body will remain in the source.

  Theoretically, the image tag could use the
  tags \I<body> as well to declare the image file:

  \\IMAGE\B<<image.png\>>

  But if a converter ignores \\IMAGE, this
  would result in the \I<text> "image.png" which
  will usually make no sense to a reader.

So, when you design your tags, make sure that nothing of them remains visible in the result in case they will be ignored.


==Finding tag names

New tag names can be freely chosen, with two exceptions: first, certain tag names are already used (and therefore reserved) by the base system:

@|
tag                                                      | description
\BC<\\B>, \BC<\\C>, \BC<\\I>, \BC<\\IMAGE>, \BC<\\READY> | Base tags defined by \BC<\PP::Tags::Basic>. By convention, \I<all> converters support these tags.
\BC<\\TABLE>, \BC<\\END_TABLE>                           | construct tables
\BC<\\EMBED>, \BC<\\END_EMBED>                           | embed other languages into a \PP source, e.g. to directly include parts in the target format, or to call Perl code which produces \PP on the fly
\BC<\\INCLUDE>                                           | loads additional files which are made part of the source (in various ways)

Second, please have a look at existing converters and \I<their> tags. It might confuse users if one and the same tag name has completely different meanings in different converters. So if your prefered name is already used, please invent another one. On the other hand, it may be the intention to support "foreign" tags as well, in a way that fits into your target format. In this case, the "foreign" names (and their syntax) \I<have> to be used, of course.

All tag names are made of uppercased letters. Underscores and digits are allowed as well. The parser does not recognize a tag if its name does not match these rules.


==Writing a tag module

Now when your tags are designed, you need to define them by a module in the \BC<PerlPoint::Tags> namespace and make it a subclass of \BC<PerlPoint::Tags>:

  # declare a tag declaration package
  package PerlPoint::Tags::New;

  # declare base "class"
  use base qw(PerlPoint::Tags);

The base module \BC<\PP::Tags> contains a special \C<import()> method which arranges that the parser learns new tag definitions when a tag module is loaded by \C<use>. \BC<\PP::Tags> is provided as part of the converter framework \BC<\PP::Package>.

It is recommended to have a "top level" tag declaration module for each \PP converter, so there could be a \C<PerlPoint::Tags::\I<HTML>>, a \C<PerlPoint::Tags::\I<Latex>>, \C<PerlPoint::Tags::\I<SDF>>, a \C<PerlPoint::Tags::\I<XML>> and so on. (These modules of course may simply \XREF{name="Integrating foreign tags"}<invoke lower level declarations> if appropriate.)

===Tag definition

Now the tags can be declared. Tag declarations are expected in a global hash named \BC<%tags>. Each key is the name of a tag, while descriptions are nested structures stored as values.

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

This looks complicated but is easy to understand. The \C<option> and \C<body> slots express if options and body are obsolete, optional or mandatory. This is done by using constants provided by
\BC<PerlPoint::Constants> (which comes with the framework). The following constants are defined:

@|
constant            | meaning
\BC<TAGS_OPTIONAL>  | Options/body can be used or not.
\BC<TAGS_MANDATORY> | The option/body part \I<must> be specified.
\BC<TAGS_DISABLED>  | No need to use options/body. \I<The parser will not expect such parts.> This means that with an obsolete body, an \C<<anything\>> sequence will not be treated as a tag body but as plain text. Likewise, if options are declared to be obsolete and a \C<{thing=something}> follows the tag name, this will be detected as plain text, not as the tag options. This can cause syntactical errors if the body is mandatory, because in this case the parser expects the body to follow the tag name.

Omitted \C<options> or \C<body> slots mean that options or body are \I<optional>.

If you need further checks you can hook into the parser by using the \C<hook> key, specifying a subroutine:

  %tags=(
         EMPHASIZE => {
                       # options
                       options => TAGS_OPTIONAL,

                       # perform special checks
                       \B<hook> => sub {
                                    # get parameters
                                    my ($tagline, $options, @body)=@_;

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

Whenever the parser detects an occurence of the defined tag, it will invoke the hook function and pass the source line, a reference to a hash of option name / value pairs to check, and a body array. Using the option hash reference, \I<the hook can modify the options>. Different to this, the body array is \I<a copy> of the body part of the stream. Therefore the hook cannot modify the body part.

A hook should return one of the following codes (defined by \BC<\PP::Constants>):

@|
return code            | description
\BC<PARSING_COMPLETED> | Parsing will be stopped \I<immediately>. The source is declared to be valid.
\BC<PARSING_ERROR>     | A semantic error occurred. This error will be counted, but parsing will be continued to possibly detect even more errors.
\BC<PARSING_FAILED>    | A syntactic error occured. Parsing will be stopped immediately.
\BC<PARSING_OK>        | The checked object is declared to be OK, parsing will be continued.

Here's an example hook from the implementation of \C<\\IMAGE>. It checks if all necessary options were set and if a specified image file really exists (to warn a user when an invalid image file is detected). Finally, it modifies the source option to provide the absolute path to the backend, which is known when the source is parsed, but unknown when the backend processes the stream.

  sub
   {
    # declare and init variable
    my $ok=PARSING_OK;

    # take parameters
    my ($tagLine, $options)=@_;

    # check them
    $ok=PARSING_FAILED, warn qq(\n\n[Error] Missing "src" option in IMAGE tag, line $tagLine.\n) 
       unless exists $options->{src};
    $ok=PARSING_ERROR,  warn qq(\n\n[Error] Image file "$options->{src}" does not exist or is no file in IMAGE tag, line $tagLine.\n)
       if $ok==PARSING_OK and not (-e $options->{src} and not -d _);

    # absolutify the image source path (should work on UNIX and DOS, but other systems?)
    my ($base, $path, $type)=fileparse($options->{src});
    $options->{src}=join('/', abs_path($path), basename($options->{src}))
       if $ok==PARSING_OK;

    # supply status
    $ok;
   },

Hooks are an interesting way to extend document parsing, but please take into consideration that tag hooks might be called quite often. So, if checks have to be performed, users will be glad if they are performed quickly.

Please note that there are no tag namespaces. Although Perl modules are used to define the tags, tags declared by various \C<PerlPoint::Tags::Xyz> share the same one "global scope", because a \PP document author simply uses all tag names the same way, regardless where they were defined. This means that different tags should be \I<named> different.


===Tag sets

Tag definitions can be grouped by setting up a global hash named \C<%sets>.

  %sets=(
         pointto => [qw(EMPHASIZE COLORIZE)],
        );

When using the definition module, this allows to activate the tags \C<\\EMPHASIZE> and \C<\\COLORIZE> together:

  # declare all the tags to recognize
  use PerlPoint::Tags::New \B<qw(:pointto)>;

The syntax is obviously borrowed from Perls usual import mechanism.

Tag sets can overlap:

  %sets=(
         pointto => [qw(EMPHASIZE \B<COLORIZE>)],
         set2    => [qw(\B<COLORIZE> FONTIFY)],
        );

And of course they can be nested:

  %sets=(
         \B<pointto> => [qw(EMPHASIZE COLORIZE)],
         all     => [(\B<':pointto'>, qw(FONTIFY))],
        );

===Completing the module

As usual, the module should flag successful loading by a final statement like

  1;


===Integrating foreign tags

You may want your converter to provide tags already defined somewhere. It is not necessary to redefine them, which would make it hard to keep all definitions synchronized later. Instead of this, simply load the appropriate modules. As an example, here's the (almost) complete code of \C<\PP::Tags::SDF>. The related converter \C<pp2sdf> does not define a single tag itself - its tag definitions are just a combination of "foreign" tags.

  01: # declare package
  02: package PerlPoint::Tags::SDF;
  03: 
  04: # declare package version
  05: $VERSION=...;
  06: 
  07: # declare base "class"
  08: use base qw(PerlPoint::Tags);
  09: 
  10: # set pragmata
  11: use strict;
  12: 
  13: # declare tags (reuse definitions made elsewhere)
  14: \B<use PerlPoint::Tags::Basic;>
  15: \B<use PerlPoint::Tags::HTML qw(A L PAGEREF SECTIONREF U XREF);>
  16: 
  17: 1;

This example demonstrates two methods of reusing other definitions. Line 14 loads all definitions made by \C<PerlPoint::Tags::Basic>. Line 15, on the other hand, picks certain definitions made by \C<PerlPoint::Tags::HTML>, the definition file of \C<pp2html>, ignoring all definitions not explicitly listed in the \C<use> statement.

If tags are defined in more than one of the included modules, messages will be displayed warning about duplicated definitions. New definitions overwrite earlier ones, so the last appearing definition of a tag wins.


===Documentation

The tag definition module is a good place to describe your tags by POD. This way, CPAN will provide these descriptions automatically to both other converter authors and \PP users.

Additionally, it is recommended to provide \PP documentations, one file per tag. Examples can be found in \C<\PP::Package>, describing the base tags \C<\\B>, \C<\\C>, \C<\\I>, \C<\\IMAGE> and \C<\\READY>. Those documentations, collected from all available converters, will make it easy to build (and maintain) a reference document of all \PP tags automatically which is planned to be provided on a future \PP homepage.


===Examples and more

\C<\PP::Package> comes with various tag modules which may illustrate this chapter. Please have a look at \C<\PP::Tags::Basic> and \C<\PP::Tags::SDF>.

Further documentation about tag definition can be found in the manpage of \C<\PP::Tags>.


=Writing the converter

Because all converters are built on base of the same frameset, there's a general scheme they can be constructed according to, which is described in the following chapters. Additionally to the frameset there are several \I<conventions> what features all converters should share. These conventions are only suggestions, no rules, but make it easier for \PP users to deal with various converters.

==The converter package

Different to usual Perl scripts, each \PP converter should declare its own namespace, which is by convention \C<\PP::Converter::<converter name\>>.

  # declare script package
  package \B<PerlPoint::Converter::pp2sdf>;

The background of this convention is the way \I<Active Contents> is implemented. \I<Active Contents> means \PP source parts made from embedded Perl. To make document source sharing as secure as possible, and configurable to \PP users, this embedded Perl can be evaluated in a compartment provided by the \BC<Safe> module.

\C<Safe> executes passed code in a special namespace, to suppress access to "unsafed" code parts. It is arranged that the \I<executed code itself> sees this namespace as \C<main>. So the embedded code uses \C<main>, which is in fact the special compartment namespace \I<different> to \C<main>.  

OK. That's no problem. But unfortunately not all code can be executed by \C<Safe>. It is different to use \C<sort> and to load modules, for example. That's why current versions of the frameset allow to execute Active Contents by \C<eval()> alternatively.

Now, if a document author writes Active Contents, he's not necessarily aware of how this embedded code will be executed. He doesn't know about \C<Safe> and \C<eval()>, so \PP has to arrange that the code can be executed \I<both> ways. Because it cannot modify \C<Safe>, it has to deal with \C<eval()>, so it makes it working in \C<main>. This means that embedded user code will access \C<main>, and that's why \C<main> should not be used by a converter itself.


==Modules to load

Several modules need to be loaded by all converters.

  use Safe;

\BC<Safe> is necessary to arrange the \XREF{name="The converter package"}<mentioned> execution of embedded Perl code.

  use Getopt::Long;
  use Getopt::ArgvFile;

\BC<Getopt::Long> and \BC<Getopt::ArgvFile> are used to evaluate converter options. This handling can of course be managed by alternative option modules or handcrafted code, if you prefer.

  use PerlPoint::Parser;
  use PerlPoint::Backend;
  use PerlPoint::Constants;

These modules are used to build parser and backend.

  use PerlPoint::Tags;

\BC<\PP::Tags> enables to accept tags defined by \I<other> converters.

  use PerlPoint::Tags::Format;

Finally, declare the tags which shall be be valid. These can be tags you \XREF{name="Tag definition"}<defined> for this converter especially, tags developed for another converter or basic tags provided with the converter framework. If the tags you want to support are spread around, you can load as many definition modules as necessary. Note that warnings will be displayed if tags are defined multiply, and that the last appearing definition of a tag will overwrite earlier ones.


==Several variables

Of course the variables to declare strongly depend on how you are going to construct your converter. For the following sections, we need an array to store stream data in, and a hash to mirror user options.

  # declare variables
  my (
      @streamData,                # PerlPoint stream;
      %options,                   # option hash;
     );

==Option handling

Option handling is a highly individual part of software design. CPAN provides numerous modules which solve this task in several ways. This reflects the very different preferences of various people, and we do not want to restrict anyone in this field. On the other hand, \PP will be obviously easier to use if its several converters provide similar working interfaces. For this reason, the following conventions are established:

* Provide a way to use \XREF{name="Option files"}<option files>.

* Provide \XREF{name="Common options"}<common \PP options>.


===Option files

Option files allow to specify Perl script options \I<by files>, so they simply contain what would normally be specified in the commandline. This relieves a user from typing in typical options again and again. It also allows to \I<reuse> options, which is helpful if a script provides a great option number. \C<pp2html>, for example, currently offers about 80 options. It is almost impossible to remember the combinations which produce a certain result, but it is easy to store them in a file like this:

  # configure style
  -style_dir /opt/perlpoint/pp2html/styles
  -style surprise

, to store this file as \C<style.cfg> and to invoke \C<pp2html> as in

  > pp2html \B<@style.cfg> ...

Option files can be nested and cascaded, and you can use as many of them as you want. It is also possible to use \I<default> option files which do not need to be specified when calling the script but are resolved automatically. They make it very handy to use a multi option script.

To provide option file usage, all you have to do is to integrate the following statement.

  # resolve option files
  argvFile(default=>1, home=>1);

\C<argvFile()> is a function of \C<Getopt::ArgvFile> which was already \XREF{name="Modules to load"}<loaded> and performs three tasks in this call:

# It searches the users home directory for a file named \C<.<converter name\>>, e.g.
  \C<\B<.>pp2sdf>. All options found therein are "unshifted" into \C<@ARGV>. A default
  option file in ones home directory stores individual preferences of calling the converter.

# It searches the directory where the converter script is located for (probably another)
  \C<.<converter name\>> and integrates its options likewise, "unshifting" them to \C<@ARGV>
  as well. Such a global option file can be used to set up options to be used by all
  script users.

# It processes \C<@ARGV> to resolve any explicit and nested option files.

The result is an \C<@ARGV> array which contains all options, both specified directly and by file, ready to be processed by usual option handling modules like \BC<Getopt::Long>.


===Common options

I personally prefer \BC<Getopt::Long> for option handling. Your preferences may vary, but please provide at least the options specified in this example statement:

  # get options
  GetOptions(\%options,

             "activeContents",    # evaluation of active contents;
             "cache",             # control the cache;
             "cacheCleanup",      # cache cleanup;
             "help",              # online help, usage;
             "nocopyright",       # suppress copyright message;
             "noinfo",            # suppress runtime informations;
             "nowarn",            # suppress runtime warnings;
             "quiet",             # suppress all runtime messages except of error ones;
             "safeOpcode=s@",     # permitted opcodes in active contents;
             "set=s@",            # user settings;
             "tagset=s@",         # add a tag set to the scripts own tag declarations;
             "trace:i",           # activate trace messages;
            );

:\BC<activeContents>: flags if active contents shall be evaluated or not.

:\BC<cache>: allows user to activate and deactivate the cache.

:\BC<cacheCleanup>: enforces a cleanup of existing cache files.

:\BC<help>: displays a usage message, which is usually the complete converter manpage.
            The converter is stopped after performing the display task.

:\BC<nocopyright>, \BC<noinfo> and \BC<nowarn>: suppress informations a user can occasionally
                                                live without: copyright messages, informations
                                                and warnings.

:\BC<quiet>: combines \C<nocopyright>, \C<noinfo> and \C<nowarn>.

:\BC<safeOpcode>: Embedded code ("Active Contents") is usually executed in a \BC<Safe>
                  compartment. This way a user can control which operations shall be allowed
                  and which shall be denied. According to the interface of \C<Safe>, allowed 
                  operations are specified by Perl opcodes as defined by the \BC<Opcode>
                  module. With this option, a user can specify such an opcode to allow its
                  execution. It can be used multiply to accept several opcodes. Alternatively,
                  the user might pass the special string \C<ALL> which flags that Active
                  Contents shall be executed without any restriction - which will be done by
                  using \C<eval()> instead of \C<Safe>.

:\BC<set>: provides a way to inject user defined settings into Active Contents. This is helpful
           to process documents in various ways, without a need to modify document sources.

:\BC<tagset>: can be used multiply to declare that foreign tags shall be accepted. Foreign tags
              are tags not supported by the converter, but defined for other converters. By 
              accepting them, a user can make a source pass to the converter even if it uses
              tags of another converter.

:\BC<trace>: activates several traces, at least of the frameset modules.

Luckily, the implementation of most of these options is as common as the options themselves and shown in the following sections. So in most cases it's no extra effort to provide these features.

For example, \C<quiet> can be implemented by

  @options{qw(nocopyright noinfo nowarn)}=() x 3 if exists $options{quiet};

It should be possible to control traces by an environment variable \BC<SCRIPTDEBUG> as well as by option \C<trace>:

  $options{trace}=$ENV{SCRIPTDEBUG} if not exists $options{trace} and exists $ENV{SCRIPTDEBUG};


==Usual startup operations

Now could be a good time to display a copyright message if you like.

  # display copyright unless suppressed

Help requests can be fulfilled very quickly, because they do not need further operations.

  # check for a help request
  (exec("pod2text $0 | less") or die "[Fatal] exec() cannot be called: $!\n") if $options{help};

After presenting the manpage, the converter stops. It also terminates in case of a wrong usage, especially missing document sources.

  # check usage
  die "[Fatal] Usage: $0 [<options>] <PerlPoint source(s)>\n" unless @ARGV>=1;

  # check passed sources
  -r or die "[Fatal] Source file $_ does not exist or is unreadable.\n" foreach @ARGV;


==Foreign tag integration

Every converter \XREF{name="Modules to load"}<supports> a set of tags, but users can process the same sources by \I<several> converters which support different tags, so a source to be read by your converter may contain tags you did not think of. Fortunately this can be easily handled by implementing \XREF{name="Common options"}<option> \C<-tagset> and the following statement.

  # import tags
  PerlPoint::Tags::addTagSets(@{$options{tagset}}) if exists $options{tagset};

\C<PerlPoint::Tags::addTagSets()> extends the converters tag definitions by loading foreign \XREF{name="Writing a tag module"}<definition files>. To make this intuitive, users have to pass \I<target formats> to \C<-tagset>, e.g. \C<HTML>.

  If a document was initially written to be processed
  by pp2\B<html> and is now passed to your converter,
  a user can use "-tagset \B<HTML>".

Tag definition packages are named \C<\PP::Tags::<target format\>>, so this rule makes it easy to find the appropriate definitions, and \C<PerlPoint::Tags::addTagSets()> can load them.

  If "-tagset \B<HTML>" is specified, the definition
  module \PP::Tags::\B<HTML> is loaded.

Please note that because \C<-tagset> is intended to reflect definitions made for a certain converter, there is no way to load only a subset of another converters tags descriptions.

Different to usual \XREF{name="Modules to load"}<definition loading>, no warning is displayed here if a loaded foreign tag is named like an own one, and the \I<original> converter definition will remain established to give the converter first priority.


==Set up Active Contents handling

If the special opcode \C<ALL> was passed, all embedded Perl operations are permitted and there's no need to perform them in a compartment provided by the \BC<Safe> module. This is flagged by a true \I<scalar> value. Otherwise, we need to construct a \C<Safe> object and to configure it according to the opcode settings.

  # Set up active contents handling. By default, we use a Safe object.
  my $safe=new Safe;
  if (exists $options{safeOpcode})
   {
    unless (grep($_ eq 'ALL', @{$options{safeOpcode}}))
      {
       # configure compartment
       $safe->permit(@{$options{safeOpcode}});
      }
    else
      {
       # simply flag that we want to execute active contents
       $safe=1;
      }
   }

The variable \C<$safe> which is prepared by this code is intended to be passed to the parser soon.


==The parser call

And now, the parser can be called. Because it is implemented by a class, we first need to build an object, which is simple.

  # build parser
  my $parser=new PerlPoint::Parser;

The objects method \C<run()> invokes the parser to process all document sources. Various parameters control how this task is performed and need to be set according to the converter options. It should be sufficient to simply copy this call and to slightly adapt it.

  # call parser
  $parser->run(
               stream          => \@streamData,
               files           => \@ARGV,

               filter          => 'perl|sdf|html',

               safe            => exists $options{activeContents} ? $safe : undef,

               activeBaseData  => {
                                   targetLanguage => 'SDF',
                                   userSettings   => {map {$_=>1} exists $options{set} ? @{$options{set}} : ()},
                                  },

               predeclaredVars => {
                                   CONVERTER_NAME    => basename($0),
                                   CONVERTER_VERSION => do {no strict 'refs'; ${join('::', __PACKAGE__, 'VERSION')}},
                                  },

               vispro          => 1,

               cache           =>   (exists $options{cache} ? CACHE_ON : CACHE_OFF)
                                  + (exists $options{cacheCleanup} ? CACHE_CLEANUP : 0),

               display         =>   DISPLAY_ALL
                                  + (exists $options{noinfo} ? DISPLAY_NOINFO : 0)
                                  + (exists $options{nowarn} ? DISPLAY_NOWARN : 0),

               trace           =>   TRACE_NOTHING
                                  + ((exists $options{trace} and $options{trace} &  1) ? TRACE_PARAGRAPHS : 0)
                                  + ((exists $options{trace} and $options{trace} &  2) ? TRACE_LEXER      : 0)
                                  + ((exists $options{trace} and $options{trace} &  4) ? TRACE_PARSER     : 0)
                                  + ((exists $options{trace} and $options{trace} &  8) ? TRACE_SEMANTIC   : 0)
                                  + ((exists $options{trace} and $options{trace} & 16) ? TRACE_ACTIVE     : 0),
              ) or exit(1);


So what happens here?

:\BC<stream>: passes a reference to an array which will be used to store the stream element
              in. It is suggested to pass an empty array (but currently new fields will be
              \I<added>, so existing entries will not be damaged).

:\BC<files>: passes an array of document source files to parse.

:\BC<filter>: declares which formats are allowed to be embedded or included. You can accept all
              formats which can be processed by the software which has to deal with the converter
              product, and "perl" to provide the full power of Active Contents. All formats not
              matching the filter will be \I<ignored>.

:\BC<safe>: pass the \XREF{name="Set up Active Contents handling"}<prepared> variable \C<$safe>.

:\BC<activeBaseData>: sets up a hash reference which is made accessible to Active Contents as
                      \C<$main::\PP>. The keys \C<targetLanguage> and \C<userSettings> are
                      provided by convention, but you may add whatever keys you need.

:\BC<vispro>: if set to a true value, the parser will display runtime informations.

:\BC<cache>: used to pass the cache settings. Please copy this code.

:\BC<display>: used to pass the display settings. Please copy this code.

:\BC<trace>: used to pass the trace settings. Please copy this code.


\C<run()> returns a true value if parsing was successful. It is recommended to evaluate this code and to stop processing in case of an error.

  # call parser
  $parser->run(...) \B<or exit(1)>;


==Backend construction

When the sources are parsed their data are represented in the stream where they can be processed to produce the final document(s). It is strongly recommended to do this by using the backend class shipped with the converter framework. In a first step, we have to make an object of this class. It is immediately configured, right by the constructor call.

  # build a backend
  my $backend=new PerlPoint::Backend(
                                     name    => 'pp2sdf',
                                     display =>   DISPLAY_ALL
                                                + (exists $options{noinfo} ? DISPLAY_NOINFO : 0)
                                                + (exists $options{nowarn} ? DISPLAY_NOWARN : 0),
                                     trace   =>   TRACE_NOTHING
                                                + ((exists $options{trace} and $options{trace} & 32) ? TRACE_BACKEND : 0),
                                     vispro  => 1,
                                    );

Names and behaviour of these constructor options are mostly known from \XREF{name="The parser call"}<call> of the parsers \C<run()> method.

:\BC<name>: a description used to identify the backend.

:\BC<display>: used to pass the display settings. Please copy this code.

:\BC<trace>: used to pass the trace settings. Please copy this code.

:\BC<vispro>: if set to a true value, the backend will display runtime informations.

Note: because backend processing does not consume stream data, it is possible to use more than one backend at a time, but there are side effects still. This may be improved by future framework versions.


==Backend callbacks

A backend is used to translate stream elements into appropriate expressions of the target format. Because of this, they need to work very format (or converter) specific. The only common task is to read the stream and to ignore all parts which the converter doesn't wish to support. These requirements are solved by a callback architecture.

When a backend is \XREF{name="Backend invokation: produce new code"}<started>, it runs through the stream. Every stream element is checked for its type, and then it is checked if a callback was specified to handle it. If so, the callback will be invoked to handle the element found, if not, the elemenet is ignored. Simple but powerful!

To make this work, callbacks need to be registered before the backend starts its stream run. This is done by the backend method \BC<register()>.

  # register backend handlers
  $backend->register(DIRECTIVE_BLOCK, \&handleBlock);
  ...

\C<register()> takes an element type and a code reference. All possible stream element types are declared by constants, which are defined and documented in \BC<\PP::Constants>. The code reference, on the other hand, points to a function which shall be invoked when an element of the described type is detected, which means that it begins or end.

Consider, for example, the statement in the last recent example: \C<DIRECTIVE_BLOCK> describes a code block element. The stream does not store blocks completely, but by a begin and end flag which show the "edges" of the block construction. Therefore the specified callback \C<handleBlock()> will be invoked twice: it will be called both when the block begins and when it is completed.

The callback \I<interface> is simple. It has a \I<common> part which is equal for all elements, and a \I<special> part which depends on the element type. The common part includes the element type (\C<DIRECTIVE_BLOCK>, \C<DIRECTIVE_TEXT>, ...) and the mode which is either \C<DIRECTIVE_START> or \C<DIRECTIVE_COMPLETED>, flagging if the element is starting or complete.

The \I<special> contains things like the name of a source file (\C<DIRECTIVE_DOCUMENT>), tag options (\C<DIRECTIVE_TAG>) or a headline level (\C<DIRECTIVE_HEADLINE>). See \XREF{name="Appendix A: Stream directives"}<Appendix A> for a complete list of all callback interfaces.

There is no common way how callbacks should work. It strongly depends on the target format, the converter features and the tags. You may build another data structure which is finally made a file, or print immediately, or mix both approaches, and there are several more choices like this. But the frameset helps to begin coding this individual part quickly.


==Backend invokation: produce new code

Everything is well prepared now, so we can finally run the backend and generate the results a user is waiting for. This is pretty easy.

  # run the backend
  $backend->run(\@streamData);

==Your individual parts

To complete the common "torso" shown in the sections above, you mostly need to add your own \XREF{name="Backend callbacks"}<backend callbacks>. Go for it! We are curious about a new interesting converter.


=Documentation

As a \PP converter, it would be great to be delivered with a \PP documentation. If you want to do so, it might be helpful to have a look at the converter packages \C<doc> directory. Its parts are intended to be a help to converter documentation authors, describing parts of the base implementation. Feel free to copy these parts and to modify it according to your implementation. (To keep the results maintainable, \\INCLUDE may be used to integrate the framework components.)


=Appendix A: Stream directives

This appendix shall provide a complete reference of all backend callback interfaces soon.

