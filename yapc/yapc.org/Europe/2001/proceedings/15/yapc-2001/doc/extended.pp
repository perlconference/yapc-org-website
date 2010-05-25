
// vim: set filetype=pp2html :

// Erweiterte Sprachmittel

? flagSet(german)

Dieser Abschnitt geht genauer auf Tags, Variablen und dynamische Inhalte ein. 
Tags sind Direktiven, die in den laufenden Text eingestreut sind und die festlegen, wie bestimmte
Teile des Textes interpretiert werden sollen.
Sie dienen z.B. dazu, Text auszuzeichnen, Bilder einzubinden, Hyperlinks zu realisieren,
weitere Vorlagendateien einzubinden oder andere Sprachen einzubetten. Auch Index-Erzeugung und Tabellen
können mit Tags verwirklicht werden.

Weitere Flexibilität erhält man durch Variablendefinitionen und dynamische Inhalte.
PerlPoint bietet die Möglichkeit, die Ausgabe durch Bedingungen zu steuern, Makros 
für häufig benutzte Tagkombinationen oder Textteile zu definieren oder gar beliebigen Perlcode
in die Vorlage einzubetten.

? flagSet(english)

This chapter provides some information about tags, variables and dynamic contents.
Tags are directives which are inserted into the text to determine how parts of the text should
be interpreted.
They are used, for example, to format text, include images, make hyperlinks, include other PerlPoint
files or other languages. Index generation and tables can also be realized with tags.

Further flexibility can be gained be using variables or dynamic contents. PerlPoint offers the 
possibility to control output by conditions, to define macros for often used tag combinations or
text parts and to embed perl code into the PerlPoint input file.

? flagSet(german)


==Tags

// nur ganz allgemein vorstellen - die speziellen Ausprägungen
// bleiben den Übersetzern vorbehalten!

Viele grundlegende Formatierungsaufgaben und Layoutoptionen werden in PerlPoint durch
Tags realisiert.
Darüberhinaus bietet PerlPoint auch die Möglichkeit, weitere backendspezifische Tags zu definieren, die
vom Übersetzungsprogramm für bestimmte Aufgaben ausgewertet werden können.

Bis auf ein paar reservierte Tags müssen alle Tags vom jeweiligen Übersetzerprogramm (z.B. pp2html)
definiert werden. Es sollten auf jeden Fall die aus POD bekannten Tags \C<B>, \C<C>, \C<I> und \C<E>
in allen Übersetzern zur Verfügung stehen. Außerdem wird üblicherweise noch 
das \C<IMAGE>-Tag definiert.


\B<Tags haben die Form:>

 \\TAGNAME [{\I<optional_params>}] [< \I<optional_tag_body> \>]

Der Tagname wird mit einem Backslash eingeleitet und in Großbuchstaben notiert.
Der optionale Parameterteil ist von geschweiften Klammern umgeben und der Tag-Body wird durch
spitze Klammern begrenzt:

? flagSet(english)

==Tags

Many basic formatting issues and layout options are handled by \I<tags> in PerlPoint.
Beside this, each converter program (e. g. \C<pp2html>) can define backend specific tags which can
then be used for special purpose.

With the exception of several reserved basic tags, tags are no part of the base language
but are to be defined by each converter program. This is done by providing special tag definition
modules, see below for details.

\B<The tag syntax is defined as follows:>

 \\TAGNAME[{<\I<optional params>>}][<\I<optional tag body>>]

The tag name begins with a backslash, followed by the name string (in capital letters).
The parameters are optional and enclosed in curly braces ("{}"). The last part ist the
tag body which is enclosed in ancle braces ("\C<<\>>").

? 1

<<EOT
 \TAGNAME
 \TAGNAME< .... >
 \TAGNAME{par1=value1 par2="value2" par3="value with blanks"}< ... >
EOT

? flagSet(german)

Der Parser erkennt alle Tags, die obige Form haben und die beim
Aufruf des Parsers deklariert worden sind.
Ein typischer Aufruf des Parsers wird im Abschnitt \I<\SECTIONREF{name="Vorlagenverarbeitung"}> gezeigt.

Falls ein Tag Optionen hat, folgen diese unmittelbar auf den
Tagnamen. Sie sind in geschweifte Klammern zu setzen. Jede
Option ist eine einfache String-Zuweisung: \I<name=value>.
Der Wert sollte in (doppelte) Hochkommata eingeschlossen werden,
falls er nicht auf \B</^\\w+$/> matcht.

 \\TAG{par1=value1 par2="www.perl.com" par3="words and blanks"}

Der Tag-Body ist der Texteil, auf den sich das Tag bezieht. Er folgt in
spitze Klammern eingeschlossen auf den Tagnamen oder die Parameterliste.

Tags dürfen auch verschachtelt werden. Allerdings ist hier Vorsicht geboten.
Möglicherweise funktionieren nicht alle denkbaren Kombinationen. Man sollte
auf jeden Fall das Ergebnis des jeweiligen Übersetzers prüfen. (Vertrauen ist
gut, Kontrolle ist besser! ;-)

? flagSet(english)

The parser recognizes all declared tags of the above form.

// Do we need the following hint in this context?
// A typical call of the parser object is shown in chapter \I<\SECTIONREF{name="Parsing the input"}>

If a tag has \I<options>, they follow the tag name immediately, enclosed in
curly braces. Each option is a simple string assignment: \I<name=value>.
The value must be enclosed in double quotes (\C<">) if it does not match
the pattern \BC</^\\w+$/> .

 \\TAG{par1=value1 par2="www.perl.com" par3="words and blanks"}

The tag \I<body> is the part of the input text which is modified by the tag. Tag
bodies are enclosed in ancle brackets and follow the tag name or the parameters,
respectively.

Tags may be combined (i. e. tag bodies may contain other tags), but be careful: some
combinations may not work or you must reverse the order of tags. Try and check
the results.

? flagSet(german)

\B<Reservierte Tags:>

Die folgenden Tags sind bereits fest vom \B<PerlPoint::Parser> reserviert,
können also nicht mehr vom Übersetzerautor definiert werden:

? flagSet(english)

\B<Reserved Tags:>

The following tags are reserved by the PerlPoint parser and cannot
be defined by converter authors:

? 1

<<EOT
 \INCLUDE
 \TABLE  \END_TABLE
 \EMBED  \END_EMBED
EOT

? flagSet(german)

==Tabellen

PerlPoint unterstützt auch einfache Tabellen. Diese sind sind als
eigener Paragraphentyp implementiert. Tabellenparagraphen beginnen mit
dem \BC<@>-Zeichen (Memo: Tabelle ist ein Array von Zeilen), gefolgt vom
Spaltentrennstring.


\B<Beispiel:> (erste Zeile wird als Header formatiert)

<<EOT
 @|
 Spalte 1     |   Spalte 2     |  Spalte 3
   xxxx       |     yyyy       |  zzzzz
   uuuu       |     vvvv       |  wwwww
EOT

Eine weitere Möglichkeit zur Tabellendefinition bieten die
reservierten Tags \B<\\TABLE> und \B<\\END_TABLE>. Hier kann man
mittels der Tag-Optionen weitere Eigenschaften der Tabelle festlegen:

<<EOT
 \TABLE{bgcolor=blue separator="|" border=2}
 \B<Spalte 1>  |  \B<Spalte 2>  | \B<Spalte 3>
  xxxx         |     yyyy       |  zzzzz
  uuuu         |     vvvv       |  wwwww
\END_TABLE
EOT

? flagSet(english)

PerlPoint supports simple tables. They are implemented as a paragraph type
which starts with a \BC<@> character. (Memo: A table is an array of lines).
The string following the \C<@> character is the column separator. The first
line of such a table is automatically formatted as a table headline.

\B<Example:>

<<EOT
 @|
 column 1     |   column 2     |  column 3
   xxxx       |     yyyy       |  zzzzz
   uuuu       |     vvvv       |  wwwww
EOT

As a true Perl tool, \PP offers yet another way to create tables: the \B<\\TABLE> and
\B<\\END_TABLE> tags. This allows better control of table layout
because \B<\\TABLE> (as a tag) accepts options.


<<EOT
 \TABLE{bgcolor=blue separator="|" border=2}
 \B<column 1>  |  \B<column 2>  | \B<column 3>
  xxxx         |     yyyy       |  zzzzz
  uuuu         |     vvvv       |  wwwww
\END_TABLE
EOT


? flagSet(german)

Hier können auch die Überschriften individuell formatiert werden.
Die erlaubten Optionen hängen vom Übersetzungsprogramm ab.

\B<pp2html> erlaubt derzeit folgende Optionen:

* bgcolor=\I<Farbbezeichnung>

* head_bgcolor=\I<Farbbezeichnung>

* border=\I<Randbreite>

* separator=\I<Spalten-Trennzeichen>


Falls diese Möglichkeiten immer noch nicht ausreichen, kann man auch direkt
Text im Zielformat (hier HTML) einbetten, wie im folgenden Abschnitt erläutert.

? flagSet(english)

These tags are sligthly more powerfull than the paragraph syntax because tags can take
\I<options>: you can set up several table features like the border width yourself, and you can
format the headlines as you like.

Here is a list of basically supported tag options (by table):

@|
option            | description
\BC<separator>    | a string separating the table \I<columns> (can contain more than one character)
\BC<rowseparator> | a string separating the table \I<rows> (can contain more than one character)
\BC<gracecr>      | usually set correctly by default, this specifies the number of row separators to be ignored before they are treated as separators - which usually allows to start the table contents in a subsequent line \I<after> the line containing the \C<\\TABLE> tag

More options can be supported by the several converters. \C<pp2html>, for example, currently additionally supports:

@|
option            | description
\BC<bgcolor>      | table background color
\BC<head_bgcolor> | table header background color
\BC<border>       | border width

All enclosed lines in a tag defined table are evaluated as table rows by default, which means that
each source line between \C<\\TABLE> and \C<\\END_TABLE> is treated as a table row. PerlPoint as well allows you to specify a string of your own choice to separate rows by option \C<rowseparator>. This allows to specify a table \I<inlined> into a paragraph.

<<EOE

  \TABLE{bg=blue separator="|" border=2 rowseparator="+++"}
  \B<column 1> | \B<column 2> | \B<column 3> +++ aaaa
  | bbbb | cccc +++ uuuu | vvvv|  wwww \END_TABLE

EOE

This is exactly the same table as above.

To go on further, inlining tables enables us to \I<nest> tables as well. (Due to target format limitations, this feature is not supported by all converters yet. You can try it with \C<pp2html>.)

  \\TABLE{rowseparator="+++"} column 1 | column 2 |
  \B<\\TABLE{rowseparator="%%%"} n1 | n2 %%% n3 | n4 \\END_TABLE>
  +++ xxxx | yyyy | zzzzz +++ uuuu | vvvv | wwwww \\END_TABLE

In \I<all> tables, leading and trailing whitespaces of a cell are automatically removed, so you can use as many of them as you want to improve the readability of your source.

And if all these table features are insufficient still, you can always include pure target format text in your PerlPoint input, let's say HTML for example. See the following chapter about included text.

? flagSet(german)

==Verschachtelte Vorlagen

Mittels \B<\\INCLUDE> Anweisungen kann man vorformatierte Dateien in der
Sprache des Zielformats einbinden oder auch verschachtelte Vorlagen erstellen.


? flagSet(english)

==Included Text

With the help of the \B<\\INCLUDE> tag it is possible to include pre-formatted
text in the format of the target language or to create hierarchical documents.

? 1

\B<Includes:>

<<EOT
 \INCLUDE{type=HTML file=filename}
 \INCLUDE{type=PP file=filename}
 \INCLUDE{type=PP file=filename headlinebase=<number>}
EOT

? flagSet(german)

Im ersten Fall wird die importierte Datei \C<filename> Teil des generierten
Stream-Zwischenformats (siehe \I<\SECTIONREF{name=Vorlagenverarbeitung}>). 
Sie wird vom Parser nicht interpretiert und kann daher
beliebigen Text in der Sprache des Zielformats enthalten.

? flagSet(english)

In the first case the imported file \C<filename> becomes part of the created
intermediate stream format (see \I<\SECTIONREF{name="Parsing the Input"}>).
The file is not parsed and can contain arbitrary code in the format of the
target language (which is HTML in this case).

? flagSet(german)

Im Fall \C<{type=PP}> wird der Datei-Inhalt vom Parser behandelt. So läßt sich
etwa ein größeres Dokument in mehrere Einzeldateien gliedern, die eventuell auch
von verschiedenen Autoren bearbeitet werden können:

<<EOT
 // Verteilte Vorlagen:

 =Einleitung

 \INCLUDE{type=PP file=chapter_01.pp}

 =PerlPoint als Dokumentationssystem

 \INCLUDE{type=PP file=chapter_02.pp}

 =Appendix

 \INCLUDE{type=PP file=appendix.pp}
EOT

? flagSet(english)

If \C<type> is set to \C<PP>, file contents is scanned by the parser. This allows
to split a big document into several parts which can be eventually written by different
authors:


<<EOT
 // distributed document:

 =Intro

 \INCLUDE{type=PP file=chapter_01.pp}

 =PerlPoint as a Documentation System

 \INCLUDE{type=PP file=chapter_02.pp}

 =Appendix

 \INCLUDE{type=PP file=appendix.pp}
EOT

? flagSet(german)

Hier ist oftmals der weiter oben gezeigte \C<headlinebase> Parameter nützlich.
Er sorgt daür, daß allen Überschriften im eingebundenen Teildokument ein
entsprechender Leveloffset zugeschlagen wird. Wenn z.B. \C<headlinebase>
den Wert 2 hat, dann wird \C<=Ein Unterkapitel> als Überschrift der
Ordung 3 interpretiert. Auf diese Weise kann ein Teildokument ohne Änderung
in verschiedenen Hierarchietiefen eines Hauptdokuments verwendet werden.

? flagSet(english)

In this context the \C<headlinebase> parameter shown above can be useful.
It has the effect that each headline of the included document gets an
additional level offset. For example, if the \C<headlinebase> is set to 2, then
\C<=A Subsection> will be interpreted as a header of level 3. This allows to
use an included document on different levels of a main document, without modification.

? flagSet(german)

==Variablen


Variable werden in speziellen Paragraphen deklariert:

 $author=Jochen Stenzel

 $mail=perl\@jochen-stenzel.de

Zu beachten ist, daß vor und nach dem Gleichheitszeichen kein Leerraum steht. Auch sollte man
die Werte der Variablen nicht in Hochkommata einschließen, da der gesamte Text nach dem Gleichheitszeichen
bis zum Zeilenende als Wert der Variablen interpretiert wird!
Jede Variablendeklaration muß durch eine Leerzeile abgeschlossen werden.

Obige Definitionen setzen die Variablen \C<$author> und \C<$mail>. Sie können nun
überall im PerlPoint Eingabetext verwendet werden. Sie werden vom Parser
automatisch durch ihren (String-) Wert ersetzt:

 Der Autor, $author, ist unter folgender Email-Adresse zu
 erreichen: $mail

Alle Variablen werden auch eingebettetem Perlcode und
\SECTIONREF{name=Bedingungen} zur Verfügung gestellt. Dort sind sie
als Package-Variablen von \B<main::> ansprechbar.
Da der Parser bereits versucht, alle Vorkommnisse der
Variablen durch ihren Wert zu ersetzen, muß man Variablen
zumindest in eingebettetem Code unter ihrem voll
qualifizierten Namen ansprechen (\C<$mail::author>), oder man muß
das Dollarzeichen durch Backslash schützen: 

<<EOT
 \EMBED{lang=perl}join(',', $main::author, \$mail)\END_EMBED
EOT

? flagSet(english)

==Variables

\PP provides document variables. Variable definitions are made in a special paragraph type:

 $author=Jochen Stenzel

 $mail=perl\@jochen-stenzel.de

Note that before and after the equal sign there are no blanks. The value of the variable
is not included in quotes because all the text after the equal sign up to the end of the
paragraph defines the value.
Each variable definition must be closed by an empty line (end of paragraph).

The above definition set the variables \C<$author> and \C<$mail>.
From now on, they can be used in the PerlPoint input text. The parser will replace
them automatically by their value:

 The author, $author, can be reached
 under the following mail address:
 $mail

All variables can be used in embedded Perl code and in \SECTIONREF{name=Conditions} as well.
They can be addressed there as package variables of \B<main::>. As the parser tries to
replace all variables by their values, it is necessary to address variables by their fully qualified name (\C<$mail::author>), or you must escape the Dollar sign by a backslash:

<<EOT
 \EMBED{lang=perl}join(',', $main::author, \$mail)\END_EMBED
EOT

? flagSet(german)

==Makros

Oft benötigte Tag-Kombinationen oder mehrfach benutzte Textpassagen lassen sich bequem 
durch Makros abkürzen. Makros sind so eine Art \B<Alias>-Definition.
Solche Makros erlauben es dem Autor einer Präsentation eigene
Abkürzungen zu definieren und diese wie Tags zu verwenden:

<<EOT
 +COPYRIGHT:Copyright (C), Pallhuber und Söhne, 2001, All rights reserved.
EOT

Verwendung des Makros:

<<EOT
 \COPYRIGHT
EOT

Makro Definitionen sind, wie könnte es anders sein, wieder
spezielle Paragraphtypen, die mit einem Pluszeichen beginnen.
Unmittelbar auf das Pluszeichen muß der Alias-Name folgen, ohne
Backslash, worauf wieder unmittelbar ein Doppelpunkt folgt. Der Rest
des Paragraphen ist dann der Ersatztext für die Makrodefinition.

Der Parser ersetzt jedes Auftreten eines Makros durch den
jeweiligen Ersatztext und bearbeitet das Ergebnis von Neuem.
Daher können Makros beliebige Tags oder andere Makros enthalten.
Makros werden genauso wie normale Tags verwendet:

<<EOT
 \MACRONAME{param=value}< this is the macro body >
EOT

? flagSet(english)

==Macros

Often used tag combinations or texts can be abbreviated by macros.
Macros are a kind of alias definitions. They allow a PerlPoint author
to declare his own abbreviations and use them like tags:

<<EOT
 +COPYRIGHT:Copyright (C), Pallhuber and Sons, 2001, All rights reserved.
EOT

Usage of the macro:

<<EOT
 \COPYRIGHT
EOT

Macro definitions are, as you might have guessed, another kind of paragraph. These
macro paragraphs start with a plus sign (\C<"+">). Immediately after the plus sign
the macro name follows, without backslash. Then a colon and the alias text follow.

The parser replaces each occurance of the macro by the alias text. The result is
then reparsed. This allows macros to be nested.

Macros are used like normal tags:

<<EOT
 \MACRONAME{param=value}<this is the macro body>
EOT

? flagSet(german)

Der Ersatztext darf auch Platzhalter der Form "__param__"
enthalten. Diese spezielle Syntax markiert einen Parameter
mit Namen "param". Wenn nun im Ersatztext ein Tag vorkommt, welches
ebenfalls einen Parameter dieses Namens hat, dann wird bei
der Ersetzung der Parameter aus dem Makro an das Tag
weitergereicht. Der spezielle Platzhalter "__body__"
markiert die Stelle, an der der Makrobody platziert werden soll.

Die folgenden Beispiele machen das etwas klarer:

<<EOT
 +RED:\FONT{color=red}<__body__>

 +F:\FONT{color=__c__}<__body__>

 +IB:\B<\I<__body__>>

 Dieser \IB<Text> ist \RED<rot>.

 Tags dürfen in Makros \RED<\I<verschachtelt>> werden. 
 Und \I<\F{c=blue}<umgekehrt>>.

 \IB<\RED<Dies>> ist durch ein verschachteltes Makro formatiert.

 +TEXT:Makros können dazu verwendet werden,
 längere Textpassagen oder auch Tag-Kombinationen abzukürzen.
EOT

? flagSet(english)

The alias text may contain place holders of the form \C<"__param__">.
This special syntax defines a parameter with name \C<"param">. If the
alias text contains a tag which also has a parameter with name \C<"param">,
then this parameter is passed from the tag to the macro while the
macro is replaced by its alias text. The special place holder \C<"__body__">
marks the place where the macro body should be placed.

The following examples should make this clearer:

<<EOT
 +RED:\FONT{color=red}<__body__>

 +F:\FONT{color=__c__}<__body__>

 +IB:\B<\I<__body__>>

 This \IB<text> is \RED<red>.

 Tags may be \RED<\I<embedded>> into makros.
 And \I<\F{c=blue}<vice versa>>.

 \IB<\RED<This>> is formated by a combined macro.

 +TEXT:Macros can be used to abbreviate
 longet texts.
EOT



? flagSet(german)

Nach dem Auflösen der Makros sieht der Parser im obigen Beispiel den folgenden Text:

<<EOT
 Dieser \B<\I<Text>> ist \FONT{color=red}<rot>

 Tags dürfen in Makros \FONT{color=red}<\I<verschachtelt>> werden.
 Und \I<\FONT{color=blue}<umgekehrt>>.
EOT

Das folgende Beispiel bezieht sich bereits auf den Absatz \I<\SECTIONREF{name="Eingebetteter Code"}>:

<<EOT

 +HTML:\EMBED{lang=HTML}

 \HTML Dies ist <i>eingebettetes HTML</i>\END_EMBED.

 Beachte: \TEXT
EOT

Eine leere Makrodefinition hebt die Definition wieder auf:

<<EOT
 // undeclare the IB alias
 +IB:
EOT

? flagSet(english)

After replacing all macros the parser sees the following text:

<<EOT
 This \B<\I<text>> is \FONT{color=red}<red>

 Tags may be \FONT{color=red}<\I<embeded>> in macros.
 And \I<\FONT{color=blue}<vice versa>>.
EOT

The following example refers to the chapter \I<\SECTIONREF{name="Embedded Code"}>:

<<EOT

 +HTML:\EMBED{lang=HTML}

 \HTML This is <i>embedded HTML</i>\END_EMBED.

 Note: \TEXT
EOT

An empty macro definition deletes the macro:

<<EOT
 // undeclare the IB alias
 +IB:
EOT



? flagSet(german)


==Dynamische Inhalte

// an geeigneter Stelle einbauen: Filter, Propagieren von Variablen, 
// Benutzersteuerung, Sicherheit (und Schwierigkeiten) mit Safe, ...

PerlPoint erlaubt die Verwendung von Bedingungen und das Einbetten von
Perlcode in die Vorlagendatei.
Voraussetzung ist, daß dynamische Inhalte im Parser aktiviert werden.

Dies ist nicht automatisch der Fall. Ein PerlPoint-Übersetzungsprogramm
(siehe \I<\SECTIONREF{name="Ein modulares Konzept"}>) muß dies explizit
anfordern, indem es den Parser mit speziellen Parametern aufruft:

? flagSet(english)


==Dynamic Contents

PerlPoint allows to use conditions and to embed Perl code.

This is not the default. A \PP converter must activate dynamical contents by calling the parser with a special option for reasons of security.

? 1

 \B<use Safe;>
 use PerlPoint::Backend;
 use PerlPoint::Constants;
 use PerlPoint::Parser 0.34;

 # build parser
 my ($parser)=new PerlPoint::Parser;

 # and call it
 $parser->run(
              stream  =\> \\@streamData,
              files   =\> \\@ARGV,
              \B<safe    =\> new Safe,>
              ...
            );

? flagSet(german)

Die dynamischen Inhalte werden aktiviert, indem man dem Parser beim Aufruf ein \B<Safe>-Objekt
übergibt.

Eingebetteter Perlcode wird in der \B<Safe>-Umgebung ausgeführt. Beim \B<Safe>-Objekt
kann über \I<opcodes> genau gesteuert werden, welche Art von Operationen in 
der \B<Safe>-Umgebung erlaubt sind. 
Siehe dazu die Dokumentation des \B<Safe>-Moduls.
Im Fall von \B<pp2html>, \B<pp2latex> und \B<pp2sdf> steht dem Anwender zu diesem Zweck der \C<--safeOpcodes>
Schalter zur Verfügung. 

Weitere Informationen zum Parser finden sich im 
Kapitel \I<\SECTIONREF{name=Vorlagenverarbeitung}>. 

? flagSet(english)

Dynamical (or "active") contents is activated by passing a \B<Safe>-Object to the parser.

Embedded Perl code is usually evaluated in a \BC<Safe> compartment. This way it is possible to control which kind of operations are allowed by configuring \C<Safe> object for accepted opcodes. (See the documentation of the \C<Safe> and \C<Opcode> modules for further details.) In \C<pp2html> , \C<pp2latex> and \C<pp2sdf> there is a \C<-safeOpcodes> option which allows to specify these codes.

Using \C<Safe> enables a \PP user to control the behaviour of Active Contents (possibly written by unknown persons) very fine grained. But using this implementation in reality we recognized that dealing with \C<Safe> is not always sufficient because it is hard to load arbitrary modules in a compartment or even to execute \C<sort()> with own handlers. (At least we found no way to do it ...) So, to work around this, we finally enabled to specify the "opcode" ALL to bypass \C<Safe> completely. Instead of invoking \C<Safe>, embedded Perl code will then be evaluated by \C<eval()> in the users (probably unsafe) environment.

? flagSet(german)

===Bedingungen

Manchmal möchte man bestimmte Textabschnitte von Bedingungen abhängig machen.
Wenn man z.B. Schulungsunterlagen mit Übungsbeispielen vorbereitet, kann man die
Lösungen der Übungsaufgaben je nach Bedarf ein- oder  ausblenden. Durch Definition eines
Flags kann man dann einmal eine Version ohne Lösungen erzeugen und nach Änderung der
Definition eine Version mit Lösungen.

Auch zweisprachige Versionen eines Dokuments lassen sich auf diese Weise einfach pflegen:

 ? $language eq 'German'

 Dieser Abschnitt erscheint nur in der deutschen Version.

 ? $language eq 'English'

 This section is for the English version only.

 ? 1

 This is common for all versions of my document!

? flagSet(english)

===Conditions

Sometimes it is useful to include a certain part of your input text only under certain
conditions. For example in training material you may include the solutions in the trainer
version but hide them in the version presented to the trainees or via intranet.
Conditions allow you to do that. You simply pass a flag to the converter and then use
conditions of the form

 ? flagSet(flagname)

 This text appears only if the flag \I<flagname> is set.

 ? 1

 This text appears in every version of this document.

In the above example we used the built-in PerlPoint function \C<flagSet> to check if the
condition has been set. The condtion itself is set while calling the converter program: use
the \C<--set> option:

  pp2html --set flagname input.pp

? flagSet(german)

Eine Bedingung ist ein spezieller Steuerparagraph, der mit einem Fragezeichen
eingeleitet wird. Danach kann ein beliebiger Perl-Ausdruck stehen. Wenn dieser Ausdruck
einen wahren Wert liefert, wird alles folgende in die Ausgabe übernommen.

Die Bedingung \B<? 1> ist immer wahr. Damit kann man einen bedingten Abschnitt beenden
und dafür sorgen, daß alles weitere in jedem Fall bearbeitet wird.

Ab der Version 0.29 des Parser-Moduls kann man
dem Parser beim Aufruf ein Hash mit Usersettings übergeben. Dieses ist in
eingebettetem Perlcode über die globale Hashreferenz \C<$PerlPoint> zugänglich.

? flagSet(english)

Conditions are special control paragraphs and start with a question mark.
After the question mark arbitrary Perl code can be placed. The value returned by that code
is evaluated to decide if the condition is true or not, according to Perls definition of truth.
In the example above, we used a function (\C<flagSet()>) and a constant (\C<1>, which is always true) as conditions.

The builtin \C<flagSet()> function checks a Perl structure which is passed to the condition code
and can be accessed directly as well. So, to check if a certain flag was set, you could write

<<EOT
 ? exists $PerlPoint->{userSettings}{flagname}
EOT

and this would do exactly the same as

<<EOT
 ? flagSet(flagname)
EOT

However, \C<flagSet()> is easier to use (and does the same thing :-), so we invited it to
simplify condition writing.

Building conditions on base of user settings makes it possible to control the result of document
converting without changes of the document source, making it easy to use one source for several
purposes. But because conditions are written in Perl, they can be as complex as necessary to
include source parts depending on system states, database data or whatever can be checked by Perl.


? flagSet(german)

Bedingungen lassen sich dann in folgender Form schreiben:

<<EOT
 ? exists $PerlPoint->{userSettings}{German}
EOT

Damit braucht man in der Vorlage keine Variablen mehr zu ändern, wenn man die
Bedingungen umsteuern will. Voraussetzung ist allerdings, daß das jeweilige
Übersetzungsprogramm diese Usersettings unterstützt und entsprechende Optionen
dafür anbietet.

===Eingebetteter Code

\A{name=embed}

Text im Zielformat muß nicht unbedingt per \C<\\INCLUDE> importiert
werden. Man kann ihn auch direkt einbetten:

\B<Embedded HTML:>

<<EOT
 \EMBED{lang=HTML}
 Zielcode. Hier ist die Tagerkennung (bis auf "\END_EMBED") abgeschaltet.
 \END_EMBED
EOT

Da dies durch Tags und nicht über Paragraphen gesteuert wird, kann der
eingebettete Code überall stehen:

<<EOT
 Dieser Abschnitt \EMBED{lang=HTML}<I>in Kursivschrift</I>\END_EMBED 
 wird durch eingebetteten HTML-Code erzeugt.
EOT

? flagSet(english)


===Embedded Code

Input text can be included by the \C<\\INCLUDE> tag as mentioned before, but there is another possiblity as well - it can be embedded directly.

\B<Embedded HTML:>

<<EOT
 \EMBED{lang=HTML}
 Target Code. Taag recognition is suspended until \\END_EMBED.
 \END_EMBED
EOT

As this is controlled by tags and not by control paragraphs, you may embed code in any place:

<<EOT
 This chapter with some words in\EMBED{lang=HTML}<I>intalics</I>\END_EMBED
 is created with ebmedded HTML Code.
EOT


? flagSet(german)

Zu beachten: \\EMBED erlaubt keinen Tag-Body, damit keine Mehrdeutigkeiten entstehen können.


\B<Filter:>

Ein PerlPoint-Übersetzungsprogramm kann beim Parseraufruf auch einen \I<Filter> setzen. Dann werden
nur solche \\INCLUDE- oder \\EMBED-Tags behandelt, bei denen
der Wert des \I<lang>-Parameters vom Filterausdruck erfaßt wird:

? flagSet(english)

Note: \\EMBED does not allow a tag body. This avoids ambigouities.

\B<Filter:>

A \PP converter can set a \I<filter> while calling the \PP parser. Then only those \\INCLUDE
and \\EMBED tags are parsed whose \I<lang> parameter matches the filter expression:

? 1

 $parser->run(
              ...
              \B<filter  =\> 'HTML',>
             );
                         
? flagSet(german)

Der Wert des \C<filter>-Parameters ist ein regulärer Ausdruck,
der caseinsensitiv ausgewertet wird. Üblicherweise stellt ein Übersetzungsprogramm die
Option \C<--filter> zur Verfügung, um diesen Wert für den Benutzer einstellbar zu machen.

\B<Embedded Perl:>

Im Gegensatz zu sonstigem eingebettetem Code wird Perlcode vom Parser \I<ausgeführt>,
sofern dynamische Inhalte aktiviert wurden. Die Ausgabe des Perlcodes 
wird als PerlPoint geparst (siehe \I<\SECTIONREF{name=Vorlagenverarbeitung}>). 

Das folgende Beispiel ermittelt Datum und Uhrzeit und
setzt sie in den Hinweis auf das Erstellungsdatum der
Präsentation ein:

? flagSet(english)

The value of the filter parameter is a regular expression, which is evaluated case insensitively.
Each \PP converter program should provide the \C<--filter> switch which allows to set the
filter expression.

\B<Embedded Perl:>

In contrary to other embedded Code, Perl code is \I<evaluated> by the parser (if
Active Contents is allowed). The output of the Perl code is parsed as PerlPoint text and
the result is passed to the intermediate stream format.

The following example includes the current date and time in your input file:

? 1

<<EOT
 \EMBED{lang=perl}

 # get date
 my ($min, $hour, $day, $month, $year)=(localtime)[1..5];
 $month++;
 $year+=1900;

 join('',
     '\EMBED{lang=html}',
     '<p align=center>',
     "Version vom $day.$month.$year, $hour:$min.",
     '</p>',
     # split up the end tag to avoid early evaluation by PP::Parser
     '\END', '_EMBED',
     );

 \END_EMBED
EOT

? flagSet(german)

Änderungen an Variablen in eingebettetem oder includiertem Perl
betreffen nicht die Variablen, die der Parser sieht. (Das gilt auch
für Bedingungen.)

? flagSet(english)

Changes to variables in embedded or included Perl do not affect the variables
which are seen by the parser. (This is also true for conditions.)

? 1

<<EOT
 $var=10
 \EMBED{lang=perl}$main::var*=2;\END_EMBED
EOT

? flagSet(german)

Dies bewirkt, daß $var für den Parser und für den
weiteren eingebetteten Code unterschiedliche Werte hat. Der Parser wird weiterhin
den Wert 10 benutzen, während der Code den Wert 20 verwendet.

? flagSet(english)

This has the effect that $var has different values with respect to the parser and to
embedded Perl code. The parser always sees the value 10, but embedded Perl deals
with a value of 20.


