####################################################################
#
#    This file was generated using Parse::Yapp version 1.01.
#
#        Don't edit this file, use source file instead.
#
#             ANY CHANGE MADE HERE WILL BE LOST !
#
####################################################################
package PerlPoint::Parser;
use vars qw ( @ISA );
use strict;

@ISA= qw ( Parse::Yapp::Driver );
#Included Parse/Yapp/Driver.pm file----------------------------------------
{
#
# Module Parse::Yapp::Driver
#
# This module is part of the Parse::Yapp package available on your
# nearest CPAN
#
# Any use of this module in a standalone parser make the included
# text under the same copyright as the Parse::Yapp module itself.
#
# This notice should remain unchanged.
#
# (c) Copyright 1998-1999 Francois Desarmenien, all rights reserved.
# (see the pod text in Parse::Yapp module for use and distribution rights)
#

package Parse::Yapp::Driver;

require 5.004;

use strict;

use vars qw ( $VERSION $COMPATIBLE $FILENAME );

$VERSION = '1.01';
$COMPATIBLE = '0.07';
$FILENAME=__FILE__;

use Carp;

#Known parameters, all starting with YY (leading YY will be discarded)
my(%params)=(YYLEX => 'CODE', 'YYERROR' => 'CODE', YYVERSION => '',
			 YYRULES => 'ARRAY', YYSTATES => 'ARRAY', YYDEBUG => '');
#Mandatory parameters
my(@params)=('LEX','RULES','STATES');

sub new {
    my($class)=shift;
	my($errst,$nberr,$token,$value,$check,$dotpos);
    my($self)={ ERROR => \&_Error,
				ERRST => \$errst,
                NBERR => \$nberr,
				TOKEN => \$token,
				VALUE => \$value,
				DOTPOS => \$dotpos,
				STACK => [],
				DEBUG => 0,
				CHECK => \$check };

	_CheckParams( [], \%params, \@_, $self );

		exists($$self{VERSION})
	and	$$self{VERSION} < $COMPATIBLE
	and	croak "Yapp driver version $VERSION ".
			  "incompatible with version $$self{VERSION}:\n".
			  "Please recompile parser module.";

        ref($class)
    and $class=ref($class);

    bless($self,$class);
}

sub YYParse {
    my($self)=shift;
    my($retval);

	_CheckParams( \@params, \%params, \@_, $self );

	if($$self{DEBUG}) {
		_DBLoad();
		$retval = eval '$self->_DBParse()';#Do not create stab entry on compile
        $@ and die $@;
	}
	else {
		$retval = $self->_Parse();
	}
    $retval
}

sub YYData {
	my($self)=shift;

		exists($$self{USER})
	or	$$self{USER}={};

	$$self{USER};
	
}

sub YYErrok {
	my($self)=shift;

	${$$self{ERRST}}=0;
    undef;
}

sub YYNberr {
	my($self)=shift;

	${$$self{NBERR}};
}

sub YYRecovering {
	my($self)=shift;

	${$$self{ERRST}} != 0;
}

sub YYAbort {
	my($self)=shift;

	${$$self{CHECK}}='ABORT';
    undef;
}

sub YYAccept {
	my($self)=shift;

	${$$self{CHECK}}='ACCEPT';
    undef;
}

sub YYError {
	my($self)=shift;

	${$$self{CHECK}}='ERROR';
    undef;
}

sub YYSemval {
	my($self)=shift;
	my($index)= $_[0] - ${$$self{DOTPOS}} - 1;

		$index < 0
	and	-$index <= @{$$self{STACK}}
	and	return $$self{STACK}[$index][1];

	undef;	#Invalid index
}

sub YYCurtok {
	my($self)=shift;

        @_
    and ${$$self{TOKEN}}=$_[0];
    ${$$self{TOKEN}};
}

sub YYCurval {
	my($self)=shift;

        @_
    and ${$$self{VALUE}}=$_[0];
    ${$$self{VALUE}};
}

sub YYExpect {
    my($self)=shift;

    keys %{$self->{STATES}[$self->{STACK}[-1][0]]{ACTIONS}}
}



#################
# Private stuff #
#################


sub _CheckParams {
	my($mandatory,$checklist,$inarray,$outhash)=@_;
	my($prm,$value);
	my($prmlst)={};

	while(($prm,$value)=splice(@$inarray,0,2)) {
        $prm=uc($prm);
			exists($$checklist{$prm})
		or	croak("Unknow parameter '$prm'");
			ref($value) eq $$checklist{$prm}
		or	croak("Invalid value for parameter '$prm'");
        $prm=unpack('@2A*',$prm);
		$$outhash{$prm}=$value;
	}
	for (@$mandatory) {
			exists($$outhash{$_})
		or	croak("Missing mandatory parameter '".lc($_)."'");
	}
}

sub _Error {
	print "Parse error.\n";
}

sub _DBLoad {
	{
		no strict 'refs';

			exists(${__PACKAGE__.'::'}{_DBParse})#Already loaded ?
		and	return;
	}
	my($fname)=__FILE__;
	my(@drv);
	open(DRV,"<$fname") or die "Report this as a BUG: Cannot open $fname";
	while(<DRV>) {
                	/^\s*sub\s+_Parse\s*{\s*$/ .. /^\s*}\s*#\s*_Parse\s*$/
        	and     do {
                	s/^#DBG>//;
                	push(@drv,$_);
        	}
	}
	close(DRV);

	$drv[0]=~s/_P/_DBP/;
	eval join('',@drv);
}

#Note that for loading debugging version of the driver,
#this file will be parsed from 'sub _Parse' up to '}#_Parse' inclusive.
#So, DO NOT remove comment at end of sub !!!
sub _Parse {
    my($self)=shift;

	my($rules,$states,$lex,$error)
     = @$self{ 'RULES', 'STATES', 'LEX', 'ERROR' };
	my($errstatus,$nberror,$token,$value,$stack,$check,$dotpos)
     = @$self{ 'ERRST', 'NBERR', 'TOKEN', 'VALUE', 'STACK', 'CHECK', 'DOTPOS' };

#DBG>	my($debug)=$$self{DEBUG};
#DBG>	my($dbgerror)=0;

#DBG>	my($ShowCurToken) = sub {
#DBG>		my($tok)='>';
#DBG>		for (split('',$$token)) {
#DBG>			$tok.=		(ord($_) < 32 or ord($_) > 126)
#DBG>					?	sprintf('<%02X>',ord($_))
#DBG>					:	$_;
#DBG>		}
#DBG>		$tok.='<';
#DBG>	};

	$$errstatus=0;
	$$nberror=0;
	($$token,$$value)=(undef,undef);
	@$stack=( [ 0, undef ] );
	$$check='';

    while(1) {
        my($actions,$act,$stateno);

        $stateno=$$stack[-1][0];
        $actions=$$states[$stateno];

#DBG>	print STDERR ('-' x 40),"\n";
#DBG>		$debug & 0x2
#DBG>	and	print STDERR "In state $stateno:\n";
#DBG>		$debug & 0x08
#DBG>	and	print STDERR "Stack:[".
#DBG>					 join(',',map { $$_[0] } @$stack).
#DBG>					 "]\n";


        if  (exists($$actions{ACTIONS})) {

				defined($$token)
            or	do {
				($$token,$$value)=&$lex($self);
#DBG>				$debug & 0x01
#DBG>			and	print STDERR "Need token. Got ".&$ShowCurToken."\n";
			};

            $act=   exists($$actions{ACTIONS}{$$token})
                    ?   $$actions{ACTIONS}{$$token}
                    :   exists($$actions{DEFAULT})
                        ?   $$actions{DEFAULT}
                        :   undef;
        }
        else {
            $act=$$actions{DEFAULT};
#DBG>			$debug & 0x01
#DBG>		and	print STDERR "Don't need token.\n";
        }

            defined($act)
        and do {

                $act > 0
            and do {        #shift

#DBG>				$debug & 0x04
#DBG>			and	print STDERR "Shift and go to state $act.\n";

					$$errstatus
				and	do {
					--$$errstatus;

#DBG>					$debug & 0x10
#DBG>				and	$dbgerror
#DBG>				and	$$errstatus == 0
#DBG>				and	do {
#DBG>					print STDERR "**End of Error recovery.\n";
#DBG>					$dbgerror=0;
#DBG>				};
				};


                push(@$stack,[ $act, $$value ]);

					$$token ne ''	#Don't eat the eof
				and	$$token=$$value=undef;
                next;
            };

            #reduce
            my($lhs,$len,$code,@sempar,$semval);
            ($lhs,$len,$code)=@{$$rules[-$act]};

#DBG>			$debug & 0x04
#DBG>		and	$act
#DBG>		and	print STDERR "Reduce using rule ".-$act." ($lhs,$len): ";

                $act
            or  $self->YYAccept();

            $$dotpos=$len;

                unpack('A1',$lhs) eq '@'    #In line rule
            and do {
                    $lhs =~ /^\@[0-9]+\-([0-9]+)$/
                or  die "In line rule name '$lhs' ill formed: ".
                        "report it as a BUG.\n";
                $$dotpos = $1;
            };

            @sempar =       $$dotpos
                        ?   map { $$_[1] } @$stack[ -$$dotpos .. -1 ]
                        :   ();


            $semval = $code ? &$code( $self, @sempar )
                            : @sempar ? $sempar[0] : undef;

            splice(@$stack,-$len,$len);

                $$check eq 'ACCEPT'
            and do {

#DBG>			$debug & 0x04
#DBG>		and	print STDERR "Accept.\n";

				return($semval);
			};

                $$check eq 'ABORT'
            and	do {

#DBG>			$debug & 0x04
#DBG>		and	print STDERR "Abort.\n";

				return(undef);

			};

#DBG>			$debug & 0x04
#DBG>		and	print STDERR "Back to state $$stack[-1][0], then ";

                $$check eq 'ERROR'
            or  do {
#DBG>				$debug & 0x04
#DBG>			and	print STDERR 
#DBG>				    "go to state $$states[$$stack[-1][0]]{GOTOS}{$lhs}.\n";

#DBG>				$debug & 0x10
#DBG>			and	$dbgerror
#DBG>			and	$$errstatus == 0
#DBG>			and	do {
#DBG>				print STDERR "**End of Error recovery.\n";
#DBG>				$dbgerror=0;
#DBG>			};

			    push(@$stack,
                     [ $$states[$$stack[-1][0]]{GOTOS}{$lhs}, $semval ]);
                next;
            };

#DBG>			$debug & 0x04
#DBG>		and	print STDERR "Forced Error recovery.\n";

            $$check='';
        };

        #Error
            $$errstatus
        or   do {

#DBG>			$debug & 0x10
#DBG>		and	do {
#DBG>			print STDERR "**Entering Error recovery.\n";
#DBG>			++$dbgerror;
#DBG>		};

            ++$$nberror;
            &$error($self);
        };

			$$errstatus == 3	#The next token is not valid: discard it
		and	do {
				$$token eq ''	# End of input: no hope
			and	do {
#DBG>				$debug & 0x10
#DBG>			and	print STDERR "**At eof: aborting.\n";
				return(undef);
			};

#DBG>			$debug & 0x10
#DBG>		and	print STDERR "**Dicard invalid token ".&$ShowCurToken.".\n";

			$$token=$$value=undef;
		};

        $$errstatus=3;

		while(	  @$stack
			  and (		not exists($$states[$$stack[-1][0]]{ACTIONS})
			        or  not exists($$states[$$stack[-1][0]]{ACTIONS}{error})
					or	$$states[$$stack[-1][0]]{ACTIONS}{error} <= 0)) {

#DBG>			$debug & 0x10
#DBG>		and	print STDERR "**Pop state $$stack[-1][0].\n";

			pop(@$stack);
		}

			@$stack
		or	do {

#DBG>			$debug & 0x10
#DBG>		and	print STDERR "**No state left on stack: aborting.\n";

			return(undef);
		};

		#shift the error token

#DBG>			$debug & 0x10
#DBG>		and	print STDERR "**Shift \$error token and go to state ".
#DBG>						 $$states[$$stack[-1][0]]{ACTIONS}{error}.
#DBG>						 ".\n";

		push(@$stack, [ $$states[$$stack[-1][0]]{ACTIONS}{error}, undef ]);

    }

    #never reached
	croak("Error in driver logic. Please, report it as a BUG");

}#_Parse
#DO NOT remove comment

1;

}
#End of include--------------------------------------------------


#line 10 "ppParser.yp"


# = HISTORY SECTION =====================================================================

# ---------------------------------------------------------------------------------------
# version | date     | author   | changes
# ---------------------------------------------------------------------------------------
# 0.35    |16.06.2001| JSTENZEL | text paragraphs containing an image only are now
#         |          |          | transformed into just the image;
# 0.34    |14.03.2001| JSTENZEL | added parsing time report;
#         |          | JSTENZEL | slight code optimizations;
#         |20.03.2001| JSTENZEL | introduced tag templates declared via PerlPoint::Tags:
#         |22.03.2001| JSTENZEL | bugfix: macros could not contain "0":
#         |          | JSTENZEL | comments are now read at once, no longer lexed and parsed,
#         |          |          | likewise, verbatim block lines are handled as one word;
#         |25.03.2001| JSTENZEL | special character activation in tags is now nearer to the
#         |          |          | related grammatical constructs, so "<" is no longer a
#         |          |          | special after the tag body is opened;
#         |          | JSTENZEL | completed tag template interface by checks of mandatory 
#         |          |          | parts and hooks into the parser to check options and body;
#         |01.04.2001| JSTENZEL | paragraphs using macros or variables are cached now -
#         |          |          | they can be reused unless macro/variable settings change;
#         |          | JSTENZEL | cache structure now stores parser version for compatibility
#         |          |          | checks;
#         |08.04.2001| JSTENZEL | removed ACCEPT_ALL support;
#         |          | JSTENZEL | improved special character handling in tag recognition
#         |          |          | furtherly: "=" is now very locally specialized;
#         |          | JSTENZEL | tag option and body hooks now take the tag occurence line
#         |          |          | number as their first argument, not the tag name which is
#         |          |          | of course already known to the hook function author;
#         |          | JSTENZEL | The new macro caching feature allowed to improve the cache
#         |          |          | another way: constructions looking like a tag or macro but
#         |          |          | being none of them were streamed and cached like strings
#         |          |          | (because they *were* strings). If later on somebody declared
#         |          |          | such a macro, the cache still found the paragraph unchanged
#         |          |          | (same checksum) and reused the old stream instead of building
#         |          |          | a new stream on base of the resolved macro. Now, if something
#         |          |          | looks like a macro, the macro cache checksum feature is
#         |          |          | activated, so every later macro definition will prevent the
#         |          |          | cached string representation of being reused. Instead of
#         |          |          | this, the new macro will be resolved, and the new resulting
#         |          |          | paragraph stream will be cached. This is by far more
#         |          |          | transparent and intuitive.
#         |11.04.2001| JSTENZEL | added predeclared variables;
#         |19.04.2001| JSTENZEL | embedded Perl code offering no code is ignored now;
#         |21.04.2001| JSTENZEL | replaced call to Parse::Yapps parser object method YYData()
#         |          |          | by direct access to its built in hash entry USER as suggested
#         |          |          | by the Parse::Yapp manual for reasons of efficiency;
#         |          | JSTENZEL | bugfix: all parts restored from @inputStack were handled as
#         |          |          | new lines which caused several unnecessay operations including
#         |          |          | line number updates, cache paragraph checksumming and
#         |          |          | removal of "leading" whitespaces (tokens recognized as Ils
#         |          |          | while we were still in a formerly started line) - this fix
#         |          |          | should accelerate processing of documents using numerous
#         |          |          | macros (when cached) and of course avoid invalid token removals;
#         |          | JSTENZEL | tables are now "normalized": if a table row contains less
#         |          |          | columns than the headline row, the missed columns are
#         |          |          | automatically added (this helps converters to detect empty columns);
#         |          | JSTENZEL | bugfix: internal table flags were not all reset if a table
#         |          |          | was completed, thus causing streams for subsequent tables
#         |          |          | being built with additional, incorrect elements;
#         |          | JSTENZEL | adapted macro handling to the new tag handling: if now options or
#         |          |          | or body was declared in the macro definition, options or body are
#         |          |          | not evaluated
#         |22.04.2001| JSTENZEL | the first bugfix yesterday was too common, improved;
#         |24.04.2001| JSTENZEL | bugfix: conditions were handled in headline state, causing
#         |          |          | backslashes to be removed; new state STATE_CONDITION added;
#         |          | JSTENZEL | added first function (flagSet()) of a simplified condition
#         |          |          | interface (SCI) which is intended to allow non (Perl) programmers
#         |          |          | to easily understand and perform common checks;
#         |27.04.2001| JSTENZEL | $^W is a global variable - no need to switch to the Safe
#         |          |          | compartment to modify it;
#         |          | JSTENZEL | added next function (varValue()) of a the SCI;
#         |29.04.2001| JSTENZEL | now the parser predeclares variables as well: first one is
#         |          |          | $_STARTDIR to flag where processing started;
#         |21.05.2001| JSTENZEL | bugfix in table handling: one column tables were not handled
#         |          |          | correctly, modified table handling partly by the way si that
#         |          |          | in the future it might become possible to have nested tables;
#         |22.05.2001| JSTENZEL | source nesting level is now reported by an internal variable _SOURCE_LEVEL;
#         |23.05.2001| JSTENZEL | table fields are trimmed now: beginning and trailing whitespaces are removed;
#         |24.05.2001| JSTENZEL | text paragraphs containing only a table become just a table now;
#         |24.05.2001| JSTENZEL | text paragraphs now longer contain a final whitespace (made from the
#         |          |          | final carriage return;
#         |25.05.2001| JSTENZEL | completed support for the new \TABLE flag option "rowseparator" which
#         |          |          | allows you to separate table columns by a string of your choice enabling
#         |          |          | streamed tables like in
#         |          |          | "Look: \TABLE{rowseparator="+++"} c1 | c2 +++ row 2, 1 | row 2, 2 \END_TABLE";
#         |          | JSTENZEL | slightly reorganized the way tag build table streams are completed,
#         |          |          | enabling a more common detection of prebuild stream parts - in fact, if
#         |          |          | this description makes no sense to you, this enables to place \END_TABLE
#         |          |          | even *in* the final table line instead of in a new line (as usually done
#         |          |          | and documented);
#         |26.05.2001| JSTENZEL | added new parser option "nestedTables" which enables table nesting if set
#         |          |          | to a true value. made nesting finally possible;
#         |          | JSTENZEL | to help converters handling nested tables, tables now provide their
#         |          |          | nesting level by the new internal table option "__nestingLevel__";
#         |27.05.2001| JSTENZEL | cache hits are no longer mentioned in the list of expected tokens displayed
#         |          |          | by _Error(), because the message is intended to be read by humans who
#         |          |          | cannot insert cache hits into a document;
#         |28.05.2001| JSTENZEL | new predeclared variable _PARSER_VERSION;
#         |          | JSTENZEL | new \INCLUDE option "localize";
#         |31.05.2001| JSTENZEL | new headline level offset keyword "base_level";
#         |01.06.2001| JSTENZEL | performance boost by lexing words no longer as real words or even
#         |          |          | characters but as the longest strings until the next special character;
#         |02.06.2001| JSTENZEL | improved table field trimming in normalizeTableRows();
#         |05.06.2001| JSTENZEL | the last line in a source file is now lexed the optimized way as well;
#         |06.06.2001| JSTENZEL | cache structure now stores constant declarations version for compatability
#         |          |          | checks;
#         |09.06.2001| JSTENZEL | bugfix: headlines could not begin with a character that can start a
#         |          |          | paragraph - fixed by introducing new state STATE_HEADLINE_LEVEL;
#         |          | JSTENZEL | variable names can contain umlauts now;
#         |          | JSTENZEL | updated inlined module documentation (POD);
#         |          | JSTENZEL | used Storable version is now stored in cache, cache is rebuilt
#         |          |          | automatically if a different Storable version is detected;
#         |10.06.2001| JSTENZEL | added code execution by eval() (on users request);
#         |12.06.2001| JSTENZEL | code executed by eval() or do() is no started with "no strict" settings
#         |          |          | to enable unlimited access to functions, like under Safe control
#         |          |          | (also this is by no means optimal so it might be improved later);
#         |          | JSTENZEL | tag hooks can reply various values now;
#         |15.06.2001| JSTENZEL | tags take exactly *one* hook into consideration now: this simplifies
#         |          |          | and accelerates the interface *and* allows hooks for tags neither
#         |          |          | owning option nor nody;
# 0.33    |22.02.2001| JSTENZEL | slightly improved PerlPoint::Parser::DelayedToken;
#         |25.02.2001| JSTENZEL | variable values can now begin with every character;
#         |13.03.2001| JSTENZEL | bugfix in handling cache hits for continued ordered lists:
#         |          |          | list numbering is updated now;
#         |14.03.2001| JSTENZEL | added mailing list hint to POD;
#         |          | JSTENZEL | undefined return values of embedded Perl are no longer
#         |          |          | tried to be parsed, this is for example useful to
#         |          |          | predeclare functions;
#         |          | JSTENZEL | slight bugfix in internal ordered list counting which
#         |          |          | takes effect if an ordered list is *started* by "##";
# 0.32    |07.02.2001| JSTENZEL | bugfix: bodyless macros can now be used without moving
#         |          |          | subsequent tokens before the macro replacement;
#         |10.02.2001| JSTENZEL | added new special type "example" to \INCLUDE to relieve
#         |          |          | people who want to include files just as examples;
# 0.31    |30.01.2001| JSTENZEL | ordered lists now provide the entry level number
#         |          |          | (additionally to the first list point which already
#         |          |          | did this if the list was continued);
#         |01.02.2001| JSTENZEL | made POD more readable to pod2man;
#         |          | JSTENZEL | bugfix: if a headline is restored from cache, internal
#         |          |          | headline level flags need to be restored as well to
#         |          |          | make \INCLUDE{headlinebase=CURRENT_LEVEL} work when
#         |          |          | it is the first thing in a document except of headlines
#         |          |          | which are all restored from cache;
#         |          | JSTENZEL | new "smart" option of \INCLUDE tag suppresses inclusion
#         |          |          | if the file was already loaded, which is useful for alias
#         |          |          | definitions used both in a nested and the base source;
#         |02.02.2001| JSTENZEL | bugfix: circular source nesting was supressed too hard:
#         |          |          | a source could never be loaded twice, but this may be
#         |          |          | really useful to reuse files multiply - now only the
#         |          |          | currently nested sources are taken into account;
#         |03.02.2001| JSTENZEL | bugfix: continued lists did not work as expected yet,
#         |          |          | now they do (bug was detected by Lorenz), improved by
#         |          |          | the way: continued list points not really continuing
#         |          |          | are streamed now as usual list points (no level hint);
# 0.30    |05.01.2001| JSTENZEL | slight lexer improvement (removed obsolete code);
#         |          | JSTENZEL | modified the grammar a way that shift/reduce conflicts
#         |          |          | were reduced (slightly) and, more important, the grammar
#         |          |          | now passes yacc/bison (just a preparation);
#         |20.01.2001| JSTENZEL | variable settings are now propagated into the stream;
#         |          | JSTENZEL | improved syntactical error messages;
#         |23.01.2001| JSTENZEL | bugfix: embedding into tags failed because not all
#         |          |          | special settings were restored correctly, especially
#         |          |          | for ">" which completes a tag body;
#         |27.01.2001| JSTENZEL | fixed "unintialized value" warning (cache statistics);
#         |          | JSTENZEL | tag implementation is now more restrictive: according
#         |          |          | to the language definition tag and macro names now *have*
#         |          |          | to be built from capitals and underscores, thus reducing
#         |          |          | potential tag recognition confusion with ACCEPT_ALL;
#         |          | JSTENZEL | lowercased alias names in alias definitions are now
#         |          |          | automatically converted into capitals because of the
#         |          |          | modfied tag/macro recognition just mentioned before;
#         |          | JSTENZEL | POD: added a warning to the POD section that the cache
#         |          |          | should be cleansed after introducing new macros which
#         |          |          | could possibly be used as simple text before;
# 0.29    |21.12.2000| JSTENZEL | direct setting of $VERSION variable to enable CPAN to
#         |          |          | detect and display the parser module version;
#         |          | JSTENZEL | introduced base settings for active contents provided
#         |          |          | in %$PerlPoint - a new common way to pass things like
#         |          |          | the current target language;
#         |27.12.2000| JSTENZEL | closing angle brackets are to be guarded only *once*
#         |          |          | now - in former versions each macro level added the need
#         |          |          | of yet another backslash;
#         |28.12.2000| JSTENZEL | macro bodies are no longer reparsed which accelerates
#         |          |          | procesing of nested macros drastically (and avoids the
#         |          |          | overhead and dangers of rebuilding a source string and
#         |          |          | parsing it again - this way, parsing becomes easier to
#         |          |          | maintain in case of syntax extensions (nevertheless, the
#         |          |          | old code worked well!);
# 0.28    |14.12.2000| JSTENZEL | made it finally backward compatible to perl 5.005 again;
# 0.27    |07.12.2000| JSTENZEL | moved package namespace from "PP" to "PerlPoint";
# 0.26    |30.11.2000| JSTENZEL | "Perl Point" => "PerlPoint";
#         |02.12.2000| JSTENZEL | bugfix in stackInput() which could remove input lines;
#         |          | JSTENZEL | new headline level offset keyword "current_level";
#         |03.12.2000| JSTENZEL | the parser now changes into a sourcefiles directory thus
#         |          |          | getting able to follow relative paths in nested sources;
#         |          | JSTENZEL | bugfix in input stack: must be multi levelled - we need
#         |          |          | one input stack per processed source!;
#         |          | JSTENZEL | cache data now contains headline level informations;
# 0.25    |22.11.2000| JSTENZEL | added notes about Storable updates;
#         |24.11.2000| JSTENZEL | bugfix in caching of embedded parts including empty lines;
#         |          | JSTENZEL | bugfix in modified ordered point intro handling;
#         |27.11.2000| JSTENZEL | bugfix in progress visualization;
#         |          | JSTENZEL | improved progress visualization;
#         |          | JSTENZEL | new experimental tag setting "\ACCEPT_ALL";
# 0.24    |10.11.2000| JSTENZEL | added incremental parsing ("caching");
#         |18.11.2000| JSTENZEL | slightly simplified the code;
#         |          | JSTENZEL | added ordered list continuations;
# 0.23    |28.10.2000| JSTENZEL | bugfix: indentation in embedded code was not accepted;
#         |          | JSTENZEL | using an input stack now for improved embedding;
#         |          | JSTENZEL | tracing active contents now;
# 0.22    |21.10.2000| JSTENZEL | new \INCLUDE headline offset parameter;
#         |25.10.2000| JSTENZEL | bugfixes in trace code;
#         |          | JSTENZEL | modified implementation of included file handling:
#         |          |          | reopening a handle did not work in all cases with perl5.6;
# 0.21    |11.10.2000| JSTENZEL | improved table paragraphs;
#         |14.10.2000| JSTENZEL | added alias/macro feature;
# 0.20    |10.10.2000| JSTENZEL | added table paragraphs;
# 0.19    |08.10.2000| JSTENZEL | added condition paragraphs;
#         |09.10.2000| JSTENZEL | bugfix in table handling: generated stream was wrong;
# 0.18    |05.10.2000| JSTENZEL | embedded Perl code is evaluated now, method run() takes
#         |          |          | a Safe object;
#         |07.10.2000| JSTENZEL | Perl code can now be included as well as embedded;
#         |          | JSTENZEL | variable values are now accessible by embedded and
#         |          |          | included Perl code;
#         |          | JSTENZEL | PerlPoint can now be embedded as well as included;
# 0.17    |04.10.2000| JSTENZEL | bugfix in documentation: colons have not to be guarded
#         |          |          | in definition texts;
#         |          | JSTENZEL | bugfixes in special token handling;
# 0.16    |30.09.2000| JSTENZEL | updated documentation;
#         |          | JSTENZEL | bugfix in special token handling;
#         |03.10.2000| JSTENZEL | definition list items can contain tags now;
#         |04.10.2000| JSTENZEL | added new target language filter feature;
# 0.15    |06.06.2000| JSTENZEL | there were still 5.6 specific operations, using
#         |          |          | IO::File now as an emulation under perl 5.005;
# 0.14    |03.06.2000| JSTENZEL | improved handling of special tag characters to simplify
#         |          |          | PP writing;
#         |          | JSTENZEL | bugfixes: stream contained trailing whitespaces for
#         |          |          | list points and headlines;
#         |          | JSTENZEL | bugfix: empty lines in verbatim blocks were not
#         |          |          | streamed;
#         |          | JSTENZEL | bugfix: stream contained leading newline for verbatim
#         |          |          | blocks;
#         |05.06.2000| JSTENZEL | switched back to 5.005 open() syntax to become compatible;
# 0.13    |01.06.2000| JSTENZEL | made it 5.003 compatible again;
# 0.12    |27.05.2000| JSTENZEL | leading spaces in list point lines are suppressed now;
#         |          | JSTENZEL | bugfix in run(): did not supply correct a return code;
#         |          | JSTENZEL | bugfix: last semantic action must be a true value to
#         |          |          | flag success (to the parser);
# 0.11    |20.05.2000| JSTENZEL | completed embedding feature;
#         |21.05.2000| JSTENZEL | bugfix in semantic error counting;
#         |          | JSTENZEL | added include feature;
#         |27.05.2000| JSTENZEL | added table feature (first version);
# 0.10    |17.04.2000| JSTENZEL | still incomplete embedding code added;
#         |03.05.2000| JSTENZEL | bugfix: verbatim block opener was added to stream
#         |          |          | because of the modified syntax (not completely impl.);
# 0.09    |11.04.2000| JSTENZEL | reorganized verbatim block start: spaces between "&"
#         |          |          | and "<<TERMINATOR" are no longer allowed, but text
#         |          |          | paragraphs with a startup "&" character are allowed now;
#         |          | JSTENZEL | added new paragraph type "definition list point";
#         |14.04.2000| JSTENZEL | streamed lists are embedded into list directives now;
#         |15.04.2000| JSTENZEL | modified syntax of verbatim blocks;
#         |          | JSTENZEL | added variables;
#         |          | JSTENZEL | modified tag syntax into "\TAG[{parlist}][<body>]";
# 0.08    |04.04.2000| JSTENZEL | started to implement the new pp2xy concept;
#         |07.04.2000| JSTENZEL | headlines are terminated by a REAL empty line now;
#         |          | JSTENZEL | old "points" became "unordered list points";
#         |          | JSTENZEL | added new paragraph type "ordered list point";
#         |08.04.2000| JSTENZEL | built in list shifting;
#         |09.04.2000| JSTENZEL | bugfix in text paragraph rule;
#         |10.04.2000| JSTENZEL | blocks are combined now automatically unless there is an
#         |          |          | intermediate control paragraph;
# 0.07    |25.03.2000| JSTENZEL | tag length is now 1 to 8 characters (instead of 1 to 3);
#         |          | JSTENZEL | POD fixes;
#         |          | JSTENZEL | using CPAN id's in HOC now;
# 0.06    |24.02.2000| JSTENZEL | trailing whitespaces in input lines are now removed
#         |          |          | (except of newlines!);
# 0.05    |11.10.1999| JSTENZEL | bugfix: paragraphs generated array references;
#         |          | JSTENZEL | PP::Parser::Constants became PP::Constants;
#         |          | JSTENZEL | adapted POD to pod2text (needs more blank lines);
# 0.04    |09.10.1999| JSTENZEL | moved certain constants into PP::Parser::Constants;
#         |          | JSTENZEL | completed POD;
# 0.03    |08.10.1999| JSTENZEL | started to generate intermediate data;
#         |          | JSTENZEL | simplified array access;
#         |          | JSTENZEL | bugfixes;
#         |09.10.1999| JSTENZEL | added data generation;
#         |          | JSTENZEL | all messages are written in English now;
#         |          | JSTENZEL | tags are declared outside now;
#         |          | JSTENZEL | exported the script part;
#         |          | JSTENZEL | added statistics;
#         |          | JSTENZEL | added trace and display control;
# 0.02    |07.10.1999| JSTENZEL | added C tag;
#         |          | JSTENZEL | added comment traces;
#         |          | JSTENZEL | bugfixes;
#         |          | JSTENZEL | made it pass -w;
#         |          | JSTENZEL | new "verbatim" paragraph;
# 0.01    |28.09.1999| JSTENZEL | new.
# ---------------------------------------------------------------------------------------

# = POD SECTION =========================================================================

=head1 NAME

B<PerlPoint::Parser> - a PerlPoint Parser

=head1 VERSION

This manual describes version B<0.35>.

=head1 SYNOPSIS

  # load the module:
  use PerlPoint::Parser;

  # build the parser and run it
  # to get intermediate data in @stream
  my ($parser)=new PerlPoint::Parser;
  $parser->run(
               stream => \@stream,
               files  => \@files,
              );


=head1 DESCRIPTION

The PerlPoint format, initially designed by Tom Christiansen, is intended
to provide a simple and portable way to generate slides without the need of
a proprietary product. Slides can be prepared in a text editor of your choice,
generated on any platform where you find perl, and presented by any browser
which can render the chosen output format.

To sum it up,
I<PerlPoint Software takes an ASCII text and transforms it into slides written in a certain document description language.>
This is, by tradition, usually HTML, but you may decide to use another format like
XML, SGML, TeX or whatever you want.

Well, this sounds fine, but how to build a translator which transforms ASCII
into the output format of your choice? Thats what B<PerlPoint::Parser> is made for.
It performs the first translation step by parsing ASCII and transforming it
into an intermediate stream format, which can be processed by a subsequently
called translator backend. By separating parsing and output generation we
get the flexibility to write as many backends as necessary by using the same
parser frontend for all translators.

B<PerlPoint::Parser> supports the complete I<GRAMMAR> with exception of I<certain>
tags. Tags I<are> supported the I<most common way>: the parser recognizes I<any>
tag which is declared by the author of a translator. This way the
parser can be used for various flavours of the PerlPoint language without
having to be modified. So, if there is a need of a certain new flag, it can
quickly be added without any change to B<PerlPoint::Parser>.

The following chapters describe the input format (I<GRAMMAR>) and the
generated stream format (I<STREAM FORMAT>). Finally, the class methods are
described to show you how to build a parser.


=head1 GRAMMAR

This chapter describes how a PerlPoint ASCII slide description has to be
formatted to pass B<PerlPoint::Parser> parsers.

I<Please note> that the input format does I<not> completely determine how
the output will be designed. The final I<format> depends on the backend
which has to be called after the parser to transform its output into a
certain document description language. The final I<appearance> depends on
the I<browsers> behaviour.

Each PerlPoint document is made of I<paragraphs>.

=head2 The paragraphs

All paragraphs start at the beginning of their first line. The first character
or string in this line determines which paragraph is recognized.

A paragraph is completed by an empty line (which may contain whitespaces).
Exceptions are described.

Carriage returns in paragraphs which are completed by an empty line
are transformed into a whitespace.

=over 4

=item Comments

start with "//" and reach until the end of the line.


=item Headlines

start with one or more  "=" characters.
The number of "=" characters represents the headline level.

  =First level headline

  ==Second level headline

  ===Multi
    line
   headline
  example


=item Lists

B<Points> or B<unordered lists> start with a "*" character.

  * This is a first point.

  * And, I forgot,
    there is something more to point out.

There are B<ordered lists> as well, and I<they> start with a hash sign ("#"):

  # First, check the number of this.

  # Second, don't forget the first.

The hash signs are intended to be replaced by numbers by a backend.

Because PerlPoint works on base of paragraphs, any paragraph different to
an ordered list point I<closes an ordered list>. If you wish the list to
be continued use a double hash sign in case of the single one in the point
that reopens the list.

  # Here the ordered list begins.

  ? $includeMore

  ## This is point 2 of the list that started before.

  # In subsequent points, the usual single hash sign
    works as expected again.

List continuation works list level specific (see below for level details).
A list cannot be continued in another chapter. Using "##" in the first
point of a new list takes no special effect: the list will begin as usual
(with number 1).

B<Definition lists> are a third list variant. Each item starts with the
described phrase enclosed by a pair of colons, followed by the definition
text:

  :first things: are usually described first,

  :others:       later then.

All lists can be I<nested>. A new level is introduced by
a special paragraph called I<"list indention"> which starts with a ">". A list level
can be terminated by a I<"list indention stop"> paragraph containing of a "<"
character. (These startup characters symbolize "level shifts".)

  * First level.

  * Still there.

>

  * A list point of the 2nd level.

<

  * Back on first level.

It is possible to shift more than one level by adding a number. There should be no whitespace between the
level shift character and the level number.

  * First level.

>

  * Second level.

>

  * Third level.

<2

  * Back on first level.

Level shifts are accepted between list items I<only>.


=item Texts

are paragraphs like points but begin I<immediately> without a startup
character:

  This is a simple text.

  In this new text paragraph,
  we demonstrate the multiline feature.


=item Blocks

are intended to contain examples or code I<with> tag recognition.
This means that the parser will discover embedded tags. On the other hand,
it means that one may have to escape ">" characters embedded into tags. Blocks
begin with an I<indentation> and are completed by the next empty line.

  * Look at these examples:

      A block.

      \I<Another> block.
      Escape ">" in tags: \C<<\>>.

  Examples completed.

Subsequent blocks are joined together automatically: the intermediate empty
lines which would usually complete a block are translated into real empty
lines I<within> the block. This makes it easier to integrate real code
sequences as one block, regardless of the empty lines included. However,
one may explicitly I<wish> to separate subsequent blocks and can do so
by delimiting them by a special control paragraph:

  * Separated subsequent blocks:

      The first block.

  -

      The second block.

Note that the control paragraph starts at the left margin.


=item Verbatim blocks

are similar to blocks in indentation but I<deactivate>
pattern recognition. That means the embedded text is I<not> scanned for tags
and empty lines and may therefore remain as it was in its original place,
possibly a script.

These special blocks need a special syntax. They are implemented as here documents.
Start with a here document clause flagging which string will close the "here document":

  <<EOC

    PerlPoint knows various
    tags like \B, \C and \I. # unrecognized tags

  EOC


=item Tables

are supported as well, they start with an @ sign which is
followed by the column delimiter:

  @|
   column 1   |   column 2   |  column 3
    aaa       |    bbb       |   ccc
    uuu       |    vvvv      |   www

The first line is automatically marked as a  "table headline". Most converters
emphasize such headlines by bold formatting, so there is no need to insert \B
tags into the document.

If a table row contains less columns than the table headline, the "missed"
columns are automatically added. This is,

  @|
  A | B | C
  1
  1 |
  1 | 2
  1 | 2 |
  1 | 2 | 3

is streamed exactly like

  @|
  A | B | C
  1 |   |
  1 |   |
  1 | 2 |
  1 | 2 |
  1 | 2 | 3

to make backend handling easier. (Empty HTML table cells, for example, are rendered
slightly obscure by certain browsers unless they are filled with invisible characters,
so a converter to HTML can detect such cells because of normalization and handle them
appropriately.)

Please note that normalization refers to the headline row. If another line contains
I<more> columns than the headline, normalization does not care.

In all tables, leading and trailing whitespaces of a cell are
automatically removed, so you can use as many of them as you want to
improve the readability of your source. The following table is absolutely
equivalent to the last example:

  @|
  A                |       B         |      C
  1                |                 |
   1               |                 |
    1              | 2               |
     1             |  2              |
      1            | 2               |      3

There is also a more sophisticated way to describe tables, see the tag section below.

Note: Although table paragraphs cannot be nested, tables declared by tag possibly
I<can> (and might be embedded into table paragraphs as well). To help converter authors
handling nested tables, the opening table tag provides an internal option "__nestingLevel__".


=item Conditions

start with a  "?" character. If active contents is enabled, the paragraph text
is evaluated as Perl code. The (boolean) evaluation result then determines if
subsequent PerlPoint is read and parsed. If the result is false, all subsequent
paragraphs until the next condition are I<skipped>.

Note that base data is made available by a global (package) hash reference
B<$PerlPoint>. See I<run()> for details about how to set up these data.

Conditions can be used to maintain various language versions of a presentation
in one source file:

  ? $PerlPoint->{targetLanguage} eq 'German'

Or you could enable parts of your document by date:

  ? time>$dateOfTalk

or by a special setting:

  ? flagSet(setting)

Please note that the condition code shares its variables with embedded and included
code.

To make usage easier and to improve readability, condition code is evaluated with
disabled warnings (the language variable in the example above may not even been set).

Converter authors might want to provide predefined variables such as "$language"
in the example.


=item Variable assignment paragraphs

Variables can be used in the text and will be automatically replaced by their string
values (if declared).

  The next paragraph sets a variable.

  $var=var

  This variable is called $var.

All variables are made available to embedded and included Perl code as well as to
conditions and can be accessed there as package variables of "main::" (or whatever
package name the Safe object is set up to). Because a
variable is already replaced by the parser if possible, you have to use the fully
qualified name or to guard the variables "$" prefix character to do so:

  \EMBED{lang=perl}join(' ', $main::var, \$var)\END_EMBED

Variable modifications by embedded or included Perl I<do not> affect the variables
visible to the parser. (This is true for conditions as well.) This means that

  $var=10
  \EMBED{lang=perl}$main::var*=2;\END_EMBED

causes I<$var> to be different on parser and code side - the parser will still use a
value of 10, while embedded code works on with a value of 20.

=item Macro or alias definitions

Sometimes certain text parts are used more than once. It would be a relieve
to have a shortcut instead of having to insert them again and again. The same
is true for tag combinations a user may prefer to use. That's what I<aliases>
(or "macros") are designed for. They allow a presentation author to declare
his own shortcuts and to use them like a tag. The parser will resolve such aliases,
replace them by the defined replacement text and work on with this replacement.

An alias declaration starts with a "+" character followed I<immediately> by the
alias I<name> (without backslash prefix), followed I<immediately> by a colon.
(No additional spaces here.)
I<All text after this colon up to the paragraph closing empty line is stored as the replacement text.>
So, whereever you will use the new macro, the parser will replace it by this
text and I<reparse> the result. This means that your macro text can contain
any valid constructions like tags or other macros.

The replacement text may contain strings embedded into doubled underscores like
C<__this__>. This is a special syntax to mark that the macro takes parameters
of these names (e.g. C<this>). If a tag is used and these parameters are set,
their values will replace the mentioned placeholders. The special placeholder
"__body__" is used to mark where the macro I<body> is to place.

Here are a few examples:

  +RED:\FONT{color=red}<__body__>

  +F:\FONT{color=__c__}<__body__>

  +IB:\B<\I<__body__>>

  This \IB<text> is \RED<colored>.

  +TEXT:Macros can be used to abbreviate longer
     texts as well as other tags
  or tag combinations.

  +HTML:\EMBED{lang=html}

  Tags can be \RED<\I<nested>> into macros.
  And \I<\F{c=blue}<vice versa>>.
  \IB<\RED<This>> is formatted by nested macros.
  \HTML This is <i>embedded HTML</i>\END_EMBED.

  Please note: \TEXT

I<If no parameter is defined in the macro definition, options will not be recognized.>
The same is true for the body part.
I<Unless C<__body__> is used in the macro definition, macro bodies will not be recognized.>
This means that with the definition

  +OPTIONLESS:\B<__body__>

the construction

  \OPTIONLESS{something=this}<more>

is evaluated as a usage of C<\OPTIONLESS> without body, followed by the I<string>
C<{something=here}>. Likewise, the definition

  +BODYLESS:found __something__

causes

  \BODYLESS{something=this}<more>

to be recognized as a usage of C<\BODYLESS> with option C<something>, followed
by the I<string> C<<more>>. So this will be resolved as C<found this>. Finally,

  +JUSTTHENAME:Text phrase.

enforces these constructions

  ... \JUSTTHENAME, ...
  ... \JUSTTHENAME{name=Name}, ...
  ... \JUSTTHENAME<text>, ...
  ... \JUSTTHENAME{name=Name}<text> ...

to be translated into

  ... Text phrase. ...
  ... Text phrase.{name=Name} ...
  ... Text phrase.<text>, ...
  ... Text phrase.{name=Name}<text> ...

The principle behind all this is to make macro usage I<easier> and intuative:
why think of options or a body or of special characters possibly treated as
option/body part openers unless the macro makes use of an option or body?

An I<empty> macro text I<undefines> the macro (if it was already known).

  // undeclare the IB alias
  +IB:

An alias can be used like a tag.

Aliases named like a tag I<overwrite> the tag (as long as they are defined).


=back

=head2 Tags

Tags are directives embedded into the text stream, commanding how certain parts
of the text should be interpreted. Tags are declared by using one or more modules
build on base of B<PerlPoint::Tags>.

  use PerlPoint::Tags::Basic;

B<PerlPoint::Parser> parsers can recognize all tags which are build of a backslash
and a number of capitals and numbers.

  \TAG

I<Tag options> are optional and follow the tag name immediately, enclosed
by a pair of corresponding curly braces. Each option is a simple string
assignment. The value has to be quoted if /^\w+$/ does not match it.

  \TAG{par1=value1 par2="www.perl.com" par3="words and blanks"}

The I<tag body> is anything you want to make the tag valid for. It is optional
as well and immediately follows the optional parameters, enclosed by "<" and ">":

  \TAG<body>
  \TAG{par=value}<body>

Tags can be I<nested>.

To provide a maximum of flexibility, tags are declared I<outside> the parser.
This way a translator programmer is free to implement the tags he needs. It is
recommended to always support the basic tags declared by B<PerlPoint::Tags::Basic>.
On the other hand,a few tags of special meaning are reserved and cannot be declared
by converter authors, because they are handled by the parser itself. These are:

=over 4

=item \INCLUDE

It is possible to include a file into the input stream. Have a look:

 \INCLUDE{type=HTML file=filename}

This imports the file "filename". The file contents is made part of the
generated stream, but not parsed. This is useful to include target language
specific, preformatted parts.

If, however, the file type is specified as "PP", the file contents is
made part of the input stream and parsed. In this case a special tag option
"headlinebase" can be specified to define a headline base level used as
an offset to all headlines in the included document. This makes it easier
to share partial documents with others, or to build complex documents by
including separately maintained parts, or to include one and the same
part at different headline levels.

 Example: If "\INCLUDE{type=PP file=file headlinebase=20}" is
          specified and "file" contains a one level headline
          like "=Main topic of special explanations"
          this headline is detected with a level of 21.

Pass the special keyword "CURRENT_LEVEL" to this tag option if you want to
set just the I<current> headline level as an offset. This results in
"subchapters".

 Example:

 ===Headline 3

 // let included chapters start on level 4
 \INCLUDE{type=PP file=file headlinebase=CURRENT_LEVEL}

Similar to "CURRENT_LEVEL", "BASE_LEVEL" sets the current I<base>
headline level as an offset. The "base level" is the level above
the current one. Using "BASE_LEVEL" results in parallel chapters.

 Example:

 ===Headline 3

 // let included chapters start on level 3
 \INCLUDE{type=PP file=file headlinebase=BASE_LEVEL}

A given offset is reset when the included document is parsed completely.

A second special option I<smart> commands the parser to include the file
only unless this was already done before. This is intended for inclusion
of pure alias/macro definition or variable assignment files.

 \INCLUDE{type=PP file="common-macros.pp" smart=1}

Included sources may declare variables of their own, possibly overwriting
already assigned values. Option "localize" works like Perls C<local()>:
such changes will be reversed after the nested source will have been
processed completely, so the original values will be restored. You can
specify a comma separated list of variable names or the special string
"__ALL__" which flags that I<all> current settings shall be restored.

 \INCLUDE{type=PP file="nested.pp" localize=myVar}

 \INCLUDE{type=PP file="nested.pp" localize="var1, var2, var3"}

 \INCLUDE{type=PP file="nested.pp" localize=__ALL__}

A PerlPoint file can be included wherever a tag is allowed, but sometimes
it has to be arranged slightly: if you place the inclusion directive at
the beginning of a new paragraph I<and> your included PerlPoint starts by
a paragraph of another type than text, you should begin the included file
by an empty line to let the parser detect the correct paragraph type. Here
is an example: if the inclusion directive is placed like

  // include PerlPoint
  \INCLUDE{type=pp file="file.pp"}

and file.pp immediately starts with a verbatim block like

  <<VERBATIM
      verbatim
  VERBATIM

, I<the inclusion directive already opens a new paragraph> which is detected to
be "text" (because there is no special startup character). Now in the included
file, from the parsers point of view the included PerlPoint is simply a
continuation of this text, because a paragraph ends with an empty line. This
trouble can be avoided by beginning the included file by an empty line,
so that its first paragraph can be detected correctly.

The second special case is a file type of "Perl". If active contents is enabled,
included Perl code is read into memory and evaluated like I<embedded> Perl. The
results are made part of the input stream to be parsed.

  // execute a perl script and include the results
  \INCLUDE{type=perl file="disk-usage.pl"}

As another option, files may be declared to be of type "example". This makes the
file placed into the source as a verbatim block, without need to copy its contents
into the source.

  // include an external script as an example
  \INCLUDE{type=example file="script.csh"}

All lines of the example file are included as they are but can be indented on request.
To do so, just set the special option "indent" to a positive numerical value equal to
the number of spaces to be inserted before each line.

  // external example source, indented by 3 spaces
  \INCLUDE{type=example file="script.csh" indent=3}

Including external scripts this way can accelerate PerlPoint authoring significantly,
especially if the included files are still subject to changes.

It is possible to filter the file types you wish to include (with exception
of "pp" and "example"), see below for details. I<In any case>, the mentioned file
has to exist.



=item \EMBED and \END_EMBED

Target format code does not necessarily need to be imported - it can be
directly I<embedded> as well. This means that one can write target language
code within the input stream using I<\EMBED>:

  \EMBED{lang=HTML}
  This is <i><b>embedded</b> HTML</i>.
  The parser detects <i>no</i> PerlPoint
  tag here, except of <b>END_EMBED</b>.
  \END_EMBED

Because this is handled by I<tags>, not by paragraphs, it can be placed
directly in a text like this:

  These \EMBED{lang=HTML}<i>italics</i>\END_EMBED
  are formatted by HTML code.

Please note that the EMBED tag does not accept a tag body to avoid
ambiguities.

Both tag and embedded text are made part of the intermediate stream.
It is the backends task to deal with it. The only exception of this rule
is the embedding of I<Perl> code, which is evaluated by the parser.
The reply of this code is made part of the input stream and parsed as
usual.

It is possible to filter the languages you wish to embed (with exception
of "PP"), see below for details.


=item \TABLE and \END_TABLE

It was mentioned above that tables can be built by table paragraphs.
Well, there is a tag variant of this:

  \TABLE{bg=blue separator="|" border=2}
  \B<column 1>  |  \B<column 2>  | \B<column 3>
     aaaa       |     bbbb       |  cccc
     uuuu       |     vvvv       |  wwww
  \END_TABLE

This is sligthly more powerfull than the paragraph syntax: you can set
up several table features like the border width yourself, and you can
format the headlines as you like.

As in all tables, leading and trailing whitespaces of a cell are
automatically removed, so you can use as many of them as you want to
improve the readability of your source.

The default row separator (as in the example above) is a carriage return,
so that each table line can be written as a separate source line. However,
PerlPoint allows you to specify another string to separate rows by option
C<rowseparator>. This allows to specify a table I<inlined> into a paragraph.

  \TABLE{bg=blue separator="|" border=2 rowseparator="+++"}
  \B<column 1> | \B<column 2> | \B<column 3> +++ aaaa
  | bbbb | cccc +++ uuuu | vvvv|  wwww \END_TABLE

This is exactly the same table as above.

If parser option I<nestedTables> is set to a true value calling I<run()>,
it is possible to I<nest> tables. To help converter authors handling this,
the opening table tag provides an internal option "__nestingLevel__".

Tables built by tag are normalized the same way as table paragraphs are.

=back


=head2 What about special formatting?

Earlier versions of B<pp2html> supported special format hints like the HTML
expression "&gt;" for the ">" character, or "&uuml;" for "ü". B<PerlPoint::Parser>
does I<not> support this directly because such hints are specific to the
I<output format> - if someone wants to translate into TeX, it might be curious
for him to use HTML syntax in his ASCII text. Further more, such hints can be
handled I<completely> by a backend which finds them unchanged in the produced
output stream.

The same is true for special headers and trailers. It is a I<backend> task to
add them if necessary. The parser does handle the I<input> only.


=head1 STREAM FORMAT

It is suggested to use B<PerlPoint::Backend> to evaluate the intermediate format.
Nevertheless, here is the documentation of this format.

The generated stream is an array of tokens. Most of them are very simple,
representing just their contents - words, spaces and so on. Example:

  "These three words."

could be streamed into

  "These three" + " "+ "words."

(This shows the principle. Actually this complete sentence would be replied as
I<one> token for reasons of effeciency.)

Note that the final dot I<is part> of the last token. From a document
description view, this should make no difference, its just a string containing
special characters or not.

Well, besides this "main stream", there are I<formatting directives>. They
flag the I<beginning> or I<completion> of a certain logical entity - this
means a whole document, a paragraph or a formatting like italicising. Almost
every entity is embedded into a start I<and> a completion directive - except
of simple tokens.

In the current implementation, a directive is a reference to an array of mostly
two fields: a directive constant showing which entity is related, and a start
or completion hint which is a constant, too. The used constants are declared in
B<PerlPoint::Constants>. Directives can pass additional informations by additional
fields. By now, the headline directives use this feature to show the headline
level, as well as the tag ones to provide tag type information and the document ones
to keep the name of the original document. Further more, ordered list points I<can>
request a fix number this way.

  # this example shows a tag directive
  ... [DIRECTIVE_TAG, DIRECTIVE_START, "I"]
  + "formatted" + " " + "strings"
  + [DIRECTIVE_TAG, DIRECTIVE_COMPLETE, "I"] ...

To recognize whether a token is a basic or a directive, the ref() function can be
used. However, this handling should be done by B<PerlPoint::Backend> transparently.
The format may be subject to changes and is documented for information purposes only.

Original line numbers are no part of the stream but can be provided by embedded
directives on request, see below for details.

This is the complete generator format. It is designed to be simple but powerful.


=head1 METHODS

=head2 new()

The constructor builds and prepares a new parser object.

B<Parameters:>

=over 4

=item The class name.

=back

B<Return value:>
The new object in case of success.

B<Example:>

  my ($parser)=new PerlPoint::Parser;

=cut

# = CODE SECTION ========================================================================

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

   # declare internal constants: action timeout types (used as array indices, sort alphabetically!)
   startupGenerateConstants(
                            'LEXER_TOKEN',           # reply symbols token;
                            'LEXER_FATAL',           # bug: unexpected symbol;
                            'LEXER_IGNORE',          # ignore this symbol;
                            'LEXER_EMPTYLINE',       # reply the token "Empty_line";
                            'LEXER_SPACE',           # reply the token "Space" and a simple whitespace;
                           );

   # state constants
   startupGenerateConstants(
                            'STATE_DEFAULT',         # default;
                            'STATE_DEFAULT_TAGMODE', # default in tag mode;

                            'STATE_BLOCK',           # block;
                            'STATE_COMMENT',         # comment;
                            'STATE_CONTROL',         # control paragraph (of a single character);
                            'STATE_DPOINT',          # definition list point;
                            'STATE_DPOINT_ITEM',     # definition list point item (defined stuff);
                            'STATE_EMBEDDING',       # embedded things (HTML, Perl, ...);
                            'STATE_CONDITION',       # condition;
                            'STATE_HEADLINE_LEVEL',  # headline level setting;
                            'STATE_HEADLINE',        # headline;
                            'STATE_OPOINT',          # ordered list point;
                            'STATE_TEXT',            # text;
                            'STATE_UPOINT',          # unordered list point;
                            'STATE_VERBATIM',        # verbatim block;
                            'STATE_TABLE',           # table *paragraph*;
                            'STATE_DEFINITION',      # macro definition;
                           );

   # declare internal constants: list shifters
   startupGenerateConstants(
                            'LIST_SHIFT_RIGHT',      # shift right;
                            'LIST_SHIFT_LEFT',       # shift left;
                           );

   # release memory
   undef &startupGenerateConstants;
  }

 # requires modern perl
 require 5.00502;

 # declare module version
 $PerlPoint::Parser::VERSION=0.3501;
 $PerlPoint::Parser::VERSION=$PerlPoint::Parser::VERSION; # to suppress a warning of exclusive usage only;

 # pragmata
 use strict;
 use fields;

 # load modules
 use Cwd;
 use Carp;
 use IO::File;
 use File::Basename;
 use PerlPoint::Constants 0.14 qw(:DEFAULT :parsing :tags);
 use Digest::SHA1 qw(sha1_base64);
 use Storable qw(:DEFAULT dclone nfreeze);

 # startup declarations
 my (
     %data,                        # the collected declaration data;
     %lineNrs,                     # the lexers line number hash, input handle specific;
     %specials,                    # special character control (may be active or not);
     %lexerFlags,                  # lexer state flags;
     %statistics,                  # statitics data;
     %variables,                   # user managed variables;
     %flags,                       # various flags;
     %macros,                      # macros / aliases;
     %openedSourcefiles,           # a hash of all already opened source files (to enable smart inclusion);

     @nestedSourcefiles,           # a list of current source file nesting (to avoid circular inclusions);
     @specialStack,                # special state stack for temporary activations (to restore original states);
     @stateStack,                  # state stack (mostly intended for non paragraph states like STATE_EMBEDDED);
     @tableSeparatorStack,         # the first element is the column separator string within a table, empty otherwise;
     @inputStack,                  # a stack of additional input lines and dynamically inserted parts;
     @inHandles,                   # a stack of input handles (to manage nested sources);
     @olistLevels,                 # a hint storing the last recent ordered list level number of a paragraph (hyrarchically);

     $safeObject,                  # an object of class Safe to evaluate Perl code embedded into PerlPoint;
     $sourceFile,                  # the source file currently read;
     $tagsRef,                     # reference to a hash of valid tag openers (strings without the "<");
     $resultStreamRef,             # reference to an array to put generated stream data in;
     $inHandle,                    # the data input stream (to parse);
     $parserState,                 # the current parser state;
     $readCompletely,              # the input file is read completely;
     $semErr,                      # semantic error counter;
     $tableColumns,                # counter of completed table columns;
     $checksums,		   # paragraph checksums (and associated stream parts);
     $macroChecksum,               # the current macro checksum;
     $varChecksum,                 # the current user variables checksum;
    );

 # ----- Startup code begins here. -----

 # prepare main input handle (obsolete when all people will use perl 5.6)
 $inHandle=new IO::File;

 # set developer data
 my ($developerName, $developer)=('J. Stenzel', 'perl@jochen-stenzel.de');

 # init flag
 $readCompletely=0;

 # prepare a common pattern
 my $patternWUmlauts=qr([\wäöüÄÖÜß]+);

 # declare paragraphs which are embedded
 my %embeddedParagraphs;
 @embeddedParagraphs{
                     DIRECTIVE_UPOINT,
                     DIRECTIVE_OPOINT,
                    }=();

 # declare token descriptions (to be used in error messages)
 my %tokenDescriptions=(
                        EOL                => 'a carriage return',
                        Embed              => 'embedded code',
                        Embedded           => 'an \END_EMBED tag',
                        Empty_line         => 'an empty line',
                        Heredoc_close      => 'a string closing the "here document"',
                        Heredoc_open       => 'a "here document" opener',
                        Ils                => 'a indentation',
                        Include            => 'an included part',
                        Named_variable     => 'a named variable',
                        Space              => 'a whitespace',
                        StreamedPart       => undef,
                        Symbolic_variable  => 'a symbolic variable',
                        Table              => 'a table',
                        Table_separator    => 'a table column separator',
                        Tabled             => 'an \END_TABLE tag',
                        Tag_name           => 'a tag name',
                        Word               => 'a word',
                       );



sub new {
        my($class)=shift;
        ref($class)
    and $class=ref($class);

    my($self)=$class->SUPER::new( yyversion => '1.01',
                                  yystates =>
[
	{#State 0
		ACTIONS => {
			'EOL' => 3,
			"\@" => 1,
			"#" => 38,
			'Block_cache_hit' => 39,
			'Named_variable' => 7,
			'Colon' => 10,
			'Symbolic_variable' => 42,
			'Upoint_cache_hit' => 45,
			'Embed' => 14,
			'Ils' => 15,
			'Opoint_cache_hit' => 16,
			'Empty_line' => 18,
			"*" => 21,
			'Include' => 23,
			'Table_separator' => 24,
			"+" => 47,
			'Headline_cache_hit' => 49,
			'StreamedPart' => 50,
			'Heredoc_open' => 51,
			'Table' => 27,
			"=" => 28,
			'Paragraph_cache_hit' => 54,
			'Space' => 56,
			"/" => 57,
			'Word' => 30,
			'Tag_name' => 58,
			"?" => 32,
			'Dpoint_cache_hit' => 33
		},
		GOTOS => {
			'included' => 2,
			'olist' => 4,
			'headline' => 35,
			'verbatim' => 5,
			'dpoint' => 6,
			'opoint' => 37,
			'list_part' => 36,
			'block' => 40,
			'opoint_opener' => 8,
			'upoint' => 9,
			'dlist' => 11,
			'embedded' => 41,
			'basic' => 12,
			'tag' => 43,
			'element' => 13,
			'paragraph' => 44,
			'condition' => 17,
			'document' => 46,
			'text' => 19,
			'list' => 20,
			'table_paragraph' => 22,
			'headline_level' => 25,
			'table_separator' => 48,
			'compound_block' => 52,
			'alias_definition' => 26,
			'comment' => 29,
			'variable_assignment' => 55,
			'table' => 53,
			'literal' => 31,
			'dlist_opener' => 59,
			'ulist' => 34
		}
	},
	{#State 1
		DEFAULT => -121,
		GOTOS => {
			'@22-1' => 60
		}
	},
	{#State 2
		DEFAULT => -96
	},
	{#State 3
		DEFAULT => -79
	},
	{#State 4
		ACTIONS => {
			"#" => 38,
			'Opoint_cache_hit' => 16
		},
		DEFAULT => -25,
		GOTOS => {
			'opoint_opener' => 8,
			'opoint' => 61
		}
	},
	{#State 5
		DEFAULT => -7
	},
	{#State 6
		DEFAULT => -32
	},
	{#State 7
		ACTIONS => {
			"=" => 62
		},
		DEFAULT => -91
	},
	{#State 8
		DEFAULT => -34,
		GOTOS => {
			'@3-1' => 63
		}
	},
	{#State 9
		DEFAULT => -30
	},
	{#State 10
		DEFAULT => -45,
		GOTOS => {
			'@6-1' => 64
		}
	},
	{#State 11
		ACTIONS => {
			'Colon' => 10,
			'Dpoint_cache_hit' => 33
		},
		DEFAULT => -27,
		GOTOS => {
			'dpoint' => 65,
			'dlist_opener' => 59
		}
	},
	{#State 12
		DEFAULT => -78
	},
	{#State 13
		DEFAULT => -84
	},
	{#State 14
		DEFAULT => -124,
		GOTOS => {
			'@24-1' => 66
		}
	},
	{#State 15
		DEFAULT => -52,
		GOTOS => {
			'@8-1' => 67
		}
	},
	{#State 16
		DEFAULT => -36
	},
	{#State 17
		DEFAULT => -10
	},
	{#State 18
		DEFAULT => -13
	},
	{#State 19
		DEFAULT => -5
	},
	{#State 20
		ACTIONS => {
			"#" => 38,
			'Colon' => 10,
			'Opoint_cache_hit' => 16,
			'Upoint_cache_hit' => 45,
			"*" => 21,
			"<" => 71,
			">" => 72,
			'Dpoint_cache_hit' => 33
		},
		DEFAULT => -4,
		GOTOS => {
			'olist' => 4,
			'list_shift' => 69,
			'dpoint' => 6,
			'list_part' => 70,
			'opoint' => 37,
			'list_shifter' => 68,
			'opoint_opener' => 8,
			'upoint' => 9,
			'dlist' => 11,
			'dlist_opener' => 59,
			'ulist' => 34
		}
	},
	{#State 21
		DEFAULT => -39,
		GOTOS => {
			'@4-1' => 73
		}
	},
	{#State 22
		DEFAULT => -11
	},
	{#State 23
		DEFAULT => -127,
		GOTOS => {
			'@26-1' => 74
		}
	},
	{#State 24
		DEFAULT => -120
	},
	{#State 25
		ACTIONS => {
			"=" => 75
		},
		DEFAULT => -15,
		GOTOS => {
			'@1-1' => 76
		}
	},
	{#State 26
		DEFAULT => -12
	},
	{#State 27
		DEFAULT => -117,
		GOTOS => {
			'@20-1' => 77
		}
	},
	{#State 28
		DEFAULT => -18
	},
	{#State 29
		DEFAULT => -9
	},
	{#State 30
		DEFAULT => -89
	},
	{#State 31
		DEFAULT => -55,
		GOTOS => {
			'@9-1' => 78
		}
	},
	{#State 32
		DEFAULT => -20,
		GOTOS => {
			'@2-1' => 79
		}
	},
	{#State 33
		DEFAULT => -44
	},
	{#State 34
		ACTIONS => {
			'Upoint_cache_hit' => 45,
			"*" => 21
		},
		DEFAULT => -26,
		GOTOS => {
			'upoint' => 80
		}
	},
	{#State 35
		DEFAULT => -3
	},
	{#State 36
		DEFAULT => -22
	},
	{#State 37
		DEFAULT => -28
	},
	{#State 38
		ACTIONS => {
			"#" => 81
		},
		DEFAULT => -37
	},
	{#State 39
		DEFAULT => -54
	},
	{#State 40
		DEFAULT => -47
	},
	{#State 41
		DEFAULT => -95
	},
	{#State 42
		DEFAULT => -92
	},
	{#State 43
		DEFAULT => -94
	},
	{#State 44
		DEFAULT => -1
	},
	{#State 45
		DEFAULT => -41
	},
	{#State 46
		ACTIONS => {
			'' => 82,
			'EOL' => 3,
			"\@" => 1,
			"#" => 38,
			'Block_cache_hit' => 39,
			'Named_variable' => 7,
			'Colon' => 10,
			'Symbolic_variable' => 42,
			'Upoint_cache_hit' => 45,
			'Embed' => 14,
			'Ils' => 15,
			'Opoint_cache_hit' => 16,
			'Empty_line' => 18,
			"*" => 21,
			'Include' => 23,
			'Table_separator' => 24,
			"+" => 47,
			'Headline_cache_hit' => 49,
			'StreamedPart' => 50,
			'Heredoc_open' => 51,
			'Table' => 27,
			"=" => 28,
			'Paragraph_cache_hit' => 54,
			'Space' => 56,
			"/" => 57,
			'Word' => 30,
			'Tag_name' => 58,
			"?" => 32,
			'Dpoint_cache_hit' => 33
		},
		GOTOS => {
			'included' => 2,
			'olist' => 4,
			'headline' => 35,
			'verbatim' => 5,
			'dpoint' => 6,
			'list_part' => 36,
			'opoint' => 37,
			'block' => 40,
			'opoint_opener' => 8,
			'upoint' => 9,
			'dlist' => 11,
			'embedded' => 41,
			'basic' => 12,
			'tag' => 43,
			'element' => 13,
			'paragraph' => 83,
			'condition' => 17,
			'text' => 19,
			'list' => 20,
			'table_paragraph' => 22,
			'headline_level' => 25,
			'table_separator' => 48,
			'compound_block' => 52,
			'alias_definition' => 26,
			'comment' => 29,
			'variable_assignment' => 55,
			'table' => 53,
			'literal' => 31,
			'dlist_opener' => 59,
			'ulist' => 34
		}
	},
	{#State 47
		DEFAULT => -129,
		GOTOS => {
			'@27-1' => 84
		}
	},
	{#State 48
		DEFAULT => -86
	},
	{#State 49
		DEFAULT => -17
	},
	{#State 50
		DEFAULT => -93
	},
	{#State 51
		DEFAULT => -57,
		GOTOS => {
			'@10-1' => 85
		}
	},
	{#State 52
		ACTIONS => {
			'Block_cache_hit' => 39,
			'Ils' => 15,
			"-" => 88
		},
		DEFAULT => -6,
		GOTOS => {
			'block' => 87,
			'block_flagnew' => 86
		}
	},
	{#State 53
		DEFAULT => -85
	},
	{#State 54
		DEFAULT => -14
	},
	{#State 55
		DEFAULT => -8
	},
	{#State 56
		DEFAULT => -90
	},
	{#State 57
		ACTIONS => {
			"/" => 89
		}
	},
	{#State 58
		DEFAULT => -101,
		GOTOS => {
			'@15-1' => 90
		}
	},
	{#State 59
		DEFAULT => -42,
		GOTOS => {
			'@5-1' => 91
		}
	},
	{#State 60
		ACTIONS => {
			'Word' => 92
		},
		GOTOS => {
			'words' => 93
		}
	},
	{#State 61
		DEFAULT => -29
	},
	{#State 62
		DEFAULT => -59,
		GOTOS => {
			'@11-2' => 94
		}
	},
	{#State 63
		ACTIONS => {
			'EOL' => 3,
			'Table_separator' => 24,
			'Include' => 23,
			'Named_variable' => 95,
			'StreamedPart' => 50,
			'Table' => 27,
			'Symbolic_variable' => 42,
			'Space' => 56,
			'Word' => 30,
			'Tag_name' => 58,
			'Embed' => 14
		},
		GOTOS => {
			'included' => 2,
			'text' => 96,
			'table' => 53,
			'embedded' => 41,
			'basic' => 12,
			'table_separator' => 48,
			'literal' => 31,
			'tag' => 43,
			'element' => 13
		}
	},
	{#State 64
		ACTIONS => {
			'Symbolic_variable' => 42,
			'Space' => 56,
			'Include' => 23,
			'Word' => 30,
			'Tag_name' => 58,
			'Named_variable' => 95,
			'StreamedPart' => 50,
			'Embed' => 14
		},
		GOTOS => {
			'included' => 2,
			'embedded' => 41,
			'tag' => 43,
			'elements' => 98,
			'element' => 97
		}
	},
	{#State 65
		DEFAULT => -33
	},
	{#State 66
		ACTIONS => {
			"{" => 99
		},
		GOTOS => {
			'used_tagpars' => 100
		}
	},
	{#State 67
		ACTIONS => {
			'EOL' => 3,
			'Table_separator' => 24,
			'Include' => 23,
			'Named_variable' => 95,
			'StreamedPart' => 50,
			'Table' => 27,
			'Symbolic_variable' => 42,
			'Space' => 56,
			'Word' => 30,
			'Tag_name' => 58,
			'Embed' => 14
		},
		GOTOS => {
			'included' => 2,
			'text' => 101,
			'table' => 53,
			'embedded' => 41,
			'basic' => 12,
			'table_separator' => 48,
			'literal' => 31,
			'tag' => 43,
			'element' => 13
		}
	},
	{#State 68
		DEFAULT => -63,
		GOTOS => {
			'@13-1' => 102
		}
	},
	{#State 69
		ACTIONS => {
			'Colon' => 10,
			"*" => 21,
			"#" => 38,
			'Upoint_cache_hit' => 45,
			'Dpoint_cache_hit' => 33,
			'Opoint_cache_hit' => 16
		},
		GOTOS => {
			'olist' => 4,
			'dpoint' => 6,
			'list_part' => 103,
			'opoint' => 37,
			'opoint_opener' => 8,
			'upoint' => 9,
			'dlist' => 11,
			'dlist_opener' => 59,
			'ulist' => 34
		}
	},
	{#State 70
		DEFAULT => -23
	},
	{#State 71
		DEFAULT => -67
	},
	{#State 72
		DEFAULT => -66
	},
	{#State 73
		ACTIONS => {
			'EOL' => 3,
			'Table_separator' => 24,
			'Include' => 23,
			'Named_variable' => 95,
			'StreamedPart' => 50,
			'Table' => 27,
			'Symbolic_variable' => 42,
			'Space' => 56,
			'Word' => 30,
			'Tag_name' => 58,
			'Embed' => 14
		},
		GOTOS => {
			'included' => 2,
			'text' => 104,
			'table' => 53,
			'embedded' => 41,
			'basic' => 12,
			'table_separator' => 48,
			'literal' => 31,
			'tag' => 43,
			'element' => 13
		}
	},
	{#State 74
		ACTIONS => {
			"{" => 99
		},
		GOTOS => {
			'used_tagpars' => 105
		}
	},
	{#State 75
		DEFAULT => -19
	},
	{#State 76
		ACTIONS => {
			'Table' => 27,
			'Symbolic_variable' => 42,
			'Space' => 56,
			'Table_separator' => 24,
			'Include' => 23,
			'Word' => 30,
			'Tag_name' => 58,
			'Named_variable' => 95,
			'StreamedPart' => 50,
			'Embed' => 14
		},
		GOTOS => {
			'included' => 2,
			'table' => 53,
			'embedded' => 41,
			'basic' => 107,
			'basics' => 106,
			'table_separator' => 48,
			'tag' => 43,
			'element' => 13
		}
	},
	{#State 77
		ACTIONS => {
			"{" => 99
		},
		GOTOS => {
			'used_tagpars' => 108
		}
	},
	{#State 78
		ACTIONS => {
			'EOL' => 3,
			'Table_separator' => 24,
			'Include' => 23,
			'Named_variable' => 95,
			'StreamedPart' => 50,
			'Table' => 27,
			'Symbolic_variable' => 42,
			'Space' => 56,
			'Word' => 30,
			'Tag_name' => 58,
			'Embed' => 14
		},
		DEFAULT => -68,
		GOTOS => {
			'included' => 2,
			'literals' => 109,
			'table' => 53,
			'embedded' => 41,
			'basic' => 12,
			'table_separator' => 48,
			'literal' => 111,
			'optional_literals' => 110,
			'tag' => 43,
			'element' => 13
		}
	},
	{#State 79
		ACTIONS => {
			'Table' => 27,
			'Symbolic_variable' => 42,
			'Space' => 56,
			'Table_separator' => 24,
			'Include' => 23,
			'Word' => 30,
			'Tag_name' => 58,
			'Named_variable' => 95,
			'StreamedPart' => 50,
			'Embed' => 14
		},
		GOTOS => {
			'included' => 2,
			'table' => 53,
			'embedded' => 41,
			'basic' => 107,
			'basics' => 112,
			'table_separator' => 48,
			'tag' => 43,
			'element' => 13
		}
	},
	{#State 80
		DEFAULT => -31
	},
	{#State 81
		DEFAULT => -38
	},
	{#State 82
		DEFAULT => -0
	},
	{#State 83
		DEFAULT => -2
	},
	{#State 84
		ACTIONS => {
			'Word' => 113
		}
	},
	{#State 85
		ACTIONS => {
			'Empty_line' => 114,
			'EOL' => 3,
			'Table_separator' => 24,
			'Include' => 23,
			'Named_variable' => 95,
			'StreamedPart' => 50,
			'Table' => 27,
			'Symbolic_variable' => 42,
			'Space' => 56,
			'Word' => 30,
			'Tag_name' => 58,
			'Embed' => 14
		},
		GOTOS => {
			'included' => 2,
			'literals_and_empty_lines' => 116,
			'table' => 53,
			'embedded' => 41,
			'literal_or_empty_line' => 115,
			'basic' => 12,
			'table_separator' => 48,
			'literal' => 117,
			'tag' => 43,
			'element' => 13
		}
	},
	{#State 86
		ACTIONS => {
			'Block_cache_hit' => 39,
			'Ils' => 15
		},
		GOTOS => {
			'compound_block' => 118,
			'block' => 40
		}
	},
	{#State 87
		DEFAULT => -48
	},
	{#State 88
		DEFAULT => -50,
		GOTOS => {
			'@7-1' => 119
		}
	},
	{#State 89
		DEFAULT => -61,
		GOTOS => {
			'@12-2' => 120
		}
	},
	{#State 90
		ACTIONS => {
			"{" => 99
		},
		DEFAULT => -104,
		GOTOS => {
			'used_tagpars' => 122,
			'optional_tagpars' => 121
		}
	},
	{#State 91
		ACTIONS => {
			'EOL' => 3,
			'Table_separator' => 24,
			'Include' => 23,
			'Named_variable' => 95,
			'StreamedPart' => 50,
			'Table' => 27,
			'Symbolic_variable' => 42,
			'Space' => 56,
			'Word' => 30,
			'Tag_name' => 58,
			'Embed' => 14
		},
		GOTOS => {
			'included' => 2,
			'text' => 123,
			'table' => 53,
			'embedded' => 41,
			'basic' => 12,
			'table_separator' => 48,
			'literal' => 31,
			'tag' => 43,
			'element' => 13
		}
	},
	{#State 92
		DEFAULT => -99
	},
	{#State 93
		ACTIONS => {
			'EOL' => 124,
			'Word' => 125
		}
	},
	{#State 94
		ACTIONS => {
			'EOL' => 3,
			'Table_separator' => 24,
			'Include' => 23,
			'Named_variable' => 95,
			'StreamedPart' => 50,
			'Table' => 27,
			'Symbolic_variable' => 42,
			'Space' => 56,
			'Word' => 30,
			'Tag_name' => 58,
			'Embed' => 14
		},
		GOTOS => {
			'included' => 2,
			'text' => 126,
			'table' => 53,
			'embedded' => 41,
			'basic' => 12,
			'table_separator' => 48,
			'literal' => 31,
			'tag' => 43,
			'element' => 13
		}
	},
	{#State 95
		DEFAULT => -91
	},
	{#State 96
		DEFAULT => -35
	},
	{#State 97
		DEFAULT => -87
	},
	{#State 98
		ACTIONS => {
			'Colon' => 127,
			'Symbolic_variable' => 42,
			'Space' => 56,
			'Include' => 23,
			'Word' => 30,
			'Tag_name' => 58,
			'Named_variable' => 95,
			'StreamedPart' => 50,
			'Embed' => 14
		},
		GOTOS => {
			'included' => 2,
			'embedded' => 41,
			'tag' => 43,
			'element' => 128
		}
	},
	{#State 99
		ACTIONS => {
			'Word' => 130
		},
		GOTOS => {
			'tagpar' => 131,
			'tagpars' => 129
		}
	},
	{#State 100
		DEFAULT => -125,
		GOTOS => {
			'@25-3' => 132
		}
	},
	{#State 101
		DEFAULT => -53
	},
	{#State 102
		ACTIONS => {
			'Number' => 134
		},
		DEFAULT => -97,
		GOTOS => {
			'optional_number' => 133
		}
	},
	{#State 103
		DEFAULT => -24
	},
	{#State 104
		DEFAULT => -40
	},
	{#State 105
		DEFAULT => -128
	},
	{#State 106
		ACTIONS => {
			'Empty_line' => 136,
			'Table_separator' => 24,
			'Include' => 23,
			'Named_variable' => 95,
			'StreamedPart' => 50,
			'Table' => 27,
			'Symbolic_variable' => 42,
			'Space' => 56,
			'Word' => 30,
			'Tag_name' => 58,
			'Embed' => 14
		},
		GOTOS => {
			'included' => 2,
			'table' => 53,
			'embedded' => 41,
			'basic' => 135,
			'table_separator' => 48,
			'tag' => 43,
			'element' => 13
		}
	},
	{#State 107
		DEFAULT => -82
	},
	{#State 108
		DEFAULT => -118,
		GOTOS => {
			'@21-3' => 137
		}
	},
	{#State 109
		ACTIONS => {
			'EOL' => 3,
			'Table_separator' => 24,
			'Include' => 23,
			'Named_variable' => 95,
			'StreamedPart' => 50,
			'Table' => 27,
			'Symbolic_variable' => 42,
			'Space' => 56,
			'Word' => 30,
			'Tag_name' => 58,
			'Embed' => 14
		},
		DEFAULT => -69,
		GOTOS => {
			'included' => 2,
			'table' => 53,
			'embedded' => 41,
			'basic' => 12,
			'table_separator' => 48,
			'literal' => 138,
			'tag' => 43,
			'element' => 13
		}
	},
	{#State 110
		ACTIONS => {
			'Empty_line' => 139
		}
	},
	{#State 111
		DEFAULT => -70
	},
	{#State 112
		ACTIONS => {
			'Empty_line' => 140,
			'Table_separator' => 24,
			'Include' => 23,
			'Named_variable' => 95,
			'StreamedPart' => 50,
			'Table' => 27,
			'Symbolic_variable' => 42,
			'Space' => 56,
			'Word' => 30,
			'Tag_name' => 58,
			'Embed' => 14
		},
		GOTOS => {
			'included' => 2,
			'table' => 53,
			'embedded' => 41,
			'basic' => 135,
			'table_separator' => 48,
			'tag' => 43,
			'element' => 13
		}
	},
	{#State 113
		ACTIONS => {
			'Colon' => 141
		}
	},
	{#State 114
		DEFAULT => -77
	},
	{#State 115
		DEFAULT => -74
	},
	{#State 116
		ACTIONS => {
			'Empty_line' => 114,
			'EOL' => 3,
			'Table_separator' => 24,
			'Include' => 23,
			'Named_variable' => 95,
			'StreamedPart' => 50,
			'Heredoc_close' => 143,
			'Table' => 27,
			'Symbolic_variable' => 42,
			'Space' => 56,
			'Word' => 30,
			'Tag_name' => 58,
			'Embed' => 14
		},
		GOTOS => {
			'included' => 2,
			'table' => 53,
			'embedded' => 41,
			'literal_or_empty_line' => 142,
			'basic' => 12,
			'table_separator' => 48,
			'literal' => 117,
			'tag' => 43,
			'element' => 13
		}
	},
	{#State 117
		DEFAULT => -76
	},
	{#State 118
		ACTIONS => {
			'Block_cache_hit' => 39,
			'Ils' => 15,
			"-" => 88
		},
		DEFAULT => -49,
		GOTOS => {
			'block' => 87,
			'block_flagnew' => 86
		}
	},
	{#State 119
		ACTIONS => {
			'Empty_line' => 144
		}
	},
	{#State 120
		ACTIONS => {
			'Table_separator' => 24,
			'Include' => 23,
			'Named_variable' => 95,
			'StreamedPart' => 50,
			'Table' => 27,
			'Symbolic_variable' => 42,
			'Space' => 56,
			'Word' => 30,
			'Tag_name' => 58,
			'Embed' => 14
		},
		DEFAULT => -80,
		GOTOS => {
			'included' => 2,
			'basics' => 145,
			'table_separator' => 48,
			'optional_basics' => 146,
			'table' => 53,
			'embedded' => 41,
			'basic' => 107,
			'element' => 13,
			'tag' => 43
		}
	},
	{#State 121
		DEFAULT => -102,
		GOTOS => {
			'@16-3' => 147
		}
	},
	{#State 122
		DEFAULT => -105
	},
	{#State 123
		DEFAULT => -43
	},
	{#State 124
		DEFAULT => -122,
		GOTOS => {
			'@23-4' => 148
		}
	},
	{#State 125
		DEFAULT => -100
	},
	{#State 126
		DEFAULT => -60
	},
	{#State 127
		DEFAULT => -46
	},
	{#State 128
		DEFAULT => -88
	},
	{#State 129
		ACTIONS => {
			'Space' => 150,
			"}" => 149
		}
	},
	{#State 130
		DEFAULT => -109,
		GOTOS => {
			'@17-1' => 151
		}
	},
	{#State 131
		DEFAULT => -107
	},
	{#State 132
		ACTIONS => {
			'Empty_line' => 114,
			'EOL' => 3,
			'Table_separator' => 24,
			'Include' => 23,
			'Named_variable' => 95,
			'StreamedPart' => 50,
			'Table' => 27,
			'Symbolic_variable' => 42,
			'Space' => 56,
			'Word' => 30,
			'Tag_name' => 58,
			'Embed' => 14
		},
		DEFAULT => -72,
		GOTOS => {
			'included' => 2,
			'literals_and_empty_lines' => 152,
			'table' => 53,
			'embedded' => 41,
			'literal_or_empty_line' => 115,
			'basic' => 12,
			'optional_literals_and_empty_lines' => 153,
			'table_separator' => 48,
			'literal' => 117,
			'tag' => 43,
			'element' => 13
		}
	},
	{#State 133
		DEFAULT => -64,
		GOTOS => {
			'@14-3' => 154
		}
	},
	{#State 134
		DEFAULT => -98
	},
	{#State 135
		DEFAULT => -83
	},
	{#State 136
		DEFAULT => -16
	},
	{#State 137
		ACTIONS => {
			'Empty_line' => 114,
			'EOL' => 3,
			'Table_separator' => 24,
			'Include' => 23,
			'Named_variable' => 95,
			'StreamedPart' => 50,
			'Table' => 27,
			'Symbolic_variable' => 42,
			'Space' => 56,
			'Word' => 30,
			'Tag_name' => 58,
			'Embed' => 14
		},
		DEFAULT => -72,
		GOTOS => {
			'included' => 2,
			'literals_and_empty_lines' => 152,
			'table' => 53,
			'embedded' => 41,
			'literal_or_empty_line' => 115,
			'basic' => 12,
			'optional_literals_and_empty_lines' => 155,
			'table_separator' => 48,
			'literal' => 117,
			'tag' => 43,
			'element' => 13
		}
	},
	{#State 138
		DEFAULT => -71
	},
	{#State 139
		DEFAULT => -56
	},
	{#State 140
		DEFAULT => -21
	},
	{#State 141
		DEFAULT => -130,
		GOTOS => {
			'@28-4' => 156
		}
	},
	{#State 142
		DEFAULT => -75
	},
	{#State 143
		DEFAULT => -58
	},
	{#State 144
		DEFAULT => -51
	},
	{#State 145
		ACTIONS => {
			'Table_separator' => 24,
			'Include' => 23,
			'Named_variable' => 95,
			'StreamedPart' => 50,
			'Table' => 27,
			'Symbolic_variable' => 42,
			'Space' => 56,
			'Word' => 30,
			'Tag_name' => 58,
			'Embed' => 14
		},
		DEFAULT => -81,
		GOTOS => {
			'included' => 2,
			'table' => 53,
			'embedded' => 41,
			'basic' => 135,
			'table_separator' => 48,
			'tag' => 43,
			'element' => 13
		}
	},
	{#State 146
		ACTIONS => {
			'Empty_line' => 157
		}
	},
	{#State 147
		ACTIONS => {
			"<" => 159
		},
		DEFAULT => -114,
		GOTOS => {
			'optional_tagbody' => 158
		}
	},
	{#State 148
		ACTIONS => {
			'EOL' => 3,
			'Table_separator' => 24,
			'Include' => 23,
			'Named_variable' => 95,
			'StreamedPart' => 50,
			'Table' => 27,
			'Symbolic_variable' => 42,
			'Space' => 56,
			'Word' => 30,
			'Tag_name' => 58,
			'Embed' => 14
		},
		DEFAULT => -68,
		GOTOS => {
			'included' => 2,
			'literals' => 109,
			'table' => 53,
			'embedded' => 41,
			'basic' => 12,
			'table_separator' => 48,
			'literal' => 111,
			'optional_literals' => 160,
			'tag' => 43,
			'element' => 13
		}
	},
	{#State 149
		DEFAULT => -106
	},
	{#State 150
		ACTIONS => {
			'Word' => 130
		},
		GOTOS => {
			'tagpar' => 161
		}
	},
	{#State 151
		ACTIONS => {
			"=" => 162
		}
	},
	{#State 152
		ACTIONS => {
			'Empty_line' => 114,
			'EOL' => 3,
			'Table_separator' => 24,
			'Include' => 23,
			'Named_variable' => 95,
			'StreamedPart' => 50,
			'Table' => 27,
			'Symbolic_variable' => 42,
			'Space' => 56,
			'Word' => 30,
			'Tag_name' => 58,
			'Embed' => 14
		},
		DEFAULT => -73,
		GOTOS => {
			'included' => 2,
			'table' => 53,
			'embedded' => 41,
			'literal_or_empty_line' => 142,
			'basic' => 12,
			'table_separator' => 48,
			'literal' => 117,
			'tag' => 43,
			'element' => 13
		}
	},
	{#State 153
		ACTIONS => {
			'Embedded' => 163
		}
	},
	{#State 154
		ACTIONS => {
			'Empty_line' => 164
		}
	},
	{#State 155
		ACTIONS => {
			'Tabled' => 165
		}
	},
	{#State 156
		ACTIONS => {
			'EOL' => 3,
			'Table_separator' => 24,
			'Include' => 23,
			'Named_variable' => 95,
			'StreamedPart' => 50,
			'Table' => 27,
			'Symbolic_variable' => 42,
			'Space' => 56,
			'Word' => 30,
			'Tag_name' => 58,
			'Embed' => 14
		},
		GOTOS => {
			'included' => 2,
			'text' => 166,
			'table' => 53,
			'embedded' => 41,
			'basic' => 12,
			'table_separator' => 48,
			'literal' => 31,
			'tag' => 43,
			'element' => 13
		}
	},
	{#State 157
		DEFAULT => -62
	},
	{#State 158
		DEFAULT => -103
	},
	{#State 159
		DEFAULT => -115,
		GOTOS => {
			'@19-1' => 167
		}
	},
	{#State 160
		ACTIONS => {
			'Empty_line' => 168
		}
	},
	{#State 161
		DEFAULT => -108
	},
	{#State 162
		DEFAULT => -110,
		GOTOS => {
			'@18-3' => 169
		}
	},
	{#State 163
		DEFAULT => -126
	},
	{#State 164
		DEFAULT => -65
	},
	{#State 165
		DEFAULT => -119
	},
	{#State 166
		DEFAULT => -131
	},
	{#State 167
		ACTIONS => {
			'EOL' => 3,
			'Table_separator' => 24,
			'Include' => 23,
			'Named_variable' => 95,
			'StreamedPart' => 50,
			'Table' => 27,
			'Symbolic_variable' => 42,
			'Space' => 56,
			'Word' => 30,
			'Tag_name' => 58,
			'Embed' => 14
		},
		GOTOS => {
			'included' => 2,
			'literals' => 170,
			'table' => 53,
			'embedded' => 41,
			'basic' => 12,
			'table_separator' => 48,
			'literal' => 111,
			'tag' => 43,
			'element' => 13
		}
	},
	{#State 168
		DEFAULT => -123
	},
	{#State 169
		ACTIONS => {
			"\"" => 171,
			'Word' => 173
		},
		GOTOS => {
			'tagvalue' => 172
		}
	},
	{#State 170
		ACTIONS => {
			'EOL' => 3,
			'Table_separator' => 24,
			'Include' => 23,
			'Named_variable' => 95,
			'StreamedPart' => 50,
			'Table' => 27,
			'Symbolic_variable' => 42,
			">" => 174,
			'Space' => 56,
			'Word' => 30,
			'Tag_name' => 58,
			'Embed' => 14
		},
		GOTOS => {
			'included' => 2,
			'table' => 53,
			'embedded' => 41,
			'basic' => 12,
			'table_separator' => 48,
			'literal' => 138,
			'tag' => 43,
			'element' => 13
		}
	},
	{#State 171
		ACTIONS => {
			'Table' => 27,
			'Symbolic_variable' => 42,
			'Space' => 56,
			'Table_separator' => 24,
			'Include' => 23,
			'Word' => 30,
			'Tag_name' => 58,
			'Named_variable' => 95,
			'StreamedPart' => 50,
			'Embed' => 14
		},
		GOTOS => {
			'included' => 2,
			'table' => 53,
			'embedded' => 41,
			'basic' => 107,
			'basics' => 175,
			'table_separator' => 48,
			'tag' => 43,
			'element' => 13
		}
	},
	{#State 172
		DEFAULT => -111
	},
	{#State 173
		DEFAULT => -112
	},
	{#State 174
		DEFAULT => -116
	},
	{#State 175
		ACTIONS => {
			'Table' => 27,
			'Symbolic_variable' => 42,
			"\"" => 176,
			'Space' => 56,
			'Table_separator' => 24,
			'Include' => 23,
			'Word' => 30,
			'Tag_name' => 58,
			'Named_variable' => 95,
			'StreamedPart' => 50,
			'Embed' => 14
		},
		GOTOS => {
			'included' => 2,
			'table' => 53,
			'embedded' => 41,
			'basic' => 135,
			'table_separator' => 48,
			'tag' => 43,
			'element' => 13
		}
	},
	{#State 176
		DEFAULT => -113
	}
],
                                  yyrules  =>
[
	[#Rule 0
		 '$start', 2, undef
	],
	[#Rule 1
		 'document', 1,
sub
#line 1274 "ppParser.yp"
{
             # skip empty line "paragraphs"
             unless ($_[1][0] eq '')
              {
               # add data to the output stream
               push(@$resultStreamRef, @{$_[1][0]});

  	       # update checksums (unless done before for parts)
               updateChecksums($_[1][0], 'Paragraph_cache_hit') unless    $_[1][0][0][0]==DIRECTIVE_BLOCK
                                                                       or $_[1][0][0][0]==DIRECTIVE_DLIST
                                                                       or $_[1][0][0][0]==DIRECTIVE_OLIST
                                                                       or $_[1][0][0][0]==DIRECTIVE_ULIST
                                                                       or $_[1][0][0][0]==DIRECTIVE_HEADLINE;

               # update statistics, if necessary
               $statistics{$_[1][0][0][0]}++ unless not defined $_[1][0][0][0] or exists $embeddedParagraphs{$_[1][0][0][0]};

               # let the user know that something is going on
               print STDERR "\r", ' ' x length('[Info] '), '... ', $statistics{&DIRECTIVE_HEADLINE}, " chapters read."
                 if     $flags{vis}
                    and $_[1][0][0][0]==DIRECTIVE_HEADLINE
                    and not $statistics{&DIRECTIVE_HEADLINE} % $flags{vis};

               # this is for the parser to flag success
               1;
              }
            }
	],
	[#Rule 2
		 'document', 2,
sub
#line 1302 "ppParser.yp"
{
             # skip empty line "paragraphs"
             unless ($_[2][0] eq '')
              {
               # add data to the output stream, if necessary
               push(@$resultStreamRef, @{$_[2][0]});

               # update checksums, if necessary
               updateChecksums($_[2][0], 'Paragraph_cache_hit') unless    $_[2][0][0][0]==DIRECTIVE_BLOCK
                                                                       or $_[2][0][0][0]==DIRECTIVE_DLIST
                                                                       or $_[2][0][0][0]==DIRECTIVE_OLIST
                                                                       or $_[2][0][0][0]==DIRECTIVE_ULIST
                                                                       or $_[2][0][0][0]==DIRECTIVE_HEADLINE;

               # update ordered list flag as necessary
               $flags{olist}=0 unless $_[2][0][0][0]==DIRECTIVE_OLIST;

               # update statistics, if necessary
               $statistics{$_[2][0][0][0]}++ unless exists $embeddedParagraphs{$_[2][0][0][0]};

               # let the user know that something is going on
               print STDERR "\r", ' ' x length('[Info] '), '... ', $statistics{&DIRECTIVE_HEADLINE}, " chapters read."
                 if     $flags{vis}
                    and $_[2][0][0][0]==DIRECTIVE_HEADLINE
                    and not $statistics{&DIRECTIVE_HEADLINE} % $flags{vis};

               # this is for the parser to flag success
               1;
              }
            }
	],
	[#Rule 3
		 'paragraph', 1, undef
	],
	[#Rule 4
		 'paragraph', 1, undef
	],
	[#Rule 5
		 'paragraph', 1,
sub
#line 1338 "ppParser.yp"
{
              # check if this paragraph consists only of exactly one table
              if (
                   # starting with a table tag?
                       ref($_[1][0][1]) eq 'ARRAY'
                   and $_[1][0][1][0]==DIRECTIVE_TAG
                   and $_[1][0][1][2]=~/^(IMAGE|TABLE)$/

                   # ending with a table tag?
                   and ref($_[1][0][-2]) eq 'ARRAY'
                   and $_[1][0][-2][0]==DIRECTIVE_TAG
                   and $_[1][0][-2][2] eq $1

                   # both covering the same table?
                   and $_[1][0][-2][3] eq $_[1][0][1][3]
                 )
               {
                # remove the enclosing paragraph stuff - just return the table
                shift(@{$_[1][0]});         # text paragraph opener
                pop(@{$_[1][0]});           # text paragraph trailer
               }

              # pass (original or modified) data
              $_[1];
             }
	],
	[#Rule 6
		 'paragraph', 1, undef
	],
	[#Rule 7
		 'paragraph', 1, undef
	],
	[#Rule 8
		 'paragraph', 1, undef
	],
	[#Rule 9
		 'paragraph', 1, undef
	],
	[#Rule 10
		 'paragraph', 1, undef
	],
	[#Rule 11
		 'paragraph', 1,
sub
#line 1369 "ppParser.yp"
{

              # by default, simply pass data
              $_[1];
             }
	],
	[#Rule 12
		 'paragraph', 1, undef
	],
	[#Rule 13
		 'paragraph', 1, undef
	],
	[#Rule 14
		 'paragraph', 1, undef
	],
	[#Rule 15
		 '@1-1', 0,
sub
#line 1381 "ppParser.yp"
{
             # switch to headline mode
             stateManager(STATE_HEADLINE);

             # update headline level hint
             $flags{headlineLevel}=$_[1][0];

             # trace, if necessary
             warn "[Trace] $sourceFile, line $_[1][1]: Headline (of level $_[1][0]) starts.\n" if $flags{trace} & TRACE_PARAGRAPHS;
            }
	],
	[#Rule 16
		 'headline', 4,
sub
#line 1392 "ppParser.yp"
{
             # back to default mode
             stateManager(STATE_DEFAULT);

             # trace, if necessary
             warn "[Trace] $sourceFile, line $_[4][1]: Headline completed.\n" if $flags{trace} & TRACE_PARAGRAPHS;

             # remove trailing whitespace (it represents the final newline)
             pop(@{$_[3][0]}) while $_[3][0][$#{$_[3][0]}]=~/^\s*$/;

	     # update related data
             @olistLevels=();

             # prepare result (data part only)
             my $data=[
                       # opener directive (including headline level)
                       [DIRECTIVE_HEADLINE, DIRECTIVE_START, $_[1][0]],
                       # the list of enclosed literals
                       @{$_[3][0]},
                       # final directive (including headline level again)
                       [DIRECTIVE_HEADLINE, DIRECTIVE_COMPLETE, $_[1][0]]
                      ];

             # update checksums (done here because hits need special handling)
             updateChecksums($data, 'Headline_cache_hit');

             # reply data
             [$data, $_[4][1]];
            }
	],
	[#Rule 17
		 'headline', 1,
sub
#line 1422 "ppParser.yp"
{
             # update headline level hint
             $flags{headlineLevel}=$_[1][0][0][2];

             # supply what you got unchanged
             $_[1];
            }
	],
	[#Rule 18
		 'headline_level', 1,
sub
#line 1433 "ppParser.yp"
{
                   # switch to headline intro mode
                   stateManager(STATE_HEADLINE_LEVEL);

                   # start new counter and reply it
                   [$flags{headlineLevelOffset}+1, $_[1][1]];
                  }
	],
	[#Rule 19
		 'headline_level', 2,
sub
#line 1441 "ppParser.yp"
{
                   # update counter and reply it
                   [$_[1][0]+1, $_[1][1]];
                  }
	],
	[#Rule 20
		 '@2-1', 0,
sub
#line 1449 "ppParser.yp"
{
               # switch to condition mode
               stateManager(STATE_CONDITION);

               # trace, if necessary
               warn "[Trace] $sourceFile, line $_[1][1]: Condition paragraph starts.\n" if $flags{trace} & TRACE_PARAGRAPHS;
              }
	],
	[#Rule 21
		 'condition', 4,
sub
#line 1457 "ppParser.yp"
{
               # back to default mode
               stateManager(STATE_DEFAULT);

               # trace, if necessary
               warn "[Trace] $sourceFile, line $_[4][1]: condition completed.\n" if $flags{trace} & TRACE_PARAGRAPHS;

                # The condition is written in Perl, anything passed really?
                # And does the caller want to evaluate the code?
                if (@{$_[3][0]} and $safeObject)
                  {
                   # trace, if necessary
                   warn "[Trace] Evaluating condition ...\n" if $flags{trace} & TRACE_SEMANTIC;

                   # update active contents base data, if necessary
                   if ($flags{activeBaseData})
                     {
                      no strict 'refs';
                      ${join('::', ref($safeObject) ? $safeObject->root : 'main', 'PerlPoint')}=dclone($flags{activeBaseData});
                     }

                   # make the Perl code a string and evaluate it
                   my $perl=join('', @{$_[3][0]});
                   $^W=0;
                   warn "[Trace] $sourceFile, line $_[6][1]: Evaluating condition code:\n\n$perl\n\n\n" if $flags{trace} & TRACE_ACTIVE;
                   my $result=ref($safeObject) ? $safeObject->reval($perl) : eval(join(' ', '{package main; no strict;', $perl, '}'));
                   $^W=1;

                   # check result
                   if ($@)
                     {warn "[Error ", ++$semErr, "] $sourceFile, line $_[3][1]: condition code could not be evaluated: $@.\n";}
                   else
                     {
                      # trace, if necessary
                      warn "[Trace] Condition is ", (defined $result and $result) ? 'true, parsing continues' : 'false, parsing is temporarily suspended', ".\n" if $flags{trace} & TRACE_SEMANTIC;

                      # success - configure parser behaviour according to result
                      $flags{skipInput}=1 unless (defined $result and $result);
                     }
                  }
                else
                  {
                   # trace, if necessary
                   warn "[Trace] Condition is not evaluated because of disabled active contents.\n" if $flags{trace} & TRACE_SEMANTIC;
                  }

               # we have to supply something, but it should be nothing (note that this is a *paragraph*, so reply a *string*)
               ['', $_[4][1]];
              }
	],
	[#Rule 22
		 'list', 1, undef
	],
	[#Rule 23
		 'list', 2,
sub
#line 1511 "ppParser.yp"
{
         # update token list and reply it
         push(@{$_[1][0]}, @{$_[2][0]});
         [$_[1][0], $_[2][1]];
        }
	],
	[#Rule 24
		 'list', 3,
sub
#line 1517 "ppParser.yp"
{
         # update statistics, if necessary (shifters are not passed as standalone paragraphs, so ...)
         $statistics{$_[2][0][0][0]}++;

         # update token list and reply it
         push(@{$_[1][0]}, @{$_[2][0]}, @{$_[3][0]});
         [$_[1][0], $_[2][1]];
        }
	],
	[#Rule 25
		 'list_part', 1,
sub
#line 1529 "ppParser.yp"
{
              # the first point may start by a certain number, check this
              my $start=(defined $_[1][0][0][2] and $_[1][0][0][2]>1) ? $_[1][0][0][2] : 1;

              # embed the points into list directives
              [
               [
                # opener directive
                [DIRECTIVE_OLIST, DIRECTIVE_START, $start],
                # the list of enclosed literals
                @{$_[1][0]},
                # final directive
                [DIRECTIVE_OLIST, DIRECTIVE_COMPLETE, $start]
               ],
               $_[1][1]
              ];
             }
	],
	[#Rule 26
		 'list_part', 1,
sub
#line 1547 "ppParser.yp"
{
              # reset ordered list flag
              $flags{olist}=0;

              # embed the points into list directives
              [
               [
                # opener directive
                [DIRECTIVE_ULIST, DIRECTIVE_START],
                # the list of enclosed literals
                @{$_[1][0]},
                # final directive
                [DIRECTIVE_ULIST, DIRECTIVE_COMPLETE]
               ],
               $_[1][1]
              ];
             }
	],
	[#Rule 27
		 'list_part', 1,
sub
#line 1565 "ppParser.yp"
{
              # reset ordered list flag
              $flags{olist}=0;

              # embed the points into list directives
              [
               [
                # opener directive
                [DIRECTIVE_DLIST, DIRECTIVE_START],
                # the list of enclosed literals
                @{$_[1][0]},
                # final directive
                [DIRECTIVE_DLIST, DIRECTIVE_COMPLETE]
               ],
               $_[1][1]
              ];
             }
	],
	[#Rule 28
		 'olist', 1, undef
	],
	[#Rule 29
		 'olist', 2,
sub
#line 1587 "ppParser.yp"
{
          # update token list and reply it
          push(@{$_[1][0]}, @{$_[2][0]});
          [$_[1][0], $_[2][1]];
         }
	],
	[#Rule 30
		 'ulist', 1, undef
	],
	[#Rule 31
		 'ulist', 2,
sub
#line 1597 "ppParser.yp"
{
          # update token list and reply it
          push(@{$_[1][0]}, @{$_[2][0]});
          [$_[1][0], $_[2][1]];
         }
	],
	[#Rule 32
		 'dlist', 1, undef
	],
	[#Rule 33
		 'dlist', 2,
sub
#line 1607 "ppParser.yp"
{
          # update token list and reply it
          push(@{$_[1][0]}, @{$_[2][0]});
          [$_[1][0], $_[2][1]];
         }
	],
	[#Rule 34
		 '@3-1', 0,
sub
#line 1616 "ppParser.yp"
{
           # switch to opoint mode
           stateManager(STATE_OPOINT);

           # trace, if necessary
           warn "[Trace] $sourceFile, line $_[1][1]: Ordered list point starts.\n" if $flags{trace} & TRACE_PARAGRAPHS;
          }
	],
	[#Rule 35
		 'opoint', 3,
sub
#line 1624 "ppParser.yp"
{
           # update statistics (list points are not passed as standalone paragraphs, so ...)
           $statistics{&DIRECTIVE_OPOINT}++;

           # trace, if necessary
           warn "[Trace] $sourceFile, line $_[3][1]: Ordered list point completed.\n" if $flags{trace} & TRACE_PARAGRAPHS;

           # remove leading whitespaces from point text (it separated number wildcard and literal text part)
           splice(@{$_[3][0]}, 1, 1) while not ref($_[3][0][1]) and $_[3][0][1]=~/^\s*$/;

           # reply data (they are already well prepared except that they are marked as text)
           $_[3][0][0][0]=$_[3][0][$#{$_[3][0]}][0]=&DIRECTIVE_OPOINT;

           # update list level hints as necessary
           $olistLevels[0]=(($flags{olist} or $_[1][0]) and @olistLevels) ? $olistLevels[0]+1 : 1;

	   # add a level hint, if necessary
	   if ($_[1][0] and not $flags{olist} and $olistLevels[0]>1)
	     {
	      push(@{$_[3][0][0]}, $olistLevels[0]);
	      push(@{$_[3][0][$#{$_[3][0]}]}, $olistLevels[0]);
	     }

           # update ordered list flag
           $flags{olist}=1;

	   # update checksums
	   updateChecksums($_[3][0], 'Opoint_cache_hit');

	   # supply result
           $_[3];
          }
	],
	[#Rule 36
		 'opoint', 1,
sub
#line 1657 "ppParser.yp"
{
           # update list level hints as necessary
           $olistLevels[0]=($flags{olist} and @olistLevels) ? $olistLevels[0]+1 : 1;

           # update continued list points
           $_[1][0][0][2]=$olistLevels[0] if @{$_[1][0][0]}>2;

           # update ordered list flag
           $flags{olist}=1;

           # supply updated stream snippet
           $_[1];
          }
	],
	[#Rule 37
		 'opoint_opener', 1,
sub
#line 1675 "ppParser.yp"
{[0, $_[1][1]];}
	],
	[#Rule 38
		 'opoint_opener', 2,
sub
#line 1677 "ppParser.yp"
{[1, $_[1][1]];}
	],
	[#Rule 39
		 '@4-1', 0,
sub
#line 1682 "ppParser.yp"
{
           # switch to upoint mode
           stateManager(STATE_UPOINT);

           # trace, if necessary
           warn "[Trace] $sourceFile, line $_[1][1]: Unordered list point starts.\n" if $flags{trace} & TRACE_PARAGRAPHS;
          }
	],
	[#Rule 40
		 'upoint', 3,
sub
#line 1690 "ppParser.yp"
{
           # update statistics (list points are not passed as standalone paragraphs, so ...)
           $statistics{&DIRECTIVE_UPOINT}++;

           # trace, if necessary
           warn "[Trace] $sourceFile, line $_[3][1]: Unordered list point completed.\n" if $flags{trace} & TRACE_PARAGRAPHS;

           # remove leading whitespaces from point text (it separated bullet and literal text part)
           splice(@{$_[3][0]}, 1, 1) while not ref($_[3][0][1]) and $_[3][0][1]=~/^\s*$/;

           # remove trailing whitespaces from point text (it represents the final newline character)
           splice(@{$_[3][0]}, -2, 1) while not ref($_[3][0][$#{$_[3][0]}-1]) and $_[3][0][$#{$_[3][0]}-1]=~/^\s*$/;

           # reply data (they are already well prepared except that they are marked as text)
           $_[3][0][0][0]=$_[3][0][$#{$_[3][0]}][0]=&DIRECTIVE_UPOINT;

	   # update checksums
	   updateChecksums($_[3][0], 'Upoint_cache_hit');

	   # supply result
           $_[3];
          }
	],
	[#Rule 41
		 'upoint', 1, undef
	],
	[#Rule 42
		 '@5-1', 0,
sub
#line 1718 "ppParser.yp"
{
          }
	],
	[#Rule 43
		 'dpoint', 3,
sub
#line 1721 "ppParser.yp"
{
           # update statistics (list points are not passed as standalone paragraphs, so ...)
           $statistics{&DIRECTIVE_DPOINT}++;

           # trace, if necessary
           warn "[Trace] $sourceFile, line $_[3][1]: Definition list point completed.\n" if $flags{trace} & TRACE_PARAGRAPHS;

           # remove leading whitespaces from point text (it separated point introduction and literal text part)
           splice(@{$_[3][0]}, 1, 1) while not ref($_[3][0][1]) and $_[3][0][1]=~/^\s*$/;

           # reply data (they are already well prepared except that they are marked as text, and that the definition item stream needs to be added)
           $_[3][0][0]=[DIRECTIVE_DPOINT, DIRECTIVE_START];
           $_[3][0][$#{$_[3][0]}]=[DIRECTIVE_DPOINT, DIRECTIVE_COMPLETE];

           # insert the definition item stream
           splice(@{$_[3][0]}, 1, 0,
                  [DIRECTIVE_DPOINT_ITEM, DIRECTIVE_START],
                  @{$_[1][0]},
                  [DIRECTIVE_DPOINT_ITEM, DIRECTIVE_COMPLETE],
                 );

	   # update checksums
	   updateChecksums($_[3][0], 'Dpoint_cache_hit');

           # supply the result
           $_[3];
          }
	],
	[#Rule 44
		 'dpoint', 1, undef
	],
	[#Rule 45
		 '@6-1', 0,
sub
#line 1754 "ppParser.yp"
{
                 # switch to dlist item mode
                 stateManager(STATE_DPOINT_ITEM);

                 # trace, if necessary
                 warn "[Trace] $sourceFile, line $_[1][1]: Definition list point starts.\n" if $flags{trace} & TRACE_PARAGRAPHS;
                }
	],
	[#Rule 46
		 'dlist_opener', 4,
sub
#line 1762 "ppParser.yp"
{
                 # switch to dlist body mode
                 stateManager(STATE_DPOINT);

                 # simply pass the elements
                 [$_[3][0], $_[4][1]];
                }
	],
	[#Rule 47
		 'compound_block', 1, undef
	],
	[#Rule 48
		 'compound_block', 2,
sub
#line 1775 "ppParser.yp"
{
                   # this is tricky - to combine both blocks, we have to remove the already
                   # embedded stop/start directives and to supply the 
                   [
                    [
                     # original collection WITHOUT the final directive ...
                     @{$_[1][0]}[0..$#{$_[1][0]}-1],
                     # insert an additional newline character (restoring the original empty line)
                     "\n",
                     # ... combined with the new block, except of its INTRO directive
                     @{$_[2][0]}[1..$#{$_[2][0]}],
                    ],
                    $_[2][1]
                   ];
                  }
	],
	[#Rule 49
		 'compound_block', 3,
sub
#line 1791 "ppParser.yp"
{
                   # update statistics (for the first part which is completed by the intermediate flag paragraph)
                   $statistics{&DIRECTIVE_BLOCK}++;

                   # this is simply a list of both blocks
                   [
                    [
                     # original collection
                     @{$_[1][0]},
                     # ... followed by the new block
                     @{$_[3][0]},
                    ],
                    $_[3][1]
                   ];
                  }
	],
	[#Rule 50
		 '@7-1', 0,
sub
#line 1810 "ppParser.yp"
{
                  # switch to control mode
                  stateManager(STATE_CONTROL);

                  # trace, if necessary
                  warn "[Trace] $sourceFile, line $_[1][1]: New block flag starts.\n" if $flags{trace} & TRACE_PARAGRAPHS;
                 }
	],
	[#Rule 51
		 'block_flagnew', 3,
sub
#line 1818 "ppParser.yp"
{
                  # back to default mode
                  stateManager(STATE_DEFAULT);

                  # trace, if necessary
                  warn "[Trace] $sourceFile, line $_[1][1]: New block flag completed.\n" if $flags{trace} & TRACE_PARAGRAPHS;

                  # reply data (these are dummies because block connectors are not made part of the output stream)
                  $_[3];
                 }
	],
	[#Rule 52
		 '@8-1', 0,
sub
#line 1832 "ppParser.yp"
{
          # switch to block mode
          stateManager(STATE_BLOCK);

          # trace, if necessary
          warn "[Trace] $sourceFile, line $_[1][1]: Block starts.\n" if $flags{trace} & TRACE_PARAGRAPHS;
         }
	],
	[#Rule 53
		 'block', 3,
sub
#line 1840 "ppParser.yp"
{
          # trace, if necessary
          warn "[Trace] $sourceFile, line $_[3][1]: Block completed.\n" if $flags{trace} & TRACE_PARAGRAPHS;

          # reply data (they are almost perfect except that they are marked as text,
          # and that the initial spaces have to be inserted)
          $_[3][0][0][0]=$_[3][0][$#{$_[3][0]}][0]=DIRECTIVE_BLOCK;
          splice(@{$_[3][0]}, 1, 0, $_[1][0]);

	  # update checksums
	  updateChecksums($_[3][0], 'Block_cache_hit');

	  # supply result
          $_[3];
         }
	],
	[#Rule 54
		 'block', 1, undef
	],
	[#Rule 55
		 '@9-1', 0,
sub
#line 1860 "ppParser.yp"
{
         # enter text mode - unless we are in a block (or point (which already set this mode itself))
         unless (   $parserState==STATE_BLOCK
                 or $parserState==STATE_UPOINT
                 or $parserState==STATE_OPOINT
                 or $parserState==STATE_DPOINT
                 or $parserState==STATE_DPOINT_ITEM
                 or $parserState==STATE_DEFINITION
                )
          {
           # switch to new mode
           stateManager(STATE_TEXT);

           # trace, if necessary
           warn "[Trace] $sourceFile, line $_[1][1]: Text starts.\n" if $flags{trace} & TRACE_PARAGRAPHS;
          }
        }
	],
	[#Rule 56
		 'text', 4,
sub
#line 1879 "ppParser.yp"
{
         # trace, if necessary
         warn "[Trace] $sourceFile, line $_[4][1]: Text completed.\n" unless    not $flags{trace} & TRACE_PARAGRAPHS
                                                                or $parserState==STATE_BLOCK
                                                                or $parserState==STATE_UPOINT
                                                                or $parserState==STATE_OPOINT
                                                                or $parserState==STATE_DPOINT
                                                                or $parserState==STATE_DPOINT_ITEM;

         # back to default mode
         stateManager(STATE_DEFAULT);

         # remove the final EOL literal, if any
         pop(@{$_[3][0]}) if defined $_[3][0][-1] and $_[3][0][-1] eq 'EOL';

         # remove the final whitespace string made from the last carriage return, if any
         pop(@{$_[3][0]}) if defined $_[3][0][-1] and $_[3][0][-1] eq ' ';

         # reply data, if any
         [
          [
           # opener directive
           [DIRECTIVE_TEXT, DIRECTIVE_START],
           # the list of enclosed literals
           @{$_[1][0]}, @{$_[3][0]},
           # final directive
           [DIRECTIVE_TEXT, DIRECTIVE_COMPLETE],
          ],
          $_[4][1],
         ];
        }
	],
	[#Rule 57
		 '@10-1', 0,
sub
#line 1914 "ppParser.yp"
{
             # switch to verbatim mode
             stateManager(STATE_VERBATIM);

             # trace, if necessary
             warn "[Trace] $sourceFile, line $_[1][1]: Verbatim block starts.\n" if $flags{trace} & TRACE_PARAGRAPHS;

             # check close hint: should be different from "1"
             warn "[Error ", ++$semErr, "] A heredoc close hint should be different from \"1\".\n" if $_[1][0] eq '1';

             # store close hint
             $specials{heredoc}=$_[1][0];
            }
	],
	[#Rule 58
		 'verbatim', 4,
sub
#line 1929 "ppParser.yp"
{
             # trace, if necessary
             warn "[Trace] $sourceFile, line $_[4][1]: Verbatim block completed.\n" if $flags{trace} & TRACE_PARAGRAPHS;

             # back to default mode
             stateManager(STATE_DEFAULT);

             # delete the initial newline (which follows the opener but is no part of the block)
             shift(@{$_[3][0]});

             # reply data
             [
              [
               # opener directive
               [DIRECTIVE_VERBATIM, DIRECTIVE_START],
               # the list of enclosed literals
               @{$_[3][0]},
               # final directive
               [DIRECTIVE_VERBATIM, DIRECTIVE_COMPLETE]
              ],
              $_[4][1]
             ];
            }
	],
	[#Rule 59
		 '@11-2', 0,
sub
#line 1956 "ppParser.yp"
{
                        # switch to text mode to allow *all* characters starting a variable value!
                        stateManager(STATE_TEXT);

                        # trace, if necessary
                        warn "[Trace] $sourceFile, line $_[1][1]: Variable assignment starts.\n" if $flags{trace} & TRACE_PARAGRAPHS;
                       }
	],
	[#Rule 60
		 'variable_assignment', 4,
sub
#line 1964 "ppParser.yp"
{
                        # remove text directives and the final space (made from the final EOL)
                        shift(@{$_[4][0]});
                        pop(@{$_[4][0]});

                        # make the text contents a string and store it
                        $variables{$_[1][0]}=join('', @{$_[4][0]});

                        # update variable checksum
                        $varChecksum=sha1_base64(nfreeze(\%variables));

                        # propagate the setting to the stream, if necessary
                        push(@$resultStreamRef, [DIRECTIVE_VARSET, DIRECTIVE_START, {var=>$_[1][0], value=>$variables{$_[1][0]}}]) if $flags{var2stream};

                        # make the new variable setting available to embedded Perl code, if necessary
                        if ($safeObject)
                         {
                          no strict 'refs';
                          ${join('::', ref($safeObject) ? $safeObject->root : 'main', $_[1][0])}=$variables{$_[1][0]};
                         }

                        # trace, if necessary
                        warn "[Trace] $sourceFile, line $_[4][1]: Variable assignment: \$$_[1][0]=$variables{$_[1][0]}.\n" if $flags{trace} & TRACE_PARAGRAPHS;

                        # flag this paragraph as internal
                        ['', $_[4][1]];
                       }
	],
	[#Rule 61
		 '@12-2', 0,
sub
#line 1995 "ppParser.yp"
{
            # switch to comment mode
            stateManager(STATE_COMMENT);

            # trace, if necessary
            warn "[Trace] $sourceFile, line $_[1][1]: Comment starts.\n" if $flags{trace} & TRACE_PARAGRAPHS;
           }
	],
	[#Rule 62
		 'comment', 5,
sub
#line 2003 "ppParser.yp"
{
            # back to default mode
            stateManager(STATE_DEFAULT);

            # trace, if necessary
            warn "[Trace] $sourceFile, line $_[5][1]: Comment completed.\n" if $flags{trace} & TRACE_PARAGRAPHS;

            # reply data
            [
             [
              # opener directive
              [DIRECTIVE_COMMENT, DIRECTIVE_START],
              # the list of enclosed literals
              @{$_[4][0]},
              # final directive
              [DIRECTIVE_COMMENT, DIRECTIVE_COMPLETE]
             ],
             $_[5][1]
            ];
           }
	],
	[#Rule 63
		 '@13-1', 0,
sub
#line 2027 "ppParser.yp"
{
                # temporarily activate number detection
                push(@specialStack, $specials{number});
                $specials{number}=1;
               }
	],
	[#Rule 64
		 '@14-3', 0,
sub
#line 2033 "ppParser.yp"
{
                # restore previous number detection mode
                $specials{number}=pop(@specialStack);

                # switch to control mode
                stateManager(STATE_CONTROL);

                # trace, if necessary
                warn "[Trace] $sourceFile, line $_[3][1]: List shift ", $_[1][0]==LIST_SHIFT_RIGHT ? 'right' : 'left', " starts.\n" if $flags{trace} & TRACE_PARAGRAPHS;
               }
	],
	[#Rule 65
		 'list_shift', 5,
sub
#line 2044 "ppParser.yp"
{
                # back to default mode
                stateManager(STATE_DEFAULT);

                # trace, if necessary
                warn "[Trace] $sourceFile, line $_[5][1]: List shift ", $_[1][0]==LIST_SHIFT_RIGHT ? 'right' : 'left', " completed.\n" if $flags{trace} & TRACE_PARAGRAPHS;

                # update related data
                if ($_[1][0]==LIST_SHIFT_RIGHT)
		  {unshift(@olistLevels, 0) for (1..(defined $_[3][0] ? $_[3][0] : 1));}
		else
		  {shift(@olistLevels) for (1..(defined $_[3][0] ? $_[3][0] : 1));}

                # reset ordered list flag
                $flags{olist}=0;

                # reply data
                [
                 [
                  # opener directive
                  [$_[1][0]==LIST_SHIFT_RIGHT ? DIRECTIVE_LIST_RSHIFT : DIRECTIVE_LIST_LSHIFT, DIRECTIVE_START, defined $_[3][0] ? $_[3][0] : 1],
                  # final directive
                  [$_[1][0]==LIST_SHIFT_RIGHT ? DIRECTIVE_LIST_RSHIFT : DIRECTIVE_LIST_LSHIFT, DIRECTIVE_COMPLETE, defined $_[3][0] ? $_[3][0] : 1]
                 ],
                 $_[5][1]
                ];
               }
	],
	[#Rule 66
		 'list_shifter', 1,
sub
#line 2075 "ppParser.yp"
{
                 # reply a flag
                 [LIST_SHIFT_RIGHT, $_[1][1]];
                }
	],
	[#Rule 67
		 'list_shifter', 1,
sub
#line 2080 "ppParser.yp"
{
                 # reply a flag
                 [LIST_SHIFT_LEFT, $_[1][1]];
                }
	],
	[#Rule 68
		 'optional_literals', 0,
sub
#line 2088 "ppParser.yp"
{
                      # start a new, empty list and reply it
                      [[], $lineNrs{$inHandle}];
                     }
	],
	[#Rule 69
		 'optional_literals', 1, undef
	],
	[#Rule 70
		 'literals', 1, undef
	],
	[#Rule 71
		 'literals', 2,
sub
#line 2098 "ppParser.yp"
{
             # update token list and reply it
             push(@{$_[1][0]}, @{$_[2][0]});
             [$_[1][0], $_[2][1]];
            }
	],
	[#Rule 72
		 'optional_literals_and_empty_lines', 0,
sub
#line 2107 "ppParser.yp"
{
                                      # start a new, empty list and reply it
                                      [[], $lineNrs{$inHandle}];
                                     }
	],
	[#Rule 73
		 'optional_literals_and_empty_lines', 1, undef
	],
	[#Rule 74
		 'literals_and_empty_lines', 1, undef
	],
	[#Rule 75
		 'literals_and_empty_lines', 2,
sub
#line 2117 "ppParser.yp"
{
                             # update token list and reply it
                             push(@{$_[1][0]}, @{$_[2][0]});
                             [$_[1][0], $_[2][1]];
                            }
	],
	[#Rule 76
		 'literal_or_empty_line', 1, undef
	],
	[#Rule 77
		 'literal_or_empty_line', 1,
sub
#line 2127 "ppParser.yp"
{
                          # start a new token list and reply it
                          [[$_[1][0]], $_[1][1]];
                         }
	],
	[#Rule 78
		 'literal', 1, undef
	],
	[#Rule 79
		 'literal', 1,
sub
#line 2136 "ppParser.yp"
{
            # start a new token list and reply it
            [[$_[1][0]], $_[1][1]];
           }
	],
	[#Rule 80
		 'optional_basics', 0,
sub
#line 2144 "ppParser.yp"
{
                   # start a new, empty list and reply it
                   [[], $lineNrs{$inHandle}];
                  }
	],
	[#Rule 81
		 'optional_basics', 1, undef
	],
	[#Rule 82
		 'basics', 1, undef
	],
	[#Rule 83
		 'basics', 2,
sub
#line 2154 "ppParser.yp"
{
           # update token list and reply it
           push(@{$_[1][0]}, @{$_[2][0]});
           [$_[1][0], $_[2][1]];
          }
	],
	[#Rule 84
		 'basic', 1, undef
	],
	[#Rule 85
		 'basic', 1, undef
	],
	[#Rule 86
		 'basic', 1, undef
	],
	[#Rule 87
		 'elements', 1, undef
	],
	[#Rule 88
		 'elements', 2,
sub
#line 2172 "ppParser.yp"
{
             # update token list and reply it
             push(@{$_[1][0]}, @{$_[2][0]});
             [$_[1][0], $_[2][1]];
            }
	],
	[#Rule 89
		 'element', 1,
sub
#line 2182 "ppParser.yp"
{
	    # check string for variables (in boost mode only)
	    if (
                    !$flags{noboost}
                and $parserState!=STATE_VERBATIM
                and ($_[1][0]=~/(?<!\\)\$($patternWUmlauts)/ or $_[1][0]=~/(?<!\\)\${($patternWUmlauts)}/)
               )
	      {
	       # flag that this paragraph uses variables (a cache hit will only be useful if variable settings will be unchanged)
	       $flags{checksummed}[4]=1 unless exists $flags{checksummed} and not $flags{checksummed};

	       # replace all variables by their values
	       $_[1][0]=~s/(?<!\\)\$($patternWUmlauts)/exists $variables{$1} ? $variables{$1} : join('', '$', $1)/ge;
	       $_[1][0]=~s/(?<!\\)\${($patternWUmlauts)}/exists $variables{$1} ? $variables{$1} : join('', '$', $1)/ge;
	      }

            # start a new token list and reply it
            [[$_[1][0]], $_[1][1]];
           }
	],
	[#Rule 90
		 'element', 1,
sub
#line 2202 "ppParser.yp"
{
            # start a new token list and reply it
            [[$_[1][0]], $_[1][1]];
           }
	],
	[#Rule 91
		 'element', 1,
sub
#line 2207 "ppParser.yp"
{
            # flag that this paragraph uses macros (a cache hit will only be useful if variable settings will be unchanged)
            $flags{checksummed}[4]=1 unless exists $flags{checksummed} and not $flags{checksummed};

            # start a new token list and reply it
            [[exists $variables{$_[1][0]} ? $variables{$_[1][0]} : join('', '$', $_[1][0])], $_[1][1]];
           }
	],
	[#Rule 92
		 'element', 1,
sub
#line 2215 "ppParser.yp"
{
            # flag that this paragraph uses macros (a cache hit will only be useful if variable settings will be unchanged)
            $flags{checksummed}[4]=1 unless exists $flags{checksummed} and not $flags{checksummed};

            # start a new token list and reply it
            [[exists $variables{$_[1][0]} ? $variables{$_[1][0]} : join('', '$', "{$_[1][0]}")], $_[1][1]];
           }
	],
	[#Rule 93
		 'element', 1,
sub
#line 2223 "ppParser.yp"
{
            # start a new token list and reply it
            # (the passed stream is already a reference)
            [$_[1][0], $_[1][1]];
           }
	],
	[#Rule 94
		 'element', 1, undef
	],
	[#Rule 95
		 'element', 1, undef
	],
	[#Rule 96
		 'element', 1, undef
	],
	[#Rule 97
		 'optional_number', 0,
sub
#line 2236 "ppParser.yp"
{[undef, $lineNrs{$inHandle}];}
	],
	[#Rule 98
		 'optional_number', 1, undef
	],
	[#Rule 99
		 'words', 1,
sub
#line 2243 "ppParser.yp"
{
          # start a new token list and reply it
          [[$_[1][0]], $_[1][1]];
         }
	],
	[#Rule 100
		 'words', 2,
sub
#line 2248 "ppParser.yp"
{
          # update token list and reply it
          push(@{$_[1][0]}, $_[2][0]);
          [$_[1][0], $_[2][1]];
         }
	],
	[#Rule 101
		 '@15-1', 0,
sub
#line 2258 "ppParser.yp"
{
        # trace, if necessary
        warn "[Trace] $sourceFile, line $_[1][1]: Tag $_[1][0] starts.\n" if $flags{trace} & TRACE_PARAGRAPHS;

        # temporarily activate special "<" *as necessary*
        my $possible=   (exists $macros{$_[1][0]} and $macros{$_[1][0]}->[2])   # macro: evaluate body flag;
                     || $tagsRef->{$_[1][0]}{__flags__}{__body__};              # tag with body;
        push(@specialStack, $specials{'<'}), $specials{'<'}=1 if $possible;     # enable tag body, if necessary
        push(@specialStack, $possible);                                         # flags what is on stack;

        # temporarily activate specials "{" and "}" *as necessary*
        push(@specialStack, @specials{('{', '}')}), @specials{('{', '}')}=(1) x 2
         if    (exists $macros{$_[1][0]} and @{$macros{$_[1][0]}->[0]})         # macro: evaluate declared options;
            || $tagsRef->{$_[1][0]}{__flags__}{__options__};                    # tag with options;

	# deactivate boost
	$flags{noboost}=1;
       }
	],
	[#Rule 102
		 '@16-3', 0,
sub
#line 2277 "ppParser.yp"
{
	# reactivate boost
	$flags{noboost}=0;

        # restore special states of "{" and "}", if necessary
        @specials{('{', '}')}=splice(@specialStack, -2, 2)
         if    (exists $macros{$_[1][0]} and @{$macros{$_[1][0]}->[0]})         # macro: evaluate declared options;
            || $tagsRef->{$_[1][0]}{__flags__}{__options__};                    # tag with options;

        # check options in general if declared mandatory
        if (    
                not @{$_[3][0]}
            and exists $tagsRef->{$_[1][0]}
            and exists $tagsRef->{$_[1][0]}{options}
            and $tagsRef->{$_[1][0]}{options}==&TAGS_MANDATORY
           )
         {
          # display error message
          warn "\n\n[Fatal] $sourceFile, line $_[3][1]: Missing mandatory options of tag $_[1][0]\n";

          # this is an syntactical error, stop parsing
          $_[0]->YYAbort;
         }
       }
	],
	[#Rule 103
		 'tag', 5,
sub
#line 2302 "ppParser.yp"
{
        # trace, if necessary
        warn "[Trace] $sourceFile, line $_[5][1]: Tag $_[1][0] completed.\n" if $flags{trace} & TRACE_PARAGRAPHS;

        # check tag body in general if declared mandatory
        if (
                not @{$_[5][0]}
            and exists $tagsRef->{$_[1][0]}
            and exists $tagsRef->{$_[1][0]}{body}
            and $tagsRef->{$_[1][0]}{body}==&TAGS_MANDATORY
           )
         {
          # display error message
          warn "[Fatal] $sourceFile, line $_[5][1]: Missing mandatory body of tag $_[1][0]\n";

          # this is an syntactical error, stop parsing
          $_[0]->YYAbort;
         }

        # invoke hook function, if necessary
        if (exists $tagsRef->{$_[1][0]} and exists $tagsRef->{$_[1][0]}{hook})
         {
          # make an option hash
          my $options={@{$_[3][0]}};

          # call hook function (use eval() to guard yourself)
          my $rc;
          eval {$rc=&{$tagsRef->{$_[1][0]}{hook}}($_[1][1], $options, @{$_[3][0]})};

          # check result
          unless ($@)
           {
            {
             # semantic error?
             ++$semErr, last if $rc==PARSING_ERROR;

             # syntactical error?
             $_[0]->YYAbort, last if $rc==PARSING_FAILED;

             # update options (might be modified, and checking for a difference
             # might take more time then just copying the replied values)
             @{$_[3][0]}=%$options;

             # all right?
             last if $rc==PARSING_OK;

             # or even superb?
             $_[0]->YYAccept, last if $rc==PARSING_COMPLETED;

             # something is wrong here
             warn "[Warn] Tags $_[1][0] body hook replied unexpected result $rc, ignored.\n";
            }
           }
          else
           {warn "[Warn] Error in tags $_[1][0] body hook: $@\n"}
         }

        # build parameter hash, if necessary
        my %pars;
        if (@{$_[3][0]})
          {
           # the list already consists of key/value pairs
           %pars=@{$_[3][0]}
          }

        # this might be a macro as well as a tag - so what?
        unless (exists $macros{$_[1][0]})
          {
           # update statistics
           $statistics{&DIRECTIVE_TAG}++;

           # reply tag data
           [
            [
             # opener directive
             [DIRECTIVE_TAG, DIRECTIVE_START, $_[1][0], \%pars],
             # the list of enclosed literals, if any
             @{$_[5][0]} ? @{$_[5][0]} : (),
             # final directive
             [DIRECTIVE_TAG, DIRECTIVE_COMPLETE, $_[1][0], \%pars]
            ],
            $_[5][1]
           ];
          }
        else
          {
	   # flag that this paragraph uses macros (a cache hit will only be useful if macro definitions will have been unchanged)
	   $flags{checksummed}[3]=1 unless exists $flags{checksummed} and not $flags{checksummed};

           # this is a macro - resolve it!
           my $macro=$macros{$_[1][0]}->[1];

           # fill in parameters
           foreach my $par (@{$macros{$_[1][0]}->[0]})
             {
              my $value=exists $pars{$par} ? $pars{$par} : '';
              $macro=~s/__${par}__/$value/g;
             }

           # Bodyless macros need special care - the parser already got the subsequent token to
           # recognize that the macro was complete. Now, the macro replacement is reinserted into the stream
           # where it will be read by the next lexer operation which is enforced when the parser needs a token
           # again - and this will happen after processing the already receicved token which stood behind the
           # bodyless macro. Letting the parser process the read token this way, this token would be streamed
           # (in most cases) *before* the macro replacement, while it was intented to come after it. So, if we
           # detect this case, we move this token *behind* the macro replacement. As for the parser, we replace
           # this token by something streamed to "nothing", currently an empty string declared as "Word" token.
           my $delayedToken;
           unless (@{$_[5][0]})
             {
              # insert the current token behind the imaginary body
              $delayedToken=new PerlPoint::Parser::DelayedToken($_[0]->YYCurtok, $_[0]->YYCurval);

              # set new dummy values to let the parser work on
              # (something without effect and valid everywhere a tag is)
              $_[0]->YYCurtok('Word');
              $_[0]->YYCurval(['', $_[0]->YYCurval->[1]]);
             }

           # finally, pass the constructed text back to the input stream (by stack)
           stackInput($_[0], (map {$_ eq '__body__' ? dclone($_[5][0]) : split(/(\n)/, $_)} split(/(__body__)/, $macro)), $delayedToken ? $delayedToken : ());

           # reset the "end of input reached" flag if necessary
           $readCompletely=0 if $readCompletely;

           # reply nothing real
           [[()], $_[5][1]];
          }
       }
	],
	[#Rule 104
		 'optional_tagpars', 0,
sub
#line 2435 "ppParser.yp"
{[[], $lineNrs{$inHandle}];}
	],
	[#Rule 105
		 'optional_tagpars', 1, undef
	],
	[#Rule 106
		 'used_tagpars', 3,
sub
#line 2441 "ppParser.yp"
{
                 # supply the parameters
                 [$_[2][0], $_[3][1]];
                }
	],
	[#Rule 107
		 'tagpars', 1, undef
	],
	[#Rule 108
		 'tagpars', 3,
sub
#line 2450 "ppParser.yp"
{
            # update parameter list
            push(@{$_[1][0]}, @{$_[3][0]});

            # supply updated parameter list
            [$_[1][0], $_[3][1]];
           }
	],
	[#Rule 109
		 '@17-1', 0,
sub
#line 2461 "ppParser.yp"
{
           # temporarily make "=" and quotes the only specials,
           # but take care to reset the remaining settings defined
           push(@specialStack, [(%specials)], $specials{'='});
           @specials{keys %specials}=(0) x scalar(keys %specials);
           @specials{('=', '"')}=(1, 1);
          }
	],
	[#Rule 110
		 '@18-3', 0,
sub
#line 2469 "ppParser.yp"
{
           # restore special "=" setting
           $specials{'='}=pop(@specialStack);
          }
	],
	[#Rule 111
		 'tagpar', 5,
sub
#line 2474 "ppParser.yp"
{
           # restore special settings
           %specials=@{pop(@specialStack)};

           # supply flag and value
           [[$_[1][0], $_[5][0]], $_[5][1]];
          }
	],
	[#Rule 112
		 'tagvalue', 1, undef
	],
	[#Rule 113
		 'tagvalue', 3,
sub
#line 2485 "ppParser.yp"
{
             # build a string and supply it
             [join('', @{$_[2][0]}), $_[3][1]];
            }
	],
	[#Rule 114
		 'optional_tagbody', 0,
sub
#line 2493 "ppParser.yp"
{
                     # if we are here, "<" *possibly* was marked to be a special - now it becomes what is was before
                     # (take care the stack is filled correctly!)
                     my $possible=pop(@specialStack);                # was the body enabled?
                     $specials{'<'}=pop(@specialStack) if $possible; # if so, restore the stack

                     # supply an empty result
                     [[], $lineNrs{$inHandle}];
                    }
	],
	[#Rule 115
		 '@19-1', 0,
sub
#line 2503 "ppParser.yp"
{
                     # if we are here, "<" was marked to be a special - now it becomes what is was before
                     # (take care the stack is filled correctly!)
                     my $possible=pop(@specialStack);                # can be ignored - surely the body was enabled!
                     $specials{'<'}=pop(@specialStack);              # restore the stack

                     # temporarily activate special ">"
                     push(@specialStack, @specials{('>')});
                     @specials{('>')}=1;
                    }
	],
	[#Rule 116
		 'optional_tagbody', 4,
sub
#line 2514 "ppParser.yp"
{
                     # reset ">" setting
                     @specials{('>')}=pop(@specialStack);

                     # reply the literals
                     [$_[3][0], $_[4][1]];
                    }
	],
	[#Rule 117
		 '@20-1', 0,
sub
#line 2525 "ppParser.yp"
{
          # trace, if necessary
          warn "[Trace] $sourceFile, line $_[1][1]: Table starts.\n" if $flags{trace} & TRACE_PARAGRAPHS;

          # check nesting
          warn "[Error ", ++$semErr, "] $sourceFile, line $_[3][1]: Nested tables are not supported by this parser version.\n"
            if @tableSeparatorStack and not $flags{nestedTables};

          # temporarily activate specials "{" and "}"
          push(@specialStack, @specials{('{', '}')});
          @specials{('{', '}')}=(1, 1);

          # empty lines have to be ignored in tables
          push(@specialStack, $lexerFlags{el});
          $lexerFlags{el}=LEXER_IGNORE;

	  # deactivate boost
          $flags{noboost}=1;
         }
	],
	[#Rule 118
		 '@21-3', 0,
sub
#line 2545 "ppParser.yp"
{
          # reactivate boost
          $flags{noboost}=0;

          # restore previous handling of empty lines
          $lexerFlags{el}=pop(@specialStack);

          # restore special state of "{" and "}"
          @specials{('{', '}')}=splice(@specialStack, -2, 2);

          # read parameters and adapt them, if necessary
          my %tagpars=@{$_[3][0]};

          if (exists $tagpars{rowseparator})
            {
             $tagpars{rowseparator}=quotemeta($tagpars{rowseparator});
             $tagpars{rowseparator}="\n" if $tagpars{rowseparator} eq '\\\\n';
            }

	  # mark table start
          $tableColumns=0-(
			   exists $tagpars{gracecr} ? $tagpars{gracecr}
                                                    : (not exists $tagpars{rowseparator} or $tagpars{rowseparator} eq "\n") ? 1
                                                    : 0
			  );

          # store specified column separator (or default)
          unshift(@tableSeparatorStack, [
					 exists $tagpars{separator}    ? quotemeta($tagpars{separator}) : '\|',
					 exists $tagpars{rowseparator} ? $tagpars{rowseparator} : "\n",
					]);
         }
	],
	[#Rule 119
		 'table', 6,
sub
#line 2578 "ppParser.yp"
{
          # build parameter hash, if necessary
          my %pars;
          if (@{$_[3][0]})
            {
             # the list already consists of key/value pairs
             %pars=@{$_[3][0]}
            }

          # remove row separator information which is of no use to a converter
          delete $pars{rowseparator};

          # store nesting level information
          $pars{__nestingLevel__}=@tableSeparatorStack;

          # If we are here and found anything in the table, it is
          # possible that a final row was closed and a new one opened
          # (e.g. at the end of the last table line, if rows are separated
          # by "\n"). Because the table is completed now, these tags can
          # be removed to get the common case of an opened but not yet
          # completed table cell.
          splice(@{$_[5][0]}, -4, 4) if     @{$_[5][0]}
                                        and ref($_[5][0][-1]) eq 'ARRAY'
                                        and @{$_[5][0][-1]}==3
                                        and $_[5][0][-1][0] eq DIRECTIVE_TAG
                                        and $_[5][0][-1][1] eq DIRECTIVE_START
                                        and $_[5][0][-1][2] eq 'TABLE_COL';

          # normalize table rows (no need of auto format)
          normalizeTableRows($_[5][0], 0);

          # reset column separator memory, mark table completed
          shift(@tableSeparatorStack);
          $tableColumns=0;

          # reply data in a "tag envelope" (for backends)
          [
           [
            # opener directives
            [DIRECTIVE_TAG, DIRECTIVE_START, 'TABLE', \%pars],
            [DIRECTIVE_TAG, DIRECTIVE_START, 'TABLE_ROW'],
            [DIRECTIVE_TAG, DIRECTIVE_START, 'TABLE_COL'],
            # the list of enclosed literals reduced by the final two, if any
            @{$_[5][0]} ? @{$_[5][0]} : (),
            # final directive
            [DIRECTIVE_TAG, DIRECTIVE_COMPLETE, 'TABLE_COL'],
            [DIRECTIVE_TAG, DIRECTIVE_COMPLETE, 'TABLE_ROW'],
            [DIRECTIVE_TAG, DIRECTIVE_COMPLETE, 'TABLE', \%pars]
           ],
           $_[6][1]
          ];
         }
	],
	[#Rule 120
		 'table_separator', 1,
sub
#line 2634 "ppParser.yp"
{
                    # update counter of completed table columns
                    $tableColumns++;

                    # supply a simple seperator tag
                    [
                     [
                      [DIRECTIVE_TAG, DIRECTIVE_COMPLETE, 'TABLE_COL'],
                      $_[1][0] eq 'c' ? ()
                                      : (
                                         [DIRECTIVE_TAG, DIRECTIVE_COMPLETE, 'TABLE_ROW'],
                                         [DIRECTIVE_TAG, DIRECTIVE_START, 'TABLE_ROW'],
                                        ),
                      [DIRECTIVE_TAG, DIRECTIVE_START, 'TABLE_COL'],
                     ],
                     $_[1][1]
                    ];
                   }
	],
	[#Rule 121
		 '@22-1', 0,
sub
#line 2656 "ppParser.yp"
{
                    # switch to condition mode
                    stateManager(STATE_TABLE);

                    # trace, if necessary
                    warn "[Trace] $sourceFile, line $_[1][1]: Table paragraph starts.\n" if $flags{trace} & TRACE_PARAGRAPHS;
                   }
	],
	[#Rule 122
		 '@23-4', 0,
sub
#line 2664 "ppParser.yp"
{
                    # store specified column separator
                    unshift(@tableSeparatorStack, [quotemeta(join('', @{$_[3][0]})), "\n"]);
                   }
	],
	[#Rule 123
		 'table_paragraph', 7,
sub
#line 2669 "ppParser.yp"
{
                    # back to default mode
                    stateManager(STATE_DEFAULT);

                    # trace, if necessary
                    warn "[Trace] $sourceFile, line $_[7][1]: Table paragraph completed.\n" if $flags{trace} & TRACE_PARAGRAPHS;

                    # reset column separator memory, mark table completed
                    shift(@tableSeparatorStack);
                    $tableColumns=0;

                    # build parameter hash (contains level information only, which is always 1)
                    my %pars=(__nestingLevel__ => 1);

                    # If we are here and found anything in the table, a final row was
                    # closed and a new one opened at the end of the last table line.
                    # Because the table is completed now, the final opener tags can
                    # be removed. This is done *here* and by pop() for acceleration.
                    if (@{$_[6][0]}>4)
                      {
                       # delete final opener directives made by the final carriage return
                       splice(@{$_[6][0]}, -2, 2);

                       # normalize table rows and autoformat headline fields
                       normalizeTableRows($_[6][0], 1);

                       # reply data in a "tag envelope" (for backends)
                       [
                        [
                         # opener directives (note that first row and column are already opened by the initial carriage return stream)
                         [DIRECTIVE_TAG, DIRECTIVE_START, 'TABLE', \%pars],
                         [DIRECTIVE_TAG, DIRECTIVE_START, 'TABLE_ROW'],
                         [DIRECTIVE_TAG, DIRECTIVE_START, 'TABLE_HL'],
                         # the list of enclosed literals reduced by the final two, if any
                         @{$_[6][0]} ? @{$_[6][0]} : (),
                         # final directive
                         [DIRECTIVE_TAG, DIRECTIVE_COMPLETE, 'TABLE', \%pars]
                        ],
                        $_[7][1]
                       ];
                      }
                    else
                      {
                       # empty table - reply nothing real
                       [[()], $_[7][1]];
                      }
                   }
	],
	[#Rule 124
		 '@24-1', 0,
sub
#line 2720 "ppParser.yp"
{
             # switch to embedding mode saving the former state (including *all* special settings)
             push(@stateStack, $parserState);
             push(@specialStack, [%specials]);
             stateManager(STATE_EMBEDDING);

             # trace, if necessary
             warn "[Trace] $sourceFile, line $_[1][1]: Embedding starts.\n" if $flags{trace} & TRACE_PARAGRAPHS;

	     # Disable storage of a checksum. (Dynamic parts may change or have changed.
             # Static parts are static of course, but the filter settings may vary.)
	     $flags{checksummed}=0;

             # temporarily activate specials "{" and "}"
             push(@specialStack, @specials{('{', '}')});
             @specials{('{', '}')}=(1, 1);

             # deactivate boost
             $flags{noboost}=1;
            }
	],
	[#Rule 125
		 '@25-3', 0,
sub
#line 2741 "ppParser.yp"
{
             # reactivate boost
             $flags{noboost}=0;

             # restore special state of "{" and "}"
             @specials{('{', '}')}=splice(@specialStack, -2, 2);

             # check parameters: language should be set at least
             my %tagpars=@{$_[3][0]};
             warn "[Error ", ++$semErr, "] $sourceFile, line $_[3][1]: You forgot to specify the language of embedded text.\n" unless exists $tagpars{lang};
            }
	],
	[#Rule 126
		 'embedded', 6,
sub
#line 2753 "ppParser.yp"
{
             # restore former parser state (including *all* special settings)
             stateManager(pop(@stateStack));
             %specials=@{pop(@specialStack)};

             # build parameter hash, if necessary
             my %pars;
             if (@{$_[3][0]})
               {
                # the list already consists of key/value pairs
                %pars=@{$_[3][0]}
               }

             # check if we have to stream this code
             unless (not $flags{filter} or lc($pars{lang}) eq 'pp' or (exists $pars{lang} and $pars{lang}=~/^$flags{filter}$/i))
               {
                # caller wants to skip the embedded code: we have to supply something, but it should be nothing
                [[()], $_[6][1]];
               }
             elsif (lc($pars{lang}) eq 'pp')
               {
                # embedded PerlPoint - pass it back to the parser (by stack)
                stackInput($_[0], split(/(\n)/, join('',  @{$_[5][0]})));

                # reset the "end of input reached" flag if necessary
                $readCompletely=0 if $readCompletely;

                # we have to supply something, but it should be nothing
                [[()], $_[6][1]];
               }
             elsif (lc($pars{lang}) eq 'perl')
               {
                # This is embedded Perl code, anything passed really?
                # And does the caller want to evaluate the code?
                if (@{$_[5][0]} and $safeObject)
                  {
                   # update active contents base data, if necessary
                   if ($flags{activeBaseData})
                     {
                      no strict 'refs';
                      ${join('::', ref($safeObject) ? $safeObject->root : 'main', 'PerlPoint')}=dclone($flags{activeBaseData});
                     }

                   # make the code a string and evaluate it
                   my $perl=join('',  @{$_[5][0]});
                   warn "[Trace] $sourceFile, line $_[6][1]: Evaluating this code:\n\n$perl\n\n\n" if $flags{trace} & TRACE_ACTIVE;

                   # ignore empty code
                   if ($perl=~/\S/)
                     {
                      # well, there is something, evaluate it
                      my $result=ref($safeObject) ? $safeObject->reval($perl) : eval(join(' ', '{package main; no strict;', $perl, '}'));

                      # check result
                      if ($@)
                        {warn "[Error ", ++$semErr, "] $sourceFile, line $_[5][1]: embedded Perl code could not be evaluated: $@.\n";}
                      else
                        {
                         # success - make the result part of the input stream, if any
                         stackInput($_[0], split(/(\n)/, $result)) if defined $result;
                        }

                      # reset the "end of input reached" flag if necessary
                      $readCompletely=0 if $readCompletely;
                     }
                  }

                # we have to supply something, but it should be nothing
                [[()], $_[6][1]];
               }
             else
               {
                # reply data in a "tag envelope" (for backends)
                [
                 [
                  # opener directive
                  [DIRECTIVE_TAG, DIRECTIVE_START, 'EMBED', \%pars],
                  # the list of enclosed literals, if any
                  @{$_[5][0]} ? @{$_[5][0]} : (),
                  # final directive
                  [DIRECTIVE_TAG, DIRECTIVE_COMPLETE, 'EMBED', \%pars]
                 ],
                 $_[6][1]
                ];
               }
            }
	],
	[#Rule 127
		 '@26-1', 0,
sub
#line 2843 "ppParser.yp"
{
             # trace, if necessary
             warn "[Trace] $sourceFile, line $_[1][1]: Inclusion starts.\n" if $flags{trace} & TRACE_PARAGRAPHS;

	     # Disable storage of a checksum. (Files may change or have changed. Later on,
             # we could try to keep a files modification date unless it is a nested PerlPoint
             # source or a dynamic Perl part. For now, it seems to be sufficient that each file
             # is cached itself.)
	     $flags{checksummed}=0;

             # temporarily activate specials "{" and "}"
             push(@specialStack, @specials{('{', '}')});
             @specials{('{', '}')}=(1, 1);

             # deactivate boost
             $flags{noboost}=1;
            }
	],
	[#Rule 128
		 'included', 3,
sub
#line 2861 "ppParser.yp"
{
             # reactivate boost
             $flags{noboost}=0;

             # restore special state of "{" and "}"
             @specials{('{', '}')}=splice(@specialStack, -2, 2);

             # check parameters: type and filename should be set at least
             my $errors;
             my %tagpars=@{$_[3][0]};
             $errors++, warn "[Error ", ++$semErr, "] $sourceFile, line $_[3][1]: You forgot to specify the type of your included file.\n" unless exists $tagpars{type};
             $errors++, warn "[Error ", ++$semErr, "] $sourceFile, line $_[3][1]: You forgot to specify the name of your included file.\n" unless exists $tagpars{file};

             # smart inclusion?
             my $smart=1 if     $tagpars{type}=~/^pp$/
                            and exists $tagpars{smart} and $tagpars{smart}
                            and exists $openedSourcefiles{$tagpars{file}};

             # avoid circular source inclusion
             $errors++, warn "[Error ", ++$semErr, "] $sourceFile, line $_[3][1]: Source file $tagpars{file} was already opened before.\n" if     $tagpars{type}=~/^pp$/
                                                                                                                                              and not $smart
                                                                                                                                              and grep($_ eq $tagpars{file}, @nestedSourcefiles);


             # PerlPoint headline offsets have to be positive numbers or certain strings
             $errors++, warn "[Error ", ++$semErr, "] $sourceFile, line $_[3][1]: Invalid headline level offset $tagpars{headlinebase}, positive number or keywords BASE_LEVEL/CURRENT_LEVEL expected.\n" if $tagpars{type}=~/^pp$/i and exists $tagpars{headlinebase} and $tagpars{headlinebase}!~/^\d+$/ and $tagpars{headlinebase}!~/^(base|current)_level$/i;
             $tagpars{headlinebase}=$flags{headlineLevel} if exists $tagpars{headlinebase} and $tagpars{headlinebase}=~/^current_level$/i;
             $tagpars{headlinebase}=$flags{headlineLevel}-1 if exists $tagpars{headlinebase} and $tagpars{headlinebase}=~/^base_level$/i;

             # all right?
             unless (defined $smart or defined $errors)
               {
                # check the filename
                if (-r $tagpars{file})
                  {
                   # check specified file type
                   if ($tagpars{type}=~/^pp$/i)
                     {
                      # update nesting stack
                      push(@nestedSourcefiles, $tagpars{file});

		      # update source file nesting level hint
		      predeclareVariables({_SOURCE_LEVEL=>scalar(@nestedSourcefiles)});

                      # build a hash of variables to "localize"
                      my ($localizedVars, $localizeAll)=({}, 0);
                      if (exists $tagpars{localize})
                        {
                         # special setting?
                         if ($tagpars{localize}=~/^\s*__ALL__\s*$/)
                           {
                            # store a copy of all existing variables
                            $localizedVars=dclone(\%variables);
                            $localizeAll=1;
                           }
                         else
                           {
                            # store values of all variables to localize (passed by a comma separated list)
                            $localizedVars={map {$_=>$variables{$_}} split(/\s*,\s*/, $tagpars{localize})};
                           }

                         # the source level variable needs to be corrected
                         $localizedVars->{_SOURCE_LEVEL}-- if exists $localizedVars->{_SOURCE_LEVEL};
                        }

                      # we include a PerlPoint document, switch input handle
                      # (we intermediately have to close the original handle because of perl5.6.0 bugs)
                      unshift(
                              @inHandles, [
                                           tell($inHandle),
                                           $_[0]->{USER}->{INPUT},
                                           basename($sourceFile),
                                           $lineNrs{$inHandle},
                                           @flags{qw(headlineLevelOffset headlineLevel)},
                                           cwd(),
                                           $localizedVars, $localizeAll,
                                          ]
                             );
                      close($inHandle);
                      open($inHandle, $tagpars{file});
                      $_[0]->{USER}->{INPUT}='';
                      $sourceFile=$tagpars{file};
                      $lineNrs{$inHandle}=0;

                      # change directory with file
                      chdir(dirname($tagpars{file}));

                      # open a new input stack
                      unshift(@inputStack, []);

                      # headline level offset declared?
                      $flags{headlineLevelOffset}=exists $tagpars{headlinebase} ? $tagpars{headlinebase} : 0;

                      # store the filename in the list of opened sources, to avoid circular reopening
                      # (it would be more perfect to store the complete path, is there a module for this?)
                      $openedSourcefiles{$tagpars{file}}=1;

                      # we have to supply something, but it should be nothing
                      [[()], $_[3][1]];
                     }
                   elsif ($flags{filter} and $tagpars{type}!~/^(($flags{filter})|example)$/i)
                     {
                      # this file does not need to be included, nevertheless
                      # we have to supply something - but it should be nothing
                      [[()], $_[3][1]];
                     }
                   elsif ($tagpars{type}=~/^perl$/i)
                     {
                      # Does the caller want to evaluate code?
                      if ($safeObject)
                        {
                         # update active contents base data, if necessary
                         if ($flags{activeBaseData})
                           {
                            no strict 'refs';
                            ${join('::', ref($safeObject) ? $safeObject->root : 'main', 'PerlPoint')}=dclone($flags{activeBaseData});
                           }

                         # evaluate the source code (for an unknown reason, we have to precede the constant by "&" here to work)
                         warn "[Info] Evaluating included Perl code.\n" unless $flags{display} & &DISPLAY_NOINFO;
                         my $result=ref($safeObject) ? $safeObject->rdo($tagpars{file})
                                                     : eval
                                                        {
                                                         # enter user code namespace
                                                         package main;
                                                         # disable "strict" checks
                                                         no strict;
                                                         # excute user code
                                                         my $result=do $tagpars{file};
                                                         # check result ($! does not need to be checked, we checked file readability ourselves before)
                                                         die $@ if $@;
                                                         # reply provided result
                                                         $result;
                                                        };

                         # check result
                         if ($@)
                           {warn "[Error ", ++$semErr, "] $sourceFile, line $_[3][1]: included Perl code could not be evaluated: $@.\n";}
                         else
                           {
                            # success - make the result part of the input stream (by stack)
                            stackInput($_[0], split(/(\n)/, $result));

                            # reset the "end of input reached" flag if necessary
                            $readCompletely=0 if $readCompletely;
                           }
                        }

                      # we have to supply something, but it should be nothing
                      [[()], $_[3][1]];
                     }
                   else
                     {
                      # we include anything else: provide the contents as it is,
                      # declared as an "embedded" part
#                      open(my $included, $tagpars{file});
                      my $included=new IO::File;
                      open($included, $tagpars{file});
                      my @included=<$included>;
                      close($included);

                      # in case the file was declared an example, embed its contents as a verbatim block,
                      # otherwise, include it as really embedded part (to be processed by a backend)
                      if ($tagpars{type}=~/^example$/i)
                        {
                         # indent lines, if requested
                         if (exists $tagpars{indent})
                           {
                            # check parameter
                            unless ($tagpars{indent}=~/^\d+$/)
                              {$errors++, warn "[Error ", ++$semErr, "] $sourceFile, line $_[3][1]: Invalid indentation value of \"$tagpars{indent}\", please set up a number.\n";}
                            else
                              {
                               # all right, indent
                               my $indentation=' ' x $tagpars{indent}; 
                               @included=map {"$indentation$_"} @included;
                              }
                           }

                         [
                          [
                           # opener directive
                           [DIRECTIVE_VERBATIM, DIRECTIVE_START],
                           # the list of enclosed literals
                           @included,
                           # final directive
                           [DIRECTIVE_VERBATIM, DIRECTIVE_COMPLETE]
                          ],
                          $_[3][1]
                         ];
                        }
                      else
                        {
                         [
                          [
                           # opener directive
                           [DIRECTIVE_TAG, DIRECTIVE_START, 'EMBED', {lang=>$tagpars{type}}],
                           # the list of enclosed "literals", if any
                           @included,
                           # final directive
                           [DIRECTIVE_TAG, DIRECTIVE_COMPLETE, 'EMBED', {lang=>$tagpars{type}}]
                          ],
                          $_[3][1]
                         ];
                        }
                     }
                  }
                else
                  {
                   # simply inform user
                   $errors++, warn "[Error ", ++$semErr, "] $sourceFile, line $_[3][1]: File $tagpars{file} does not exist or cannot be read (current directory: ", cwd(), ").\n";

                   # we have to supply something, but it should be nothing
                   [[()], $_[3][1]];
                  }
               }
             else
               {        
                # we have to supply something, but it should be nothing
                [[()], $_[3][1]];
               }
            }
	],
	[#Rule 129
		 '@27-1', 0,
sub
#line 3088 "ppParser.yp"
{
                     # switch to definition mode
                     stateManager(STATE_DEFINITION);

                     # trace, if necessary
                     warn "[Trace] $sourceFile, line $_[1][1]: Macro definition starts.\n" if $flags{trace} & TRACE_PARAGRAPHS;
                    }
	],
	[#Rule 130
		 '@28-4', 0,
sub
#line 3096 "ppParser.yp"
{
                     # disable all specials to get the body as a plain text
                     @specials{keys %specials}=(0) x scalar(keys %specials);
                    }
	],
	[#Rule 131
		 'alias_definition', 6,
sub
#line 3101 "ppParser.yp"
{
                     # "text" already switched back to default mode (and disabled specials [{}:])

                     # trace, if necessary
                     warn "[Trace] $sourceFile, line $_[4][1]: Macro definition completed.\n" if $flags{trace} & TRACE_PARAGRAPHS;

                     # check spelling (only accept capitals and underscores in alias names, just like in tags)
                     if ($_[3][0]=~/[a-z]/)
                       {
                        warn "[Warn] $sourceFile, line $_[3][1]: Macro \"\\$_[3][0]\" is stored as ", uc("\\$_[3][0]"), ".\n" unless $flags{display} & DISPLAY_NOWARN;
                        $_[3][0]=uc($_[3][0]);
                       }

                     # build macro text
                     shift(@{$_[6][0]}); pop(@{$_[6][0]});
                     my $macro=join('', @{$_[6][0]});

                     # anything specified?
                     if ($macro=~/^\s*$/)
                       {
                        # nothing defined, should this line cancel a previous definition?
                        if (exists $macros{$_[3][0]})
                          {
                           # cancel macro
                           delete $macros{$_[3][0]};

                           # trace, if necessary
                           warn "[Trace] $sourceFile, line $_[4][1]: Macro \"$_[3][0]\" is cancelled.\n" if $flags{trace} & TRACE_SEMANTIC;

                           # update macro checksum
                           $macroChecksum=sha1_base64(nfreeze(\%macros));
                          }
                        else
                          {
                           # trace, if necessary
                           warn "[Trace] $sourceFile, line $_[4][1]: Empty macro \"$_[3][0]\" is ignored.\n" if $flags{trace} & TRACE_SEMANTIC;
                          }
                       }
                     else
                       {
                        # ok, this is a new definition - get all used parameters
                        my %pars; 
                        @pars{($macro=~/__([^_\\]+)__/g)}=();

                        # tag body wildcard is no parameter
                        my $bodyFlag=exists $pars{body} ? 1 : 0;
                        delete $pars{body};

                        # make guarded underscores just underscores
                        $macro=~s/\\_//g;

                        # store name, parameters, macro text and body flag
                        $macros{$_[3][0]}=[[keys %pars], $macro, $bodyFlag];

                        # update macro checksum
                        $macroChecksum=sha1_base64(nfreeze(\%macros));
                       }

                     # we have to supply something, but it should be nothing
                     # (this is a paragraph, so reply a plain string)
                     ['', $_[8][1]];
                    }
	]
],
                                  @_);
    bless($self,$class);
}

#line 3167 "ppParser.yp"



# ------------------------------------------
# Internal function: input stack management.
# ------------------------------------------
sub stackInput
 {
  # get parameters
  my ($parser, @lines)=@_;

  # declare variable
  my (@waiting);

  # the current input line becomes the last line to read in this set
  # (this way, we arrange it that additional text is exactly placed where its generator tag or macro stood,
  # without Ils confusion)
  push(@lines, (defined $parser->{USER}->{INPUT} and $parser->{USER}->{INPUT}) ? $parser->{USER}->{INPUT} : ());

  # combine line parts to lines completed by a trailing newline
  # (additionally, take into account that there might be mixed references which have to be stored unchanged)
  {
   my $lineBuffer='';
   foreach my $line (@lines)
     {
      if (ref($line))
        {
         # push collected string and current reference
         push(@waiting, $lineBuffer, $line);

         # reset line buffer
         $lineBuffer='';

         # next turn
         next;
        }

      # compose a string ...
      $lineBuffer.=$line;

      # ... until a newline was found
      push(@waiting, $lineBuffer), $lineBuffer='' if $line eq "\n";
     }
   push(@waiting, $lineBuffer) if $lineBuffer;
  }

  # get next line to read
  my $newInputLine=shift(@waiting);

  # update (innermost) input stack
  unshift(@{$inputStack[0]}, @waiting);

  # make the new top line the current input
  $parser->{USER}->{INPUT}=$newInputLine;
 }


# -----------------------------
# Internal function: the lexer.
# -----------------------------
sub lexer
 {
  # get parameters
  my ($parser)=@_;

  # scan for unlexed EOL´s which should be ignored
  while (
	     $parser->{USER}->{INPUT}
	 and $parser->{USER}->{INPUT}=~/^\n/
	 and (
	         $lexerFlags{eol}==LEXER_IGNORE
	      or (
		      @tableSeparatorStack
		  and $tableSeparatorStack[0][1] eq "\n"
		  and $tableColumns<0
		 )
	     )
	)
    {
     # trace, if necessary
     warn "[Trace] Lexer: Ignored EOL in line $lineNrs{$inHandle}.\n" if $flags{trace} & TRACE_LEXER;
     
     # remove the ignored newline
     $parser->{USER}->{INPUT}=~s/^\n//;

     # update column counter, if necessary
     $tableColumns++ if @tableSeparatorStack and $tableSeparatorStack[0][1] eq "\n" and $tableColumns<0;
    }

  # get next symbol
  unless ($parser->{USER}->{INPUT})
    {
      {
       # will the next line be get from the input stack instead of from a real file?
       my $lineFromStack=scalar(@{$inputStack[0]});

       # get next input line
       unless (
                  (@{$inputStack[0]} and ($parser->{USER}->{INPUT}=shift(@{$inputStack[0]}) or 1))
               or (defined($inHandle) and $parser->{USER}->{INPUT}=<$inHandle>)
              )
         {
          # was this a nested source?
          unless (@inHandles)
            {
             # this was the base document: should we insert a final additional token?
             $readCompletely=1,
             (($flags{trace} & TRACE_LEXER) and warn("[Trace] Lexer: Final Empty_line in line $lineNrs{$inHandle}.\n")),
             return('Empty_line', ['', $lineNrs{$inHandle}]) unless $readCompletely;

             # well done
             return('', [undef, -1]);
            }
          else
            {
             # we finished a nested source: close it and restore
             # things to continue reading the enclosing file
             my ($helper1, $helper2, $helper3, $localizedVars, $localizedAll);
             (
              $helper1,
              $parser->{USER}->{INPUT},
              $sourceFile,
              $helper2,
              @flags{qw(headlineLevelOffset headlineLevel)},
              $helper3,
              $localizedVars, $localizedAll,
             )=@{shift(@inHandles)};
             $lineNrs{$inHandle}=$helper2-1; # -1 to compensate the subsequent increment

             # back to envelopes directory
             chdir($helper3);

             # reopen envelope file
             close($inHandle);
             $inHandle=new IO::File;
             open($inHandle, $sourceFile);
             seek($inHandle, $helper1, 0);

             # switch back to envelopes input stack
             shift(@inputStack);

             # update nesting stack
             pop(@nestedSourcefiles);

	     # update source file nesting level hint
	     predeclareVariables({_SOURCE_LEVEL=>scalar(@nestedSourcefiles)});

             # restore variables as necessary
             if ($localizedAll)
               {
                # Do we have to take care of the stream?
                if ($flags{var2stream})
                  {
                   # stream variable reset
                   push(@$resultStreamRef, [DIRECTIVE_VARRESET, DIRECTIVE_START]);

                   # restore former variables completely, overwriting current settings
                   # (and propagating them into the stream again)
                   undef %variables;
                   predeclareVariables({$_=>$localizedVars->{$_}}, 1) foreach sort keys %$localizedVars;
                  }
                else
                  {
                   # ok, the stream does not take notice of this operation, so it can be performed quicker
                   %variables=%$localizedVars;
                  }
               }
             elsif (!$localizedAll and %$localizedVars)
               {
                # handle each localized variable
                foreach my $var (keys %$localizedVars)
                  {
                   # restore old value in parser and stream context, if necessary
                   predeclareVariables({$var=>$localizedVars->{$var}}, 1)
                     if $localizedVars->{$var} ne $variables{$var};
                  }
               }
            }
         }

       # if this line was got from stack and is a reference, we got an already prepared stream part
       # or a delayed token
       if ($lineFromStack and ref($parser->{USER}->{INPUT}))
         {
          if (ref($parser->{USER}->{INPUT}) eq 'PerlPoint::Parser::DelayedToken')
            {
             my $delayedToken=$parser->{USER}->{INPUT};
             $parser->{USER}->{INPUT}='';
             return($delayedToken->token, $delayedToken->value);
            }
          else
            {
             my $streamedPart=$parser->{USER}->{INPUT};
             $parser->{USER}->{INPUT}='';
             return('StreamedPart', [$streamedPart, $lineNrs{$inHandle}]);
            }
         }

       # update line counter, if necessary
       $lineNrs{$inHandle}++ unless $lineFromStack;

       # ignore this line if wished
       $parser->{USER}->{INPUT}='', redo if $flags{skipInput} and $parser->{USER}->{INPUT}!~/^\?/;

       # if we are here, skip mode is leaved
       $flags{skipInput}=0;
     
       unless ($lineFromStack)
         {
          # add a line update hint
          push(@$resultStreamRef, [DIRECTIVE_NEW_LINE, DIRECTIVE_START, {file=>$sourceFile, line=>$lineNrs{$inHandle}}]) if $flags{linehints};

          # remove TRAILING whitespaces, but keep newlines (if any)
          {
           my $newline=($parser->{USER}->{INPUT}=~/\n$/m);
           $parser->{USER}->{INPUT}=~s/\s*$//;
           $parser->{USER}->{INPUT}=join('', $parser->{USER}->{INPUT}, "\n") if $newline;
          }
	 }

       # scan for empty lines as necessary
       if ($parser->{USER}->{INPUT}=~/^$/)
         {
          # update the checksum flags
          $flags{checksum}=1 if $flags{cache} & CACHE_ON;

          # trace, if necessary
          warn "[Trace] Lexer: Empty_line in line $lineNrs{$inHandle}", $lexerFlags{el}==LEXER_IGNORE ? ' is ignored' : '', ".\n" if $flags{trace} & TRACE_LEXER;

          # update input line
          $parser->{USER}->{INPUT}='';

          # sometimes empty lines have no special meaning
          $lexerFlags{el}==LEXER_IGNORE and redo;

          # but sometimes they are very special
          return('Empty_line', ["\n", $lineNrs{$inHandle}]);
         }
       else
         {
          # disable caching for embedded code containing empty lines
          $flags{checksummed}=0 if $specials{embedded};

          # this may be the first line of a new paragraph to be checksummed
          if (
                  ($flags{cache} & CACHE_ON)
              and $flags{checksum}
              and not $lineFromStack
              and (not $specials{heredoc} or $specials{heredoc} eq '1')
              and not @tableSeparatorStack
              and not $specials{embedded}
             )
            {
             # handle $/ locally
             local($/);

             # update statistics
             $statistics{cache}[0]++;

             # well, switch to paragraph mode (depending on the paragraph type)!
             if ($parser->{USER}->{INPUT}=~/^<<(\w+)/)
               {$/="\n$1";}
             elsif ($parser->{USER}->{INPUT}=~/^(?<!\\)\\TABLE/i)
               {$/="\n\\END_TABLE";}
             else
               {$/='';}

             # store current position
             my $lexerPosition=tell($inHandle);

             # read *current* paragraph completely (take care - we may have read it completely yet!)
             seek($inHandle, $lexerPosition-length($parser->{USER}->{INPUT}), 0) unless $parser->{USER}->{INPUT}=~/^<<(\w+)/ or $parser->{USER}->{INPUT}=~/^(?<!\\)\\TABLE/i;
             my $paragraph=<$inHandle>;
             $paragraph=join('', $parser->{USER}->{INPUT}, $paragraph) if $parser->{USER}->{INPUT}=~/^<<(\w+)/ or $parser->{USER}->{INPUT}=~/^(?<!\\)\\TABLE/i;

             # count the lines in the paragraph read
             my $plines=0;
             $plines++ while $paragraph=~/(\n)/g;
             $plines-- unless $parser->{USER}->{INPUT}=~/^<<(\w+)/ or $parser->{USER}->{INPUT}=~/^(?<!\\)\\TABLE/i;

             # remove trailing whitespaces (to avoid checksumming them)
             $paragraph=~s/\n+$//;

             # anything interesting found?
             if (defined $paragraph)
               {
                # build checksum (of paragraph *and* headline level offset)
                my $checksum=sha1_base64(join('+', exists $flags{headlineLevelOffset} ? $flags{headlineLevelOffset} : 0, $paragraph));
		
                # warn "---> Searching checksum for this paragraph:\n-----\n$paragraph\n- by $checksum --\n";
                # check paragraph to be known
                if (
                        exists $checksums->{$sourceFile}
                    and exists $checksums->{$sourceFile}{$checksum}
                    and (
                            not defined $checksums->{$sourceFile}{$checksum}[3]
                         or $checksums->{$sourceFile}{$checksum}[3] eq $macroChecksum
                        )
                    and (
                            not defined $checksums->{$sourceFile}{$checksum}[4]
                         or $checksums->{$sourceFile}{$checksum}[4] eq $varChecksum
                        )
                   )
                  {
                   # Do *not* reset the checksum flag for new checksums - we already read the
                   # empty lines, and a new paragraph may follow! *But* deactivate the current
                   # checksum to avoid multiple storage - we already stored it, right?
                   $flags{checksummed}=0;

                   # reset input buffer - it is all handled (take care to remove a final newline
                   # if the paragraph was closed by a string - this would normally be read in a
                   # per line processing, but it remained in the file in paragraph mode)
                   $/="\n";
                   scalar(<$inHandle>) if $parser->{USER}->{INPUT}=~/^<<(\w+)/ or $parser->{USER}->{INPUT}=~/^(?<!\\)\\TABLE/i;
                   $parser->{USER}->{INPUT}='';

                   # warn "===========> PARAGRAPH CACHE HIT!! ($lineNrs{$inHandle}/$sourceFile/$checksum) <=================\n$paragraph-----\n";
                   # use Data::Dumper; warn Dumper($checksums->{$sourceFile}{$checksum});

                   # update statistics
                   $statistics{cache}[1]++;
		   
                   # update line counter
                   # warn "----> Old line: $lineNrs{$inHandle}\n";
                   $lineNrs{$inHandle}+=$plines;
                   # warn "----> New line: $lineNrs{$inHandle}\n";

                   # The next steps depend - follow the provided hint. We may have to reinvoke
                   # the parser to restore a state.                   
# perl 5.6 #       unless (exists $checksums->{$sourceFile}{$checksum}[2])
                   unless (defined $checksums->{$sourceFile}{$checksum}[2])
                     {
                      # direct case - add the already known part directly to the stream
                      push(@$resultStreamRef, @{$checksums->{$sourceFile}{$checksum}[0]});

                      # Well done this paragraph - go on!
                      redo;
                     }
                   else
                     {
                      # more complex case - reinvoke the parser to update its states
                      return($checksums->{$sourceFile}{$checksum}[2], [dclone($checksums->{$sourceFile}{$checksum}[0]), $lineNrs{$inHandle}]);
                     }
                  }

                # flag that we are going to build an associated stream
                $flags{checksummed}=[$checksum, scalar(@$resultStreamRef), $plines];
                # warn "---> Started checksumming for\n-----\n$paragraph\n---(", $plines+1, " line(s))\n";
               }

             # reset file pointer
             seek($inHandle, $lexerPosition, 0);
            }

          # update the checksum flag: we are *within* a paragraph, do not checksum
          # until we reach the next empty line
          $flags{checksum}=0;
         }

       unless ($lineFromStack)
         {
          # scan for heredoc close hints
          if ($specials{heredoc} and $specials{heredoc} ne '1' and $parser->{USER}->{INPUT}=~/^($specials{heredoc})$/)
            {
             # trace, if necessary
             warn "[Trace] Lexer: Heredoc close hint $1 in line $lineNrs{$inHandle}.\n" if $flags{trace} & TRACE_LEXER;

             # update input line
             $parser->{USER}->{INPUT}='';

             # reset heredoc setting
             $specials{heredoc}=1;

             # reply token
             return('Heredoc_close', [$1, $lineNrs{$inHandle}]);
            }

          # scan for indented lines, if necessary
          if ($parser->{USER}->{INPUT}=~/^(\s+)/)
            {
             if ($lexerFlags{ils}==LEXER_TOKEN)
               {
                # trace, if necessary
                warn "[Trace] Lexer: Ils in line $lineNrs{$inHandle}.\n" if $flags{trace} & TRACE_LEXER;

                # update input buffer and reply the token (contents is necessary as well)
                my $ils=$1;
                $parser->{USER}->{INPUT}=~s/^$1//; 
                return('Ils', [$ils, $lineNrs{$inHandle}]);
               }
             elsif ($lexerFlags{ils}==LEXER_IGNORE)
               {
                warn "[Trace] Lexer: Ils in line $lineNrs{$inHandle} is ignored.\n" if $flags{trace} & TRACE_LEXER;
                $parser->{USER}->{INPUT}=~s/^(\s+)//;
               }
            }

          # scan for a new paragraph opened by a tag, if necessary
          if ($parserState==STATE_DEFAULT and $parser->{USER}->{INPUT}=~/^\\/)
            {
             # remain in default state, but switch to its tag mode
             stateManager(STATE_DEFAULT_TAGMODE);
            }
         }
      }
     }

  # can we take the rest of the line at *once*?
  if (($parserState==STATE_COMMENT or $parserState==STATE_VERBATIM) and $parser->{USER}->{INPUT} ne "\n")
    {
     # grab line and chomp if necessary
     my $line=$parser->{USER}->{INPUT};
     chomp($line) unless $parserState==STATE_VERBATIM;
          
     # update input line (restore trailing newline if it will be used to detect paragraph completion)
     $parser->{USER}->{INPUT}=$parserState==STATE_VERBATIM ? '' : "\n";

     # supply result
     return('Word', [$line, $lineNrs{$inHandle}]);
    }

  # reply a token
  for ($parser->{USER}->{INPUT})
    {
     # declare scopies
     my ($found, $sfound);

     # trace, if necessary
     warn "[Trace] Lexing \"$_\".\n" if $flags{trace} & TRACE_LEXER;

     # check for table separators, if necessary (these are the most common strings)
     if (@tableSeparatorStack)
       {
        # check for a column separator
        s/^$tableSeparatorStack[0][0]//,
        (($flags{trace} & TRACE_LEXER) and warn("[Trace] Lexer: table column separator in line $lineNrs{$inHandle}.\n")),
        return('Table_separator', ['c', $lineNrs{$inHandle}]) if /^($tableSeparatorStack[0][0])/;

        # check for row separator
        s/^$tableSeparatorStack[0][1]//,
        (($flags{trace} & TRACE_LEXER) and warn("[Trace] Lexer: table row separator in line $lineNrs{$inHandle}.\n")),
        return('Table_separator', ['r', $lineNrs{$inHandle}]) if /^($tableSeparatorStack[0][1])/;
       }

     # reply next token: EOL?
     if (/^(\n)/)
       {
        if ($lexerFlags{eol}==LEXER_TOKEN)
          {
           $found=$1;
           warn("[Trace] Lexer: EOL in line $lineNrs{$inHandle}.\n") if $flags{trace} & TRACE_LEXER;
           s/^$1//;
           return('EOL', [$found, $lineNrs{$inHandle}]);
          }
        elsif ($lexerFlags{eol}==LEXER_EMPTYLINE)
          {
           # flag "empty line" as wished
           warn("[Trace] Lexer: EOL -> Empty_line in line $lineNrs{$inHandle}.\n") if $flags{trace} & TRACE_LEXER;
           s/^$1//;
           return('Empty_line', ['', $lineNrs{$inHandle}]);
          }
        elsif ($lexerFlags{eol}==LEXER_SPACE)
          {
           # flag "space" as wished and reply a simple whitespace
           warn("[Trace] Lexer: EOL -> Space in line $lineNrs{$inHandle}.\n") if $flags{trace} & TRACE_LEXER;
           s/^$1//;
           return('Space', [' ', $lineNrs{$inHandle}]);
          }
        else
          {die "[BUG] Unhandled EOL directive $lexerFlags{eol}.";}
       }

     # reply next token: scan for spaces
     $found=$1, s/^$1//,
     (($flags{trace} & TRACE_LEXER) and warn("[Trace] Lexer: Space in line $lineNrs{$inHandle}.\n")),
     return('Space', [$found, $lineNrs{$inHandle}]) if /^(\s+)/;

     # reply next token: scan for here doc openers
     $found=$1, s/^<<$1//,
     (($flags{trace} & TRACE_LEXER) and warn("[Trace] Lexer: Heredoc opener $found in line $lineNrs{$inHandle}.\n")),
     return('Heredoc_open', [$found, $lineNrs{$inHandle}]) if /^<<(\w+)/ and $specials{heredoc} eq '1';

     # reply next token: scan for SPECIAL tagnames: \TABLE
     $found=$1, s/^\\$1//,
     (($flags{trace} & TRACE_LEXER) and warn("[Trace] Lexer: Table starts in line $lineNrs{$inHandle}.\n")),
     return('Table', [$found, $lineNrs{$inHandle}]) if $specials{tag} and /^(?<!\\)\\(TABLE)/;
     
     # reply next token: scan for SPECIAL tagnames: \END_TABLE
     $found=$1, s/^\\$1//,
     (($flags{trace} & TRACE_LEXER) and warn("[Trace] Lexer: Table completed in line $lineNrs{$inHandle}.\n")),
     return('Tabled', [$found, $lineNrs{$inHandle}])  if $specials{tag} and /^(?<!\\)\\(END_TABLE)/;
     
     # reply next token: scan for SPECIAL tagnames: \EMBED
     $found=$1, s/^\\$1//,
     (($flags{trace} & TRACE_LEXER) and warn("[Trace] Lexer: Embedding starts in line $lineNrs{$inHandle}.\n")),
     return('Embed', [$found, $lineNrs{$inHandle}]) if $specials{tag} and /^(?<!\\)\\(EMBED)/;
     
     # reply next token: scan for SPECIAL tagnames: \END_EMBED
     $found=$1, s/^\\$1//,
     (($flags{trace} & TRACE_LEXER) and warn("[Trace] Lexer: Embedding completed in line $lineNrs{$inHandle}.\n")),
     return('Embedded', [$found, $lineNrs{$inHandle}]) if $specials{embedded} and /^(?<!\\)\\(END_EMBED)/;
     
     # reply next token: scan for SPECIAL tagnames: \INCLUDE
     $found=$1, s/^\\$1//,
     (($flags{trace} & TRACE_LEXER) and warn("[Trace] Lexer: Including starts in line $lineNrs{$inHandle}.\n")),
     return('Include', [$found, $lineNrs{$inHandle}]) if $specials{tag} and /^(?<!\\)\\(INCLUDE)/;
     
     # reply next token: scan for tagnames
     $found=$1, s/^\\$1//,
     (($flags{trace} & TRACE_LEXER) and warn("[Trace] Lexer: Tag opener $found in line $lineNrs{$inHandle}.\n")),
     return('Tag_name', [$found, $lineNrs{$inHandle}]) if $specials{tag} and /^(?<!\\)\\([A-Z_0-9]+)/ and (exists $tagsRef->{$1} or exists $macros{$1});
     
     # reply next token: scan for special characters
     $found=$1, s/^\Q$1//,
     (($flags{trace} & TRACE_LEXER) and warn("[Trace] Lexer: Special $found in line $lineNrs{$inHandle}.\n")),
     return($found, [$found, $lineNrs{$inHandle}]) if /^(?<!\\)(\S)/ and exists $specials{$1} and $specials{$1};

     # reply next token: scan for definition list items
     $found=$1, s/^$1//,
     (($flags{trace} & TRACE_LEXER) and warn("[Trace] Lexer: Colon in line $lineNrs{$inHandle}.\n")),
     return('Colon', [$found, $lineNrs{$inHandle}]) if $specials{colon} and /^(?<!\\)(:)/;

     # reply next token: search for named variables
     $found=$1, s/^\$$1//,
     (($flags{trace} & TRACE_LEXER) and warn("[Trace] Lexer: Named variable \"$found\" in line $lineNrs{$inHandle}.\n")),
     return('Named_variable', [$found, $lineNrs{$inHandle}]) if /^(?<!\\)\$($patternWUmlauts)/;

     # reply next token: search for symbolic variables
     $found=$1, s/^\${$1}//,
     (($flags{trace} & TRACE_LEXER) and warn("[Trace] Lexer: Symbolic variable \"$found\" in line $lineNrs{$inHandle}.\n")),
     return('Symbolic_variable', [$found, $lineNrs{$inHandle}]) if /^(?<!\\)\${($patternWUmlauts)}/;

     # flag that this paragraph *might* use macros someday, if there is still something being no tag and no
     # macro, but looking like a tag or a macro (somebody could *later* declare it a real macro, so the cache
     # needs to check macro definitions)
     $flags{checksummed}[3]=1
       if     $specials{tag} and /^(?<!\\)\\([A-Z_0-9]+)/
          and not (exists $flags{checksummed} and not $flags{checksummed});

     # remove guarding \\, if necessary
     s/^\\// unless    $specials{heredoc}
                    or $parserState==STATE_EMBEDDING
                    or $parserState==STATE_CONDITION
                    or $parserState==STATE_DEFINITION;

     # reply next token: scan for numbers, if necessary
     $found=$1, s/^$1//,
     (($flags{trace} & TRACE_LEXER) and warn("[Trace] Lexer: Number $found in line $lineNrs{$inHandle}.\n")),
     return('Number', [$found, $lineNrs{$inHandle}]) if $specials{number} and /^(\d+)/;

     unless ($flags{noboost})
       {
        # build set of characters to be special
        my %translator;
        @translator{'colon', 'number'}=(':', '0-9');
        my $special=join('', '([', '\n\\\\', (map {exists $translator{$_} ? $translator{$_} : $_} grep(($specials{$_} and (length==1 or exists $translator{$_})), keys %specials)), '])');
        $special=join('', $special, '|(', $tableSeparatorStack[0][0], ')|(', $tableSeparatorStack[0][1], ')') if @tableSeparatorStack;

        # reply next token: scan for word or single character (declared as "Word" as well)
        # warn("~~~~~~~~~> $special\n");
        $found=$1, s/^\Q$1//,
        # warn("=====> $found\n"),
        (($flags{trace} & TRACE_LEXER) and warn("[Trace] Lexer: Word \"$found\" in line $lineNrs{$inHandle}.\n")),
        return('Word', [$found, $lineNrs{$inHandle}]) if /^(.+?)($special|($))/;
       }

     # reply next token: scan for word or single character (declared as "Word" as well)
     $found=$1, s/^\Q$1//,
     (($flags{trace} & TRACE_LEXER) and warn("[Trace] Lexer: Word \"$found\" in line $lineNrs{$inHandle}.\n")),
     return('Word', [$found, $lineNrs{$inHandle}]) if /^($patternWUmlauts)/ or /^(\S)/;

     # everything should be handled - this code should never be executed!
     die "[BUG] $sourceFile, line $lineNrs{$inHandle}: No symbol found in \"$_\"!\n";
    }
 }

# ----------------------------------------------------------------------------------------------
# Internal function: error message display.
# ----------------------------------------------------------------------------------------------
sub _Error
 {
  # declare base indention
  my $baseIndention=' ' x length('[Error] ');

  # use $_[0]->YYCurtok to display the recognized *token* if necessary - for users convenience, it is suppressed in the message
  warn "\n\n[Error] $sourceFile, line ${$_[0]->YYCurval}[1]", (exists $statistics{cache} and $statistics{cache}[1]) ? ' (or below because of cache hits)' : (), qq(: found "), ${$_[0]->YYCurval}[0], qq(", expected:\n$baseIndention), ' ' x length('or '), join("\n${baseIndention}or ", map {exists $tokenDescriptions{$_} ? defined $tokenDescriptions{$_} ? $tokenDescriptions{$_} : () : $_} sort grep($_!~/cache_hit$/, $_[0]->YYExpect)), ".\n\n";
 }

# ----------------------------------------------------------------------------------------------
# Internal function: state manager.
# ----------------------------------------------------------------------------------------------
sub stateManager
 {
  # get parameter
  my ($newState)=@_;

  # check parameter
  confess "[BUG] Invalid new state $newState passed.\n" unless    $newState==STATE_DEFAULT
                                                               or $newState==STATE_DEFAULT_TAGMODE
                                                               or $newState==STATE_TEXT
                                                               or $newState==STATE_UPOINT
                                                               or $newState==STATE_OPOINT
                                                               or $newState==STATE_DPOINT
                                                               or $newState==STATE_DPOINT_ITEM
                                                               or $newState==STATE_BLOCK
                                                               or $newState==STATE_VERBATIM
                                                               or $newState==STATE_EMBEDDING
                                                               or $newState==STATE_CONDITION
                                                               or $newState==STATE_HEADLINE_LEVEL
                                                               or $newState==STATE_HEADLINE
                                                               or $newState==STATE_TABLE
                                                               or $newState==STATE_DEFINITION
                                                               or $newState==STATE_CONTROL
                                                               or $newState==STATE_COMMENT;

  # store the new state
  $parserState=$newState;

  # enter new state: default
  $newState==STATE_DEFAULT and do
    {
     # prepare lexer
     @lexerFlags{qw(ils eol el)}=(LEXER_TOKEN, LEXER_EMPTYLINE, LEXER_IGNORE);

     # activate special characters as necessary
     @specials{('/', '*', '#', '=', '<', '>', '{', '}' , '-', '?', '@', '+', 'heredoc', 'colon', 'tag', 'embedded', 'number')}=(1, 1, 1, 1, 1, 1, 0, 0, 1, 1, 1, 1, 1, 1, 1, 0, 0);

     # trace, if necessary
     warn "[Trace] Entered default state.\n" if $flags{trace} & TRACE_SEMANTIC;

     # well done
     return;
    };

  # enter new state: default in tag mode (same as default, but a paragraph starting with a tag delays switching to other
  # modes, so we have to explicitly disable the paragraph opener specials)
  $newState==STATE_DEFAULT_TAGMODE and do
    {
     # prepare lexer
     @lexerFlags{qw(ils eol el)}=(LEXER_TOKEN, LEXER_EMPTYLINE, LEXER_IGNORE);

     # activate special characters as necessary
     @specials{('/', '*', '#', '=', '<', '>', '{', '}' , '-', '?', '@', '+', 'heredoc', 'colon', 'tag', 'embedded', 'number')}=(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0);

     # trace, if necessary
     warn "[Trace] Entered default state in tag mode.\n" if $flags{trace} & TRACE_SEMANTIC;

     # well done
     return;
    };

  # enter new state: headline body
  ($newState==STATE_HEADLINE or $newState==STATE_HEADLINE_LEVEL) and do
    {
     # prepare lexer
     @lexerFlags{qw(ils eol el)}=(LEXER_IGNORE, LEXER_SPACE, LEXER_TOKEN);

     # activate special characters as necessary
     @specials{('/', '*', '#', '=', '<', '>', '{', '}' , '-', '?', '@', '+', 'heredoc', 'colon', 'tag', 'embedded', 'number')}=(0, 0, 0, $newState==STATE_HEADLINE ? 0 : 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0);

     # trace, if necessary
     warn "[Trace] Entered headline ", $newState==STATE_HEADLINE ? 'body' : 'level', " state.\n" if $flags{trace} & TRACE_SEMANTIC;

     # well done
     return;
    };

  # enter new state: comment
  $newState==STATE_COMMENT and do
    {
     # prepare lexer
     @lexerFlags{qw(ils eol el)}=(LEXER_IGNORE, LEXER_EMPTYLINE, LEXER_IGNORE);

     # activate special characters as necessary
     @specials{('/', '*', '#', '=', '<', '>', '{', '}' , '-', '?', '@', '+', 'heredoc', 'colon', 'tag', 'embedded', 'number')}=(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);

     # trace, if necessary
     warn "[Trace] Entered comment state.\n" if $flags{trace} & TRACE_SEMANTIC;

     # well done
     return;
    };

  # enter new state: text
  $newState==STATE_TEXT and do
    {
     # prepare lexer
     @lexerFlags{qw(ils eol el)}=(LEXER_IGNORE, LEXER_SPACE, LEXER_TOKEN);

     # activate special characters as necessary
     @specials{('/', '*', '#', '=', '<', '>', '{', '}' , '-', '?', '@', '+', 'heredoc', 'colon', 'tag', 'embedded', 'number')}=(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0);

     # trace, if necessary
     warn "[Trace] Entered text state.\n" if $flags{trace} & TRACE_SEMANTIC;

     # well done
     return;
    };

  # enter new state: text
  $newState==STATE_TABLE and do
    {
     # prepare lexer
     @lexerFlags{qw(ils eol el)}=(LEXER_SPACE, LEXER_TOKEN, LEXER_TOKEN);

     # activate special characters as necessary
     @specials{('/', '*', '#', '=', '<', '>', '{', '}' , '-', '?', '@', '+', 'heredoc', 'colon', 'tag', 'embedded', 'number')}=(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0);

     # trace, if necessary
     warn "[Trace] Entered table paragraph state.\n" if $flags{trace} & TRACE_SEMANTIC;

     # well done
     return;
    };

  # enter new state: text
  $newState==STATE_DEFINITION and do
    {
     # prepare lexer
     @lexerFlags{qw(ils eol el)}=(LEXER_IGNORE, LEXER_SPACE, LEXER_TOKEN);

     # activate special characters as necessary
     @specials{('/', '*', '#', '=', '<', '>', '{', '}' , '-', '?', '@', '+', 'heredoc', 'colon', 'tag', 'embedded', 'number')}=(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0);

     # trace, if necessary
     warn "[Trace] Entered macro definition state.\n" if $flags{trace} & TRACE_SEMANTIC;

     # well done
     return;
    };

  # enter new state: unordered list point - defined item
  ($newState==STATE_DPOINT_ITEM) and do
    {
     # prepare lexer
     @lexerFlags{qw(ils eol el)}=(LEXER_IGNORE, LEXER_SPACE, LEXER_TOKEN);

     # activate special characters as necessary
     @specials{('/', '*', '#', '=', '<', '>', '{', '}' , '-', '?', '@', '+', 'heredoc', 'colon', 'tag', 'embedded', 'number')}=(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0);

     # trace, if necessary
     warn "[Trace] Entered definition item state.\n" if $flags{trace} & TRACE_SEMANTIC;

     # well done
     return;
    };

  # enter new state: unordered list point
  ($newState==STATE_UPOINT or $newState==STATE_OPOINT or $newState==STATE_DPOINT) and do
    {
     # prepare lexer
     @lexerFlags{qw(ils eol el)}=(LEXER_IGNORE, LEXER_SPACE, LEXER_TOKEN);

     # activate special characters as necessary
     @specials{('/', '*', '#', '=', '<', '>', '{', '}' , '-', '?', '@', '+', 'heredoc', 'colon', 'tag', 'embedded', 'number')}=(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0);

     # trace, if necessary
     warn "[Trace] Entered point state.\n" if $flags{trace} & TRACE_SEMANTIC;

     # well done
     return;
    };

  # enter new state: block
  $newState==STATE_BLOCK and do
    {
     # prepare lexer
     @lexerFlags{qw(ils eol el)}=(LEXER_SPACE, LEXER_TOKEN, LEXER_TOKEN);

     # activate special characters as necessary
     @specials{('/', '*', '#', '=', '<', '>', '{', '}' , '-', '?', '@', '+', 'heredoc', 'colon', 'tag', 'embedded', 'number')}=(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0);

     # trace, if necessary
     warn "[Trace] Entered block state.\n" if $flags{trace} & TRACE_SEMANTIC;

     # well done
     return;
    };

  # enter new state: verbatim block
  $newState==STATE_VERBATIM and do
    {
     # prepare lexer
     @lexerFlags{qw(ils eol el)}=(LEXER_SPACE, LEXER_TOKEN, LEXER_TOKEN);

     # activate special characters as necessary
     @specials{('/', '*', '#', '=', '<', '>', '{', '}' , '-', '?', '@', '+', 'heredoc', 'colon', 'tag', 'embedded', 'number')}=(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0);

     # trace, if necessary
     warn "[Trace] Entered verbatim state.\n" if $flags{trace} & TRACE_SEMANTIC;

     # well done
     return;
    };

  # enter new state: embedding
  $newState==STATE_EMBEDDING and do
    {
     # prepare lexer
     @lexerFlags{qw(ils eol el)}=(LEXER_SPACE, LEXER_TOKEN, LEXER_TOKEN);

     # activate special characters as necessary
     @specials{('/', '*', '#', '=', '<', '>', '{', '}' , '-', '?', '@', '+', 'heredoc', 'colon', 'tag', 'embedded', 'number')}=(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0);

     # trace, if necessary
     warn "[Trace] Entered embedding state.\n" if $flags{trace} & TRACE_SEMANTIC;

     # well done
     return;
    };

  # enter new state: condition (very similar to embedding, naturally)
  $newState==STATE_CONDITION and do
    {
     # prepare lexer
     @lexerFlags{qw(ils eol el)}=(LEXER_SPACE, LEXER_SPACE, LEXER_TOKEN);

     # activate special characters as necessary
     @specials{('/', '*', '#', '=', '<', '>', '{', '}' , '-', '?', '@', '+', 'heredoc', 'colon', 'tag', 'embedded', 'number')}=(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);

     # trace, if necessary
     warn "[Trace] Entered condition state.\n" if $flags{trace} & TRACE_SEMANTIC;

     # well done
     return;
    };

  # enter new state: unordered list point
  $newState==STATE_CONTROL and do
    {
     # prepare lexer
     @lexerFlags{qw(ils eol el)}=(LEXER_IGNORE, LEXER_IGNORE, LEXER_TOKEN);

     # activate special characters as necessary
     @specials{('/', '*', '#', '=', '<', '>', '{', '}' , '-', '?', '@', '+', 'heredoc', 'colon', 'tag', 'embedded', 'number')}=(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);

     # trace, if necessary
     warn "[Trace] Entered control state.\n" if $flags{trace} & TRACE_SEMANTIC;

     # well done
     return;
    };

  # check yourself
  confess "[BUG] Unhandled state $newState.\n";
 }


=pod

=head2 run()

This function starts the parser to process a number of specified files.

B<Parameters:>
All parameters except of the I<object> parameter are named (pass them by hash).

=over 4

=item activeBaseData

This optional parameter allows to pass common data to all active contents
(conditions, embedded and included Perl) by a I<hash reference>. By convention,
a translator at least passes the target language and user settings by

  activeBaseData => {
                     targetLanguage => "lang",
                     userSettings   => \%userSettings,
                    },

User settings are intended to allow the specification of per call settings by a
user, e.g. to include special parts. By using this convention, users can easily
specify such a part the following way

  ? flagSet(setting)

  Special part.

  ? 1

It is up to a translator author to declare translator specific settings (and to
document them). The passed values can be as complex as necessary as long as they
can be duplicated by C<Storable::dclone()>.

Whenever active contents is invoked, the passed hash reference is copied 
(duplicated by C<Storable::dclone()>) into the Safe objects namespace
(see I<safe>) as a global variable $PerlPoint. This way, modifications by
invoked code do not effect subsequently called code snippets, base data are
always fresh.

=item activeDataInit

Reserved to pass hook functions to be called preparing every active contents
invokation. I<The hook is still unimplemented.>

=item cache

This optional parameter controls source file paragraph caching.

By default, a source file is parsed completely everytime you pass it to the
parser. This is no problem with tiny sources but can delay your work if you
are dealing with large sources which have to be translated periodically into
presentations while they are written. Typically most of the paragraphs remain
unchanged from version to version, but nevertheless everything is usually
reparsed which means a waste of time. Well, to improve this a paragraph
cache can be activated by setting this option to B<CACHE_ON>.

The parser caches each I<initial source file> individually. That means
if three files are passed to the parser with activated caching, three cache
files will be written. They are placed in the source file directory, named
.<source file>.ppcache. Please note that the paragraphs of I<included> sources
are cached in the cache file of the I<main> document because they may have to
be evaluated differently depending on inclusion context.

What acceleration can be expected? Well, this I<strongly>
depends on your source structure. Efficiency will grow with longer paragraphs,
reused paragraphs and paragraph number. It will be reduced by heavy usage
of active contents and embedding because every paragraph that refers
to parts defined externally is not strongly determined by itself and therefore
it cannot be cached. Here is a list of all reasons which cause a paragraph to
be excluded from caching:

=over 4

=item Embedded parts

Obviously dynamic parts may change from one version to another, but even static
parts could have to be interpreted differently because a user can set up new
I<filter>s.

=item Included files

An \INCLUDE tag immediately disables caching for the paragraph it resides in
because the loaded file may change its contents. This is not really a
restriction because the included paragraphs themselves I<are> cached if possible.

=back

Even with these restrictions about 70% of a real life document of more than
150 paragraphs could be cached. This saved more than 60% of parsing time in
subsequent translator calls.

New cache entries are always I<added> which means that old entries are never
replaced and a cache file tends to grow. If you ever wish to clean up a
cache file completely pass B<CACHE_CLEANUP> to this option.

To deactivate caching explicitly pass B<CACHE_OFF>.
I<An existing cache will not be destroyed.>

Settings can be combined by I<addition>.

  # clean up the cache, then refill it
  cache => CACHE_CLEANUP+CACHE_ON,

  # clean up the cache and deactivate it
  cache => CACHE_CLEANUP+CACHE_OFF,

The B<CACHE_OFF> value is overwritten by any other setting.

It is suggested to make this setting available to translator users to let
them decide if a cache should be used.

I<Please note> that there is a problem with line numbers if paragraphs are
restored from cache because of the behaviour of perls paragraph mode. In this
mode, the <> operator reads in any number of newlines between paragraphs but
supplies only one of them. That is why I do not get the real number of lines
in a paragraph and therefore cannot store them. To work around this, two
strategies can be used. First, do not use more than exactly one newline
between paragraphs. (This strategy is not for real life users, of course,
but in this case restored numbers would be correct.) Second, remember that
source line numbers are only interesting in error messages. If the parser
detects an error, it therefore says: error "there or later" when a cache hit
already occured. If the real number is wished the parser could be reinvoked
then with deactivated cache and will report it.

I<Another known paragraph mode problem> occurs if you parse on a UNIX
system but your document (or parts of it) were written in DOS format. The
paragraph mode reads such a document I<completely>. Please replace the line
ending character sequences system appropriate. (If you are using C<dos2unix>
under Solaris please invoke it with option C<-ascii> to do this.)

More, Perls paragraph mode and PerlPoint treat whitespace lines differently.
Because of the way it works, paragraph mode does not recognize them as "empty"
while PerlPoint I<does> for reasons of usability (invisible characters should
not make a difference). This means that lines containing only whitespaces
separate PerlPoint paragraphs but not "Perl" paragraphs, making the cache
working wrong especially in examples. If paragraphs unintentionally disappear
in the resulting presentation, please check the "empty lines" before them.

Consistent cache data depend on the versions of the parser, of constant
declarations and of the module B<Storable> which is used internally. If the
parser detects a significant change in one of these versions, existing
caches are automatically rebuilt.

I<Final cache note:> cache files are not locked while they are used.
If you need this feature please let me know.

=item display

This parameter is optional. It controls the display of runtime messages
like informations or warnings. By default, all messages are displayed. You
can suppress these informations partially or completely by passing one or
more of the "DISPLAY_..." variables declared in B<PerlPoint::Constants>.
Constants should be combined by addition.

=item files

a reference to an array of files to be scanned.

=item filter

a regular expression describing the target language. This setting, if used,
prevents all embedded or included source code of other languages than the set
one from inclusion into the generated stream. This accelerates both parsing
and backend handling. The pattern is evaluated case insensitively.

 Example: pass "html|perl" to allow HTML and Perl.

To illustrate this, imagine a translator to PostScript. If it reads a Perl
Point file which includes native HTML, this translator cannot handle such code.
The backend would have to skip the HTML statements. With a "PostScript" filter,
the HTML code will not appear in the stream.

This enables PerlPoint texts prepared for various target languages. If an
author really needs plain target language code to be embedded into PerlPoint,
he could provide versions for various languages. Translators using a filter
will then receive exactly the code of their target language, if provided.

Please note that you cannot filter out PerlPoint code or example files.

By default, no filter is set.

=item linehints

If set to a true value, the parser will embed line hints into the stream
whenever a new source line begins.

A line hint directive is provided as

  [
   DIRECTIVE_NEW_LINE, DIRECTIVE_START,
   {file=>filename, line=>number}
  ]

and is suggested to be handled by a backend callback.

Please note that currently source line numbers are not guaranteed to be
correct if stream parts are restored from I<cache> (see there for details).

The default value is 0.

=item nestedTables

This is an optional flag which is by default set to 0, indicating if the parser
shall accept nested tables or not. Table nesting can produce very nice results
if it is supported by the target language. HTML, for example, allows to nest
tables, but other languages I<do not>. So, using this feature can really improve
the results if a user is focussed on supporting certain target formats only. If I want
to produce nothing but HTML, why should I take care of target formats not able
to handle table nesting? On the other hand, I<if> a document shall be translated
into several formats, it might cause trouble to nest tables therein.

Because of this, it is suggested to let converter users decide if they want to
enable table nesting or not. If the target format does not support nesting, I
recommend to disable nesting completely.


=item object

the parser object made by I<new()>;

=item safe

an object of the B<Safe> class which comes with perl. It is used to evaluate
embedded Perl code in a safe environment. By letting the caller of I<run()>
provide this object, a translator author can make the level of safety fully
configurable by users. Usually, the following should work

  use Safe;
  ...
  $parser->run(safe=>new Safe, ...);

Safe is a really good module but unfortunately limited in loading modules
transparently. So if a user wants to use modules in his embedded code, he
might fail to get it working in a Safe compartment. If safety does not matter,
he can decide to execute it without Safe, with full Perl access. To switch
on this mode, pass a true scalar value (but no reference) instead of a Safe
object.

To make all PerlPoint converters behave similarly, it is recommended to provide
two related options C<-activeContents> and C<-safeOpcode>. C<-activeContents>
should flag that active contents shall be evaluated, while C<-safeOpcode>
controls the level of security. A special level C<ALL> should mean that all
code can b executed without any restriction, while any other settings should be
treated as an opcode to configure the Safe object. So, the recommended rules
are: pass 0 unless C<-activeContents> is set. Pass 1 if the converter was
called with C<-activeContents> I<and> C<-safeOpcode ALL>. Pass a Safe object
and configure it according to the users C<-safeOpcode> settings if
C<-activeContents> is used but without C<-safeOpcode ALL>. See C<pp2sdf>
for an implementation example.

Active Perl contents is I<suppressed> if this setting is omitted or if anything
else than a B<Safe> object is passed. (There are currently three types of active
contents: embedded or included Perl and condition paragraphs.)


=item predeclaredVars

Variables are usually set by assignment paragraphs. However, it may be useful
for a converter to predeclare a set of them to provide certain settings to the
users. Predeclared variables, as any other PerlPoint variables, can be used
both in pure PerlPoint and in active contents. To help users distinguish them
from user defined vars, their names will be I<capitalized>.

Just pass a hash of variable name / value pairs:

  $parser->run(
               ...
               predeclaredVars => {
                                   CONVERTER_NAME    => 'pp2xy',
                                   CONVERTER_VERSION => $VERSION,
                                   ...
                                  },
              );

Non capitalized variable names will be capitalized without further notice.

Please note that variables currently can only be scalars. Different data types
will not be accepted by the parser.

Predeclared variables should be mentioned in the converters documentation.

The parser itself makes use of this feature by declaring C<_PARSER_VERSION>
(the version of this module used to parse the source) and _STARTDIR (the full
path of the startup directory, as reported by C<Cwd::cdw()>).

C<predeclaredVars> needs C<var2stream> to take effect.


=item stream

A reference to an array where the generated output stream should be stored in.

Application programmers may want to tie this array if the target ASCII
texts are expected to be large (long ASCII texts can result in large stream
data which may occupy a lot of memory). Because of the fact that the parser
stores stream data I<by paragraph>, memory consumption can be reduced
significantly by tying the stream array.

It is recommended to pass an empty array. Stored data will not be overwritten,
the parser I<appends> its data instead (by C<push()>).

=item trace

This parameter is optional. It is intended to activate trace code while the method
runs. You may pass any of the "TRACE_..." constants declared in B<PerlPoint::Constants>,
combined by addition as in the following example:

  # show the traces of both
  # lexical and syntactical analysis
  trace => TRACE_LEXER+TRACE_PARSER,

If you omit this parameter or pass TRACE_NOTHING, no traces will be displayed.

=item var2stream

If set to a true value, the parser will propagate variable settings into the stream
by adding additional C<DIRECTIVE_VARSET> directives.

A variable propagation has the form

  [
   DIRECTIVE_VARSET, DIRECTIVE_START,
   {var=>varname, value=>value}
  ]

and is suggested to be handled by a backend callback.

The default value is 0.

=item vispro

activates "process visualization" which simply means that a user will see
progress messages while the parser processes documents. The I<numerical>
value of this setting determines how often the progress message shall be
updated, by a I<chapter interval>:

  # inform every five chapters
  vispro => 5,

Process visualization is automatically suppressed unless STDERR is
connected to a terminal, if this option is omitted, I<display> was set
to C<DISPLAY_NOINFO> or parser I<trace>s are activated.

=back

B<Return value:>
A "true" value in case of success, "false" otherwise. A call is performed
successfully if there was neither a syntactical nor a semantic error in the
parsed files.

B<Example:>

  $parser->run(
               stream => \@streamData,
               files  => \@ARGV,
               filter => 'HTML',
               cache  => CACHE_ON,
               trace  => TRACE_PARAGRAPHS,
              );

=cut
sub run 
 {
  # get parameters
  my ($me, @pars)=@_;

  # build parameter hash
  confess "[BUG] The number of parameters should be even.\n" if @pars%2;
  my %pars=@pars;

  # and check parameters
  confess "[BUG] Missing object parameter.\n" unless $me;
  confess "[BUG] Object parameter is no ", __PACKAGE__, " object.\n" unless ref $me and ref $me eq __PACKAGE__;
  confess "[BUG] Missing stream array reference parameter.\n" unless $pars{stream};
  confess "[BUG] Stream array reference parameter is no array reference.\n" unless ref $pars{stream} and ref $pars{stream} eq 'ARRAY';
  confess "[BUG] Missing file list reference parameter.\n" unless $pars{files};
  confess "[BUG] File list reference parameter is no array reference.\n" unless ref $pars{files} and ref $pars{files} eq 'ARRAY';
  confess "[BUG] You should pass at least one file to parse.\n" unless @{$pars{files}};
  confess "[BUG] Active base data reference is no hash reference.\n" if exists $pars{activeBaseData} and ref $pars{activeBaseData} ne 'HASH';
  confess "[BUG] Active data initializer is no code reference.\n" if exists $pars{activeDataInit} and ref $pars{activeDataInit} ne 'CODE';
  if (exists $pars{filter})
    {
     eval "'lang'=~/$pars{filter}/";
     confess "[BUG] Invalid filter expression \"$pars{filter}\": $@.\n" if $@;
    }

  # variables
  my ($rc)=(1);

  # init internal data
  (
   $resultStreamRef,         #  1
   $safeObject,              #  2
   $flags{trace},            #  3
   $flags{display},          #  4
   $flags{filter},           #  5
   $flags{linehints},        #  6
   $flags{var2stream},       #  7
   $flags{cache},            #  8
   $flags{cached},           #  9
   $flags{vis},              # 10
   $flags{activeBaseData},   # 11
   $flags{activeDataInit},   # 12
   $flags{nestedTables},     # 13
   $macroChecksum,           # 14
   $varChecksum,             # 15
  )=(
     $pars{stream},                                                              #  1
     (                                                                           #  2
          exists $pars{safe}
      and defined $pars{safe}
     ) ? ref($pars{safe}) eq 'Safe' ? $pars{safe}
                                    : 1
       : 0,
     exists $pars{trace} ? $pars{trace} : TRACE_NOTHING,                         #  3
     exists $pars{display} ? $pars{display} : DISPLAY_ALL,                       #  4
     exists $pars{filter} ? $pars{filter} : '',                                  #  5
     (exists $pars{linehints} and $pars{linehints}),                             #  6
     (exists $pars{var2stream} and $pars{var2stream}),                           #  7
     exists $pars{cache} ? $pars{cache} : CACHE_OFF,                             #  8
     0,                                                                          #  9
     exists $pars{vispro} ? $pars{vispro} : 0,                                   # 10
     exists $pars{activeBaseData} ? fields::phash(%{$pars{activeBaseData}}) : 0, # 11
     exists $pars{activeDataInit} ? $pars{activeDataInit} : 0,                   # 12
     exists $pars{nestedTables} ? $pars{nestedTables} : 0,                       # 13
     0,                                                                          # 14
     0,                                                                          # 15
    );

  # declare helper subroutines to be used in active contents
  if ($safeObject)
    {
     my $code=<<'EOC';

  # check if a flag is set
  sub flagSet
    {exists $PerlPoint->{userSettings}{$_[0]};}

  # supply variable value
  sub varValue
    {${join('::', 'main', $_[0])};}

# complete compartment code
EOC

     ref($safeObject) ? $safeObject->reval($code) : eval(join(' ', '{package main; no strict;', $code, '}'));
    }

  # predeclare variables
  predeclareVariables({_PARSER_VERSION=>$PerlPoint::Parser::VERSION, _STARTDIR=>cwd()});

  # store initial variables, if necessary
  if (exists $pars{predeclaredVars})
    {
     # check data format
     confess "[BUG] Please pass predeclared variables by a hash reference .\n" unless ref($pars{predeclaredVars}) eq 'HASH';

     # declare
     predeclareVariables($pars{predeclaredVars});
    }

  # update visualization flag
  $flags{vis}=0 unless     $flags{vis}
                       and not $flags{display} & &DISPLAY_NOINFO
                       and not $flags{trace}>TRACE_NOTHING
                       and -t STDERR;

  # init more
  @flags{qw(skipInput headlineLevelOffset headlineLevel olist)}=(0) x 4;
  $statistics{cache}[1]=0 if $flags{cache} & CACHE_ON;

  # check tag declarations
  unless (ref($PerlPoint::Tags::tagdefs) eq 'HASH')
    {
     # warn user
     warn "[Warn] No tags are declared. No tags will be detected.\n" unless $flags{display} & DISPLAY_NOWARN;

     # init shortcut pointer
     $tagsRef={};
    }
  else
    {
     # ok, there are tags, make a shortcut
     $tagsRef=$PerlPoint::Tags::tagdefs;
    }

  # welcome user
  unless ($flags{display} & DISPLAY_NOINFO)
   {  
    print STDERR "[Info] The PerlPoint parser ";
    {
     no strict 'refs';
     print STDERR ${join('::', __PACKAGE__, 'VERSION')};
    }
    warn " starts.\n";
    warn "       Active contents is ", $safeObject ? ref($safeObject) ? 'safely evaluated' : 'risky evaluated' : 'ignored', ".\n";

    # report cache mode
    warn "       Paragraph cache is ", ($flags{cache} & CACHE_ON) ? '' : 'de', "activated.\n";
   }

  # save current directory
  my $startupDirectory=cwd();

  # scan all input files
  foreach my $file (@{$pars{files}})
    {
     # inform user
     warn "[Info] Processing $file ...\n" unless $flags{display} & DISPLAY_NOINFO;

     # init input stack
     @inputStack=([]);

     # init nesting stack
     @nestedSourcefiles=($file);

     # update source file nesting level hint
     predeclareVariables({_SOURCE_LEVEL=>scalar(@nestedSourcefiles)});

     # update file hint
     $sourceFile=$file;

     # open file and make the new handle the parsers input
     open($inHandle, $file) or confess("[Fatal] Could not open input file $file.\n");

     # store the filename in the list of opened sources, to avoid circular reopening
     # (it would be more perfect to store the complete path, is there a module for this?)
     $openedSourcefiles{$file}=1;

     # change into the source directory
     chdir(dirname($file));

     # (cleanup and) read old checksums as necessary
     my $cachefile=sprintf(".%s.ppcache", basename($file));
     if (($flags{cache} & CACHE_CLEANUP) and -e $cachefile)
       {
	warn "       Resetting paragraph cache for $file.\n" unless $flags{display} & DISPLAY_NOINFO;
	unlink($cachefile);
       }
     if (($flags{cache} & CACHE_ON) and -e $cachefile)
       {
        $checksums=retrieve($cachefile) ;
        #use Data::Dumper; warn Dumper($checksums);

        # clean up old format caches
        unless (
                    exists $checksums->{sha1_base64('version')}
                and $checksums->{sha1_base64('version')}>=0.34

                and exists $checksums->{sha1_base64('constants')}
                and $checksums->{sha1_base64('constants')}==$PerlPoint::Constants::VERSION

                and exists $checksums->{sha1_base64('Storable')}
                and $checksums->{sha1_base64('Storable')}==$Storable::VERSION
               )
          {
           warn "       Paragraph cache for $file is rebuilt because of an old format.\n" unless $flags{display} & DISPLAY_NOINFO;
           unlink($cachefile);
           $checksums={};
          }
       }

     # store cache builder version and constant declarations version
     if ($flags{cache} & CACHE_ON)
       {
        $checksums->{sha1_base64('version')}=$PerlPoint::Parser::VERSION;
        $checksums->{sha1_base64('constants')}=$PerlPoint::Constants::VERSION;
        $checksums->{sha1_base64('Storable')}=$Storable::VERSION;
       }

     # store a document start directive (done here to save memory)
     push(@$resultStreamRef, [DIRECTIVE_DOCUMENT, DIRECTIVE_START, basename($file)]);

     # enter first (and most common) lexer state
     stateManager(STATE_DEFAULT);

     # flag that the next paragraph can be checksummed, if so
     $flags{checksum}=1 if $flags{cache} & CACHE_ON;

     # set a timestamp, if helpful
     $flags{started}=time unless $flags{display} & DISPLAY_NOINFO;

     # parse input
     $rc=($rc and $me->YYParse(yylex=>\&lexer, yyerror=>\&_Error, yydebug => ($flags{trace} & TRACE_PARSER) ? 0x1F : 0x00));

     # stop time, if necessary
     warn "\n       $file was parsed in ", time-$flags{started}, " seconds.\n" unless $flags{display} & DISPLAY_NOINFO;

     # store a document completion directive (done here to save memory)
     push(@$resultStreamRef, [DIRECTIVE_DOCUMENT, DIRECTIVE_COMPLETE, basename($file)]);

     # reset the input handle and flags
     $readCompletely=0;

     # store checksums, if necessary
     store($checksums, $cachefile) if     ($flags{cache} & CACHE_ON)
                                      and $flags{cached}
                                      and defined $checksums and %$checksums;

     # close the input file
     close($inHandle);
     $inHandle=new IO::File;

     # back to startup directory
     chdir($startupDirectory);
    }

  # success?
  if ($rc and not $semErr)
    {
     # display a summary
     warn <<EOM unless $flags{display} & DISPLAY_NOINFO;

[Info] Input ok.

       Statistics:
       -----------
       ${\(statisticsHelper(DIRECTIVE_HEADLINE, 'headline'))},
       ${\(statisticsHelper(DIRECTIVE_TEXT, 'text'))},
       ${\(statisticsHelper(DIRECTIVE_UPOINT, 'unordered list point'))},
       ${\(statisticsHelper(DIRECTIVE_OPOINT, 'ordered list point'))},
       ${\(statisticsHelper(DIRECTIVE_DPOINT, 'definition list point'))},
       ${\(statisticsHelper(DIRECTIVE_BLOCK, 'block'))},
       ${\(statisticsHelper(DIRECTIVE_VERBATIM, 'verbatim block'))},
       ${\(statisticsHelper(DIRECTIVE_TAG, 'tag'))}
       ${\(statisticsHelper(DIRECTIVE_LIST_RSHIFT, 'right list shifter'))},
       ${\(statisticsHelper(DIRECTIVE_LIST_LSHIFT, 'left list shifter'))},
       and ${\(statisticsHelper(DIRECTIVE_COMMENT, 'comment'))} were detected in ${\(join('', scalar(@{$pars{files}}), ' file', @{$pars{files}}==1?'':'s'))}.

EOM

     # add cache informations, if necessary
     warn  ' ' x length('[Info] '), int(100*$statistics{cache}[1]/$statistics{cache}[0]+0.5), "% of all checked paragraphs were restored from cache.\n\n" if $flags{cache} & CACHE_ON and not $flags{display} & DISPLAY_NOINFO;
    }
  else
    {
     # display a summary
     warn "[Info] Input contains $semErr semantic error", $semErr>1?'s':'', ".\n" if $semErr;
    }

  # inform user
  warn "[Info] Parsing completed.\n\n" unless $flags{display} & DISPLAY_NOINFO;

  # reply success state
  $rc and not $semErr;
 }

# ------------------------------------------------------
# A tiny helper function intended for internal use only.
# ------------------------------------------------------
sub statisticsHelper
 {
  # get and check parameters
  my ($type, $string)=@_;
  confess "[BUG] Missing type parameter.\n" unless defined $type;
  confess "[BUG] Missing string parameter.\n" unless $string;

  # declare variables
  my ($nr)=(exists $statistics{$type} and $statistics{$type}) ? $statistics{$type} : 0;

  # reply resulting string
  join('', "$nr $string", $nr==1 ? '' : 's');
 }

sub updateChecksums
 {
  # get and check parameters
  my ($streamPart, $parserReinvokationHint)=@_;
  confess "[BUG] Missing stream part parameter.\n" unless defined $streamPart;
  confess "[BUG] Stream part parameter is no reference.\n" unless ref($streamPart);

  # certain paragraph types are not cached intentionally
  return if    not ($flags{cache} & CACHE_ON)
            or exists {
                       DIRECTIVE_COMMENT() => 1,
                      }->{$streamPart->[0][0]};

  if (exists $flags{checksummed} and $flags{checksummed})
    {
     $checksums->{$sourceFile}{$flags{checksummed}[0]}=[
                                                        dclone($streamPart),
                                                        $flags{checksummed}[2],
                                                        $parserReinvokationHint ? $parserReinvokationHint : (),
                                                        defined $flags{checksummed}[3] ? $macroChecksum : (),
                                                        defined $flags{checksummed}[4] ? $varChecksum : (),
                                                       ];
     # use Data::Dumper;
     # warn Dumper($streamPart);
     $flags{checksummed}=undef;

     # note that something new was cached
     $flags{cached}=1;
    }
 }


# --------------------------------------------------------
# Extend all table rows to the number of columns found
# in the first table line ("table headline"). On request,
# automatically format the first table line as "headline".
# --------------------------------------------------------
sub normalizeTableRows
 {
  # get and check parameters
  my ($stream, $autoHeadline)=@_;
  confess "[BUG] Missing stream part reference parameter.\n" unless defined $stream;
  confess "[BUG] Stream part reference parameter is no array reference.\n" unless ref($stream) eq 'ARRAY';
  confess "[BUG] Missing headline mode parameter.\n" unless defined $autoHeadline;

  # declare variables
  my ($refColumns, $columns, $nested, @flags, @improvedStream)=(0, 0.5, 0, 1);

  # remove whitespaces at the beginning and end of the stream, if necessary
  shift(@$stream) if $stream->[0]=~/^\s*$/; $stream->[0]=~s/^\s+//;
  pop(@$stream) if $stream->[-1]=~/^\s*$/; $stream->[-1]=~s/\s+$//;

  # process the received stream
  foreach (@$stream)
    {
     # search for *embedded* tables - which are already normalized!
     $nested+=($_->[1]==DIRECTIVE_START ? 1 : -1)
       if ref($_) eq 'ARRAY' and $_->[0]==DIRECTIVE_TAG and $_->[2] eq 'TABLE';

     # Inside an embedded table? Just pass the stream unchanged then.
     push(@improvedStream, $_), next if $nested;

     # check state, set flags
     $flags[1]=(ref($_) eq 'ARRAY' and $_->[0]==DIRECTIVE_TAG);
     $flags[2]=($flags[1] and $_->[2] eq 'TABLE_COL');
     $flags[3]=($flags[1] and $_->[1]==DIRECTIVE_COMPLETE and $_->[2] eq 'TABLE_ROW');
     $flags[4]=1 if $flags[2] and $_->[1]==DIRECTIVE_START;
     $flags[4]=0 if $flags[2] and $_->[1]==DIRECTIVE_COMPLETE;

     # update counter of current row columns
     $columns+=0.5 if $flags[2];

        # end of column reached?
        if ($flags[2] and not $flags[4])
          {
           # remove all trailing whitespaces in the last recent data entry,
           # remove data which becomes empty this way
           $improvedStream[-1]=~s/\s+$//;
           pop(@improvedStream) unless $improvedStream[-1];
          }

        # first data after opening a new column?
        if ($flags[4] and not $flags[2])
          {
           # reset flag
           $flags[4]=0;

           # remove all leading whitespaces, skip data which becomes empty this way
           s/^\s+//;
           next unless $_;
          }

     # table headline row?
     if ($flags[0])
       {
        # ok: mark columns as headline parts if necessary, take other elements unchanged
        push(@improvedStream, ($flags[2] and $autoHeadline)? [@{$_}[0, 1], 'TABLE_HL'] : $_);
        # at the end of this first row, marks that it is reached, store the number
        # of its columns as a reference for the complete table, and reset the column counter
        # (which will be used slightly differently in the following lines)
        $flags[0]=0, $refColumns=$columns, $columns=0 if $flags[3];
       }
     else
       {
        # this is a content row (take care to preserve the order of operations here)

        # end of table row reached?
        if ($flags[3])
          {
           # yes: insert additional columns, if necessary
           push(
                @improvedStream,
                [DIRECTIVE_TAG, DIRECTIVE_START, 'TABLE_COL'],
                [DIRECTIVE_TAG, DIRECTIVE_COMPLETE, 'TABLE_COL'],
               ) for 1 .. ($refColumns-$columns);
           
           # reset column counter
           $columns=0;
          }
        
        # in any case, copy this stream part
        push(@improvedStream, $_);
       }
    }

  # replace original stream by the improved variant
  @$stream=@improvedStream;
 }


# predeclare variables
sub predeclareVariables
 {
  # get and check parameters
  my ($declarations, $preserveNames)=@_;
  confess "[BUG] Missing declaration parameter.\n" unless defined $declarations;
  confess "[BUG] Declaration parameter is no hash reference.\n" unless ref($declarations) eq 'HASH';

  # transform variable names, if necessary
  {
   my $c=0;
   %$declarations=map {$c++; $c%2 ? uc : $_} %$declarations unless $preserveNames;
  }

  # handle every setting (keys are sorted for test puposes only, to make the stream reproducable)
  foreach my $var (sort {$a cmp $b} keys %$declarations)
    {
     # check data format
     confess "[BUG] Predeclared variable $var is no scalar.\n" if ref($declarations->{$var});

     # store the variable - with an uppercased name
     $variables{$var}=$declarations->{$var};

     # propagate the setting to the stream, if necessary
     push(@$resultStreamRef, [DIRECTIVE_VARSET, DIRECTIVE_START, {var=>$var, value=>$declarations->{$var}}]) if $flags{var2stream};

     # make the new variable setting available to embedded Perl code, if necessary
     if ($safeObject)
       {
        no strict 'refs';
        ${join('::', ref($safeObject) ? $safeObject->root : 'main', $var)}=$declarations->{$var};
       }
    }
 }



1;

# declare a helper package used for token "delay" after bodyless macros
# (implemented the oo way to determine the data)
package PerlPoint::Parser::DelayedToken;

# even this tiny package needs modules!
use Carp;

# make an object holding the token name and its value
sub new
 {
  # get parameter
  my ($class, $token, $value)=@_;

  # check parameters
  confess "[BUG] Missing class name.\n" unless $class;
  confess "[BUG] Missing token parameter.\n" unless $token;
  confess "[BUG] Missing token value parameter.\n" unless defined $value;

  # build and reply object
  bless([$token, $value], $class);
 }

# reply token
sub token {$_[0]->[0];}

# reply value
sub value {$_[0]->[1];}

1;


# = POD TRAILER SECTION =================================================================

=pod

=head1 EXAMPLE

The following code shows a minimal but complete parser.

  # pragmata
  use strict;

  # load modules
  use PerlPoint::Parser;

  # declare variables
  my (@streamData);

  # build parser
  my ($parser)=new PerlPoint::Parser;
  # and call it
  $parser->run(
               stream  => \@streamData,
               files   => \@ARGV,
              );

=head1 NOTES

=head2 Converter namespace

It is suggested to B<avoid> operating in namespace B<main::>. In order to emulate
the behaviour of the B<Safe> module by C<eval()> in case a user wishes to get
full Perl access for active contents, active contents needs to be executed in
this namespace. Safe does not allow to change this, so the documented default
for "saved" and "not saved" active contents I<needs> to be C<main::>. This means
that both the parser and active contents will pollute C<main::>. Prevent from being
effected by choosing a different converter namespace. The B<PerlPoint::Converter::>
 hyrarchy is reserved for this purpose. The recommended namespace is
C<PerlPoint::Converter::<converter name>>, e.g. C<PerlPoint::Converter::pp2sdf>.

=head2 Format

The PerlPoint format was initially designed by I<Tom Christiansen>,
who wrote an HTML slide generator for it, too.

I<Lorenz Domke> added a number of additional, useful and interesting
features to the original implementation. At a certain point, we
decided to redesign the tool to make it a base for slide generation
not only into HTML but into various document description languages.

The PerlPoint format implemented by this parser version is slightly
different from the original design. Presentations written for Perl
Point 1.0 will I<not> pass the parser but can simply be converted
into the new format. We designed the new format as a team of
I<Lorenz Domke>, I<Stephen Riehm> and me.

=head2 Storable updates

From version 0.24 on the Storable module is a prerequisite of the
parser package because Storable is used to store and retrieve cache
data in files. If you update your Storable installation it I<might>
happen that its internal format changes and therefore stored cache
data becomes unreadable. To avoid this, the parser automatically
rebuilds existing caches in case of Storable updates.

=head1 FILES

If I<cache>s are used, the parser writes cache files where the initial
sources are stored. They are named .<source file>.ppcache.

=head1 SEE ALSO

=over 4

=item PerlPoint::Backend

A frame class to write backends basing on the I<STREAM OUTPUT>.

=item PerlPoint::Constants

Constants used by parser functions and in the I<STREAM FORMAT>.

=item PerlPoint::Tags

Tag declaration base class.

=item pp2sdf

A reference implementation of a PerlPoint converter, distributed with the parser package.

=item pp2html

The inital PerlPoint tool designed and provided by Tom Christiansen. A new translator
by I<Lorenz Domke> using B<PerlPoint::Package>.

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
http://www.perl.com/perl/misc/Artistic.html.

B<PerlPoint::Parser> is built using B<Parse::Yapp> a way that users
have I<not> to explicitly install B<Parse::Yapp> themselves. According
to the copyright note of B<Parse::Yapp> I have to mention the following:

"The Parse::Yapp module and its related modules and shell
scripts are copyright (c) 1998-1999 Francois Desarmenien,
France. All rights reserved.

You may use and distribute them under the terms of either
the GNU General Public License or the Artistic License, as
specified in the Perl README file."


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

1;
