
=head1 NAME

Getopt::ArgvFile - interpolates script options from files into @ARGV

=head1 SYNOPSIS

  # load the module
  use Getopt::ArgvFile qw(argvFile);
  # load another module to evaluate the options, e.g.:
  use Getopt::Long;
  ...
  # solve option files
  argvFile;
  # evaluate options, e.g. this common way:
  GetOptions(%options, 'any');

=head1 DESCRIPTION

This module simply interpolates option file hints in @ARGV
by the contents of the pointed files. This enables option
reading from I<files> instead of or additional to the usual
reading from the command line.

The interpolated @ARGV could be subsequently processed by
the usual option handling, e.g. by a Getopt::xxx module.
Getopt::ArgvFile does I<not> perform any option handling itself,
it only prepares the array @ARGV.

Option files can significantly simplify the call of a script.
Imagine the following:

=over 4

=item Breaking command line limits

A script may offer a lot of options, with possibly a few of them
even taking parameters. If these options and their parameters
are passed onto the program call directly, the number of characters
accepted by your shells command line may be exceeded.

Perl itself does I<not> limit the number of characters passed to a
script by parameters, but the shell or command interpreter often
I<sets> a limit here. The same problem may occur if you want to
store a long call in a system file like crontab.

If such a limit restricts you, options and parameters may be moved into
option files, which will result in a shorter command line call.

=item Script calls prepared by scripts

Sometimes a script calls another script. The options passed onto the
nested script could depend on variable situations, such as a users
input or the detected environment. In such a case, it I<can> be easier
to generate an intermediate option file which is then passed to
the nested script.

Or imagine two cron jobs one preparing the other: the first may generate
an option file which is then used by the second.

=item Simple access to typical calling scenarios

If several options need to be set, but in certain circumstances
are always the same, it could become sligthly nerveracking to type
them in again and again. With an option file, they can be stored
I<once> and recalled easily as often as necessary.

Further more, option files may be used to group options. Several
settings may set up one certain behaviour of the program, while others
influence another. Or a certain set of options may be useful in one
typical situation, while another one should be used elsewhere. Or there
is a common set of options which has to be used in every call,
while other options are added depending on the current needs. Or there
are a few user groups with different but typical ways to call your script.
In all these cases, option files may collect options belonging together,
and may be combined by the script users to set up a certain call.
In conjunction with the possiblity to I<nest> such collections, this is
perhaps the most powerful feature provided by this method.

=item Individual and installationwide default options

The module allows the programmer to enable user setups of default options;
for both individual users or generally I<all> callers of a script.
This is especially useful for administrators who can configure the
I<default> behaviour of a script by setting up its installationwide
startup option file. All script users are free then to completely
forget every already configured setup option. And if one of them regularly
adds certain options to every call, he could store them in his I<individual>
startup option file.

For example, I use this feature to make my scripts both flexible I<and>
usable. I have several scripts accessing a database via DBI. The database
account parameters as well as the DBI startup settings should not be coded
inside the scripts because this is not very flexible, so I implemented
them by options. But on the other hand, there should be no need for a normal
user to pass all these settings to every script call. My solution for this
is to use I<default> option files set up and maintained by an administrator.
This is very transparent, most of the users know nothing of these
(documented ;-) configuration settings ... and if anything changes, only the
option files have to be adapted.

=back

=cut

# PACKAGE SECTION  ###############################################

# force Perl version
require 5.003;

# declare namespace
package Getopt::ArgvFile;

# declare your revision (and use it to avoid a warning)
$VERSION="1.01";
$VERSION=$VERSION;

=head1 EXPORTS

No symbol is exported by default, but you may explicitly import
the "argvFile()" function.

Example:

  use Getopt::ArgvFile qw(argvFile);

=cut

# export something
require Exporter;
@ISA=qw(Exporter);
@EXPORT_OK=qw(argvFile);

# CODE SECTION  ##################################################

# set pragmas
use strict;

# load libraries
use Carp;
use File::Basename;
use Text::ParseWords;

# METHOD SECTION  ################################################

=head1 FUNCTIONS

=head2 argvFile()

Scans the command line parameters (stored in @ARGV) for option file hints
(see I<Basics> below), reads the pointed files and makes their contents part
of @ARGV replacing the hints.

B<Basics>

An option file hint is simply the filename preceeded by (at least) one
"@" character:

  > script -optA argA -optB @optionFile -optC argC

This will cause argvFile() to scan "optionFile" for options.
The element "@optionFile" will be removed from the @ARGV array and
will be replaced by the options found.

An option file which cannot be found is quietly skipped.

Well, what's I<within> an option file? It is intended to
store I<command line arguments> which should be passed to the called
script. They can be stored exactly as they would be written in
the command line, but may be spread to multiple lines. To make the
file more readable, space and comment lines (starting with a "#")
are allowed additionally. For example, the call

  > script -optA argA -optB -optC cArg par1 par2

could be transformed into

  > script @scriptOptions par1 par2

where the file "scriptOptions" may look like this:

  # option a
  -optA argA

C<>

  # option b
  -optB

C<>

  # option c
  -optC cArg

B<Nested option files>

Option files can be nested. Recursion is avoided globally, that means
that every file will be opened only I<once> (the first time argvFile() finds
a hint pointing to it). This is the simplest implementation, indeed, but
should be suitable. (Unfortunately, there are I<LIMITS>.)

By using this feature, you may combine groups of typical options into
a top level option file, e.g.:

  File ab:

C<>

  # option a
  -optA argA
  # option b
  -optB

C<>

  File c:

C<>

  # option c
  -optC cArg

C<>

  File abc:

C<>

  # combine ab and c
  @ab @c

If anyone provides these files, a user can use a very short call:

  > script @abc

and argvFile() will recursively move all the filed program parameters
into @ARGV.

B<Startup support>

By setting several named parameters, you can enable I<default>
and I<home> option files. Both are searched with the scriptname preceeded
by a dot. The I<default option file> is searched in the installation path
of the calling script, while the I<home option file> is searched in the
users home (evaluated via environment variable "HOME").

 Examples:
  If called in a script "/path/script" by "user" whoms "HOME"
  variable points to "/homes/user", the following happens:

C<>

  argvFile()                    ignores startup option files;
  argvFile(default=>1)          searches and expands "/path/.script",
                                if available (the "default" settings);
  argvFile(home=>1)             searches and expands "/homes/user/.script",
                                if available (the "home" settings);
  argvFile(default=>1, home=>1) tries to handle both startups.

Any true value will activate the setting it is assigned to.

The contents found in a startup file is placed I<before> all explicitly
set command line arguments. This enables to overwrite a default setting
by an explicit option. If both startup files are read, I<home> startup
files can overwrite I<default> ones, so that the I<default> startups are
most common. In other words, if the module would not support startup
files, you could get the same result with
"script @/path/.script @/homes/user/.script".

If there is no I<HOME> environment variable, the I<home> setting takes no effect
to avoid trouble accessing the root directory.

B<Cascades>

The function supports multi-level (or so called I<cascaded>) option files.
If a filename in an option file hint starts with a "@" again, this complete
name is the resolution written back to @ARGV - assuming there will be
another utility reading option files.

 Examples:
  @rfile          rfile will be opened, its contents is
                  made part of @ARGV.
  @@rfile         cascade: "@rfile" is written back to
                  @ARGV assuming that there is a subsequent
                  tool called by the script to which this
                  hint will be passed to solve it by an own
                  call of argvFile().

The number of cascaded hints is unlimited.

=cut
sub argvFile
 {
  # declare function variables
  my ($maskString, $i, %rfiles, %startup)=("\0x07\0x06\0x07");

  # detect the host system (to prepare filename handling)
  my $casesensitiveFilenames=$^O!~/^(?:dos|os2|MSWin32)/i;

  # check and get parameters
  confess("[BUG] Number of parameters should be even") if @_ % 2;
  my %switches=@_;

  # init startup file pathes
  ($startup{'default'}{'path'}, $startup{'home'}{'path'})=(dirname($0), exists $ENV{'HOME'} ? $ENV{'HOME'} : \007);

  # check all possible startup files for usage - be careful to handle
  # them in the following order (implemented by alphabetical order here!):
  # FIRST, the HOME startup should be read, THEN the DEFAULT one - this way,
  # all startup options are placed before command line ones, and the
  # HOME settings can overwrite the DEFAULT ones - which are the most common
  foreach (reverse sort keys %startup)
	{
	 # anything to do?
	 if (exists $switches{$_} and $startup{$_}{'path'} ne \007)
	   {
		# build absolute startup filename
		my $cfg=join('', $startup{$_}{'path'}, '/.', basename($0));

		# if there's a configuration file, let's proceed it first - this way,
		# command line options can overwrite configuration settings
		unshift @ARGV, join('', '@', $cfg) if -e $cfg;
	   }
	}

  # nesting ...
  while (grep(/^\@/, @ARGV))
	{
	 # declare scope variables
	 my (%nr, @c, $c);

	 # scan @ARGV for option file hints
	 for ($i=0; $i<@ARGV; $i++)
	   {$nr{$i}=1 if substr($ARGV[$i], 0, 1) eq '@';}

	 for ($i=0; $i<@ARGV; $i++)
	   {
		if ($nr{$i})
		  {
		   # an option file - handle it

		   # remove the option hint
		   $ARGV[$i]=~s/\@//;

		   # if there is still an option file hint in the name of the file,
		   # this is a cascaded hint - insert it with a special temporary
		   # hint (has to be different from"@" to avoid a subsequent solution
		   # by this loop)
		   push(@c, $ARGV[$i]), next if $ARGV[$i]=~s/^@/$maskString/;

		   # skip nonexistent or recursively nested files
		   next if !-e $ARGV[$i] || -d _ || $rfiles{$casesensitiveFilenames ? $ARGV[$i] : lc($ARGV[$i])};

		   # store filename to avoid recursion
		   $rfiles{$casesensitiveFilenames ? $ARGV[$i] : lc($ARGV[$i])}=1;

		   # open file and read its contents
		   open(OPT, $ARGV[$i]);
		   while (<OPT>)
			 {
			  # skip space and comment lines
			  next if /^\s*$/ || /^\s*#/;
			  # remove newlines, leading and trailing spaces
			  s/\s*\n?$//; s/^\s*//;
			  # store options and parameters
			  push(@c, shellwords($_));
			 }
		  }
		else
		  {
		   # a normal option or parameter - handle it
		   push(@c, $ARGV[$i]);
		  }
	   }

	 # replace @ARGV by expanded @ARGV
	 @ARGV=@c;
	}

  # reset hint character in cascaded hints to "@"
  @ARGV=map {s/^$maskString/@/; $_} @ARGV;
 }

# flag this module was read successfully
1;

# POD TRAILER ####################################################

=head1 LIMITS

If an option file does not exist, argvFile() simply ignores it.
No message will be displayed, no special return code will be set.

=head1 AUTHOR

Jochen Stenzel E<lt>mailto://jochen.stenzel@t-online.deE<gt>

=head1 COPYRIGHT

Copyright (c) 1993-99 Jochen Stenzel. All rights reserved.

This program is free software, you can redistribute it and/or modify it
under the terms of the Artistic License distributed with Perl version
5.003 or (at your option) any later version. Please refer to the
Artistic License that came with your Perl distribution for more
details.

=cut
