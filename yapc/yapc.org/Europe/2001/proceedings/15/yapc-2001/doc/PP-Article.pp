// vim: set filetype=pp2html :

+PP:PerlPoint

+IB:\I<\B<__body__>>

+BC:\B<\C<__body__>>

? flagSet(html)

? flagSet(english)

=PerlPoint

\EMBED{lang=html}

<HR>
<PRE>



</PRE>

<FONT SIZE=+6>
 <CENTER>
 <STRONG>PerlPoint: Present and Document with Perl</STRONG>


</FONT>

<PRE>


</PRE>

<FONT SIZE=+2>
<STRONG>Contribution to YAPC::Europe, August 2001</STRONG>

<PRE>



</PRE>

<P>
Jochen Stenzel, <I>perl@jochen-stenzel.de</I>
</P>

<P>
Lorenz Domke, <I>lorenz.domke@gmx.de</I>
</P>
</FONT>

<HR>
<P>
Copyright  &copy; Jochen Stenzel, Lorenz Domke 2001

<P>
 This article is essentially a translation of the article which has
 previously been published for the Third German Perl-Workshop 2001.
 </CENTER>
\END_EMBED

? 1

=Introduction

? flagSet(german)

Wer das Vergnügen hat, eine Präsentation vorbereiten zu müssen, denkt dabei 
schnell an Programme wie PowerPoint, StarImpress oder Harvard Graphics. Sie 
bieten wirkungsvolle optische Effekte, liefern professionell wirkende Vorlagen, 
unterstützen die Ausarbeitung mit Assistenten und graphischen Werkzeugen und 
sind noch dazu oft in verbreitete Office-Pakete eingebunden.

? flagSet(english)

If you are about to prepare a presentation you will probably consider
programs like PowerPoint, StarImpress or Harvard Graphics. They offer cool
optical effects, provide professional templates and support you with graphical
tools and \I<wizzards>. And they are often included into common office suites.

? flagSet(german)

Kehrseite der Medaille sind jedoch nicht selten umfangreiche Installationen, 
eine gewisse Größe und Schwerfälligkeit der Software und die mangelnde 
Portierbarkeit der proprietären Formate - die erzeugten Präsentationen lassen 
sich nur in entsprechenden "Projektoren" zum Leben erwecken. Selbst wenn die 
Projektionssoftware kostenlos weitergegeben werden darf, so ist sie doch 
zunächst zu installieren und läuft auch nicht immer auf allen Plattformen. 
Sollen Folien allgemein zur Verfügung gestellt werden, bleibt oft nur der 
Export in Grafiken - Bitmap-Präsentationen im Internet sprechen hier eine 
deutliche Sprache. Sollen mehrere Personen eine Präsentation zusammen 
erarbeiten, müssen sie zwingend dieselbe Software verwenden. Wer dazu gerne 
Open Source Software einsetzt, wird wohl erst in einiger Zeit mit der 
Präsentationskomponente aus Open Office in den Genuß eines entsprechenden 
Programmes kommen.

? flagSet(english)

On the other hand this kind of programs often requires to install large packages,
and the software itself is usually really big not very portable. Presentations made
this way depend on corresponding projectors (i. e. PowerPoint or StarOffice). Even if the
projector software can be freely \I<distributed>, it may not \I<run> on every platform
and you have to install it first. If you want to work platform independently, often the only
solution is to make bitmap graphics from your slides, which consume a lot
of space and (download) time. If several persons want to prepare a presentation
or write a document \I<together>, all of them are in need of the \I<same> software. And if
you like to use Open Source programs there are not that many alternatives yet.

? flagSet(german)

Gerade der Open-Source-Aspekt stieß Tom Christiansen bereits vor einigen Jahren 
auf, als er die zunehmende Verbreitung von PowerPoint-Präsentationen auf 
Open-Source-Kongressen bemerkte. Als Ergebnis seiner Überlegungen entwarf er 
ein neues, einfaches \I<Text>format, aus dem sich mit einem Perlscript auf 
einfache Weise Webseiten generieren ließen, und nannte es \B<\PP>. Die 
Wahl von HTML als Präsentationsformat garantierte, daß die erzeugten 
Präsentationen auf nahezu jedem Rechner sofort und ohne spezielle 
Softwareinstallationen lauffähig waren, ganz unabhängig vom verwendeten 
Betriebssystem. Darüber hinaus ließen sie sich jederzeit unverändert im Web 
(oder Intranet) publizieren. Auch das Verfassen einer Präsentation wurde 
drastisch vereinfacht: jeder beliebige Texteditor reichte dafür aus.

? flagSet(english)

It was this Open Source aspect especially which brought \I<Tom Cristiansen> to invent
\PP several years ago. He noticed that more and more PowerPoint talks were
presented on Open Source conferences. So he created a simple \I<text> format
which could be transformed to HTML pages by a little Perl script. He called it
\IB<\PP>. The choice of HTML as a presentation format had the big advantage
that \PP presentations could be shown on \I<every platform>, without any system
specific adaptations. All you needed was a web browser, nothing more! The
presentations could be instantly published in the Internet or in an intranet as well.
\I<Authoring> presentations was very simple, too: each text editor could be used for that.

? flagSet(german)

Toms Idee faszinierte uns sofort, und wir begannen umfangreiche Dokumentationen 
in \PP zu schreiben. Sehr schnell entstanden dabei auch Wünsche nach 
speziellen Erweiterungen. Lorenz begann \PP stark auszubauen. Das immer 
weiter aufgebohrte und umgeschriebene Originalscript \C<pp2html> erreichte 
allerdings schließlich einen Stand, in dem ein Redesign angezeigt erschien. 
Gleichzeitig beschäftigten wir uns angesichts des aufkommenden XML mit der 
Idee, \PP so flexibel zu machen, daß die Beschränkung auf HTML als 
Präsentationsformat aufgehoben wäre und \I<beliebige> Zielformate erzeugt 
werden könnten. Nach dem Zweiten Deutschen Perl-Workshop arbeiteten wir dann 
verstärkt an einer entsprechenden Implementierung, die hier vorgestellt werden 
soll.

? flagSet(english)

Tom's idea fascinated us at once and we started to write large documents in \PP
(not only presentations!). Soon we had requests for more features and more flexibility.
Lorenz started to enhance \PP essentially. The formerly simple \I<pp2html> script grew more and
more, and at a certain point, we decided to redesign it completely. Jochen had the idea to base
the new design on a common parser which should read \PP source files and provide an intermediate stream format. The stream could then be translated to arbitrary target formats like HTML, SDF or XML. It would be a modular concept with one frontend (parser) and several backends (converters).
After the Second German Perl Workshop, we started this new implementation which shall be
presented in this article.


? flagSet(german)

=Ein Überblick über die Sprache

Zusammen mit \I<Stephen Riehm> definierten wir eine stark erweiterte, neue 
Syntax, die aber möglichst weit an das Original angelehnt wurde. \PP war 
schon immer sehr leicht verständlich, und nach wie vor ist es äußerst einfach, 
Vorlagen in \PP zu verfassen und zu verstehen. Man kann einfach 
"draufloschreiben":

 Dieses Beispiel zeigt einen gültigen Eingabetext.

Umlaute und andere "Sonderzeichen" bedürfen dabei keiner besonderen 
Schreibweise. Wenn eine Zielsprache sie nicht direkt darstellen kann, sorgt der 
entsprechende Übersetzer für die Übertragung in eine spezielle Darstellung (wie 
\C<&uuml;> in HTML). Diese Eigenschaft sorgt für flüssiges Schreiben und 
vereinfacht auch das Kopieren von Texten aus anderen Formaten.

Ähnlich HTML spielen Zeilenumbrüche innerhalb eines Textes keine Rolle. 
\PP ist \B<paragraphenorientiert> und faßt alle Zeilen innerhalb eines 
Textparagraphen so zusammen, als wären sie in einer einzigen langen Zeile 
eingegeben worden. Eingeschlossene Zeilenumbrüche werden durch ein Leerzeichen 
ersetzt.

? flagSet(english)

=Language Overview

Together with \I<Stephen Riehm> we defined the new enhanced syntax for \PP. It was based
on the original syntax by Tom Christiansen but slightly modified to meet our additional needs.
Nevertheless, \PP is still a simple language, and it is easy to write \PP input files.
Just start to write:

 This examples shows valid \PP input text.

German \I<umlauts> and other special characters can be used freely. When the target language
does not support theses characters directly, the corresponding converter will handle this
for you and translate them to special notations like \C<&uuml;> in HTML. This feature 
simplifies writing and allows copying texts from other formats.

Similar to HTML, line breaks within a text have no effect. \PP is \B<paragraph oriented>.
All lines within the same paragraph are combined as if they had been written as one long line.


? flagSet(german)

Ein Paragraph wird grundsätzlich durch mindestens eine Leerzeile abgeschlossen:

 Hier beginnt der Text.
 Und er setzt sich fort.

 Ein neuer Absatz.

Natürlich besteht ein Dokument nicht nur aus Textabschnitten. \PP bietet 
darum weitere \I<Paragraphentypen> an. Jeder Typ ist durch einen speziellen 
Beginn gekennzeichnet - die häufig benötigten \B<Überschriften> beginnen 
beispielweise mit (mindestens einem) Gleichheitszeichen.

 \B<=>Ein neues Kapitel

? flagSet(english)

Each paragraph is terminated by at least one empty line:

  Here a paragraph begins.
  This line is part of the first paragraph as well.

  This is a new paragraph.

Of course, a document seldomly contains text paragraphs only. \PP therefore
offers various other paragraph types. The first character of a paragraph flags which
type of paragraph it is. \B<Headlines>, for example, start with (at least) one equality sign (\C<=>).

 \B<=>A New Chapter


? flagSet(german)

Auch hier sorgt die folgende Leerzeile für den Abschluß des Paragraphen - wird 
eine Überschrift sehr lang, kann man sie zur besseren Lesbarkeit im Editor also 
durchaus umbrechen.

 =Es dürfte schwerfallen,
 den Text dieser Überschrift
 in einer einzigen Taschenbuchzeile
 zu drucken

? flagSet(english)

The following empty line terminates the headline paragraph. If a headline is
very long, it may be continued in the next source lines:

 =It should be difficult to
 print the text of this headline
 in one single line of a small
 paperback booklet

? flagSet(german)


Häufiger als derart lange Überschriften sind jedoch zweifellos Unterkapitel 
anzutreffen. In \PP bestimmt die Anzahl der einleitenden 
Gleichheitszeichen, auf welcher Ebene eine Überschrift ausgegeben werden soll - 
die Numerierung wird automatisch vorgenommen.

 \B<=>Titel

 \B<==>Unterkapitel 1

 \B<==>Unterkapitel 2

 \B<===>verzweigt sich noch weiter

 \B<=>Anhang

Bei der Umsetzung wird jede dieser Überschriften dann zum Titel einer Folie.

? flagSet(english)

More often than such long headlines you will need \I<subsection> headlines.
\PP allows to specify the level of a headline by multiple equality signs
at the beginning of a headline:

 \B<=>Title

 \B<==>Subsection 1

 \B<==>Subsection 2

 \B<===>Let's look at details

 \B<=>Appendix

Each headline starts a new slide, and the headline is printed on top of this
slide.
 

? flagSet(german)

Einzelne Aussagen einer Präsentation werden gerne in Punkten vorgestellt, die 
mitunter durchaus nur Stichwörter enthalten - sie fallen dem Zuhörer ins Auge 
und gliedern den dargebotenen Stoff optisch, so daß er viel leichter erfaßbar 
ist als ein langer Textabsatz. In der \PP-Vorlage kennzeichnet man einen 
solchen \B<Punkt> mit einem \I<Stern>:

 \B<*> "Punkt" oder "Anstrich"

 \B<*> leicht erfaßbar

 \B<*> Vorlage ähnelt optisch dem Ergebnis

? flagSet(english)

Single statements are often presented as \B<bullet items>: They contain very little
text, catch the eye and provide a short summary of the presented contents.
This is easier to read than a long text paragraph.

\PP marks such bullets by an asterisk:

 \B<*> "Bullet"

 \B<*> easy to read

 \B<*> \PP input is similar to the result


? flagSet(german)


Eine solche Aufzählung könnte durchaus auch als "ungeordnete Liste" verstanden 
werden (tatsächlich ist das die Konstruktion, die \B<pp2html> zur Umsetzung 
benutzt). Ehe die Fragen nach \I<geordneten> Listen zu laut werden, stelle ich 
sie gleich mit vor:

 \B<#> erst 1

 \B<#> dann zwei

\B<Aufzählungsparagraphen> beginnen also mit dem Hash-Zeichen ("#"). Wir haben 
uns für dieses Zeichen entschieden, weil es oft als Symbol für "Zahl" verwendet 
wird - die Bedeutung im Vorlagentext läßt sich hier (von entsprechend 
vorbelasteten Lesern) wieder intuitiv erfassen.

? flagSet(english)

Such a bunch of bullet items is nothing more than an \B<unordered list> (which
is actually translated into an HTML \C<<UL\>> construction by \C<pp2html>).
And of course, there are numbered lists as well:

 \B<#> first item

 \B<#> and second item

\B<Numbered list> point paragraphs start with a hash sign ("#"). We decided
to use this character because it is often used for numbers. Readers familiar
with this meaning will find writing and reading of such paragraphs intuitive.


? flagSet(german)

Obwohl der Platz auf einer Präsentationsfolie meist recht begrenzt ist, wünscht 
man sich doch vielleicht manchmal die Möglichkeit, auch Listen hierarchisch 
gliedern zu können, um einen Gedanken detaillierter zu erläutern. \PP 
stellt dafür einen speziellen Paragraphentyp ("\B<Shift>") bereit, der zwischen 
einzelnen Listenpunkten platziert werden kann und die Ebene einer Liste ändert.

 # Beginn

 \B<\>>

 # vor allem anderen

 # ganz vorne

 \B<<>

 # Abschluß

? flagSet(english)

Sometimes it is useful to have hierarchical lists: one top level list
containing some sub-lists. \PP offers \B<shift> paragraphs to
achieve this. Shift paragraphs can be placed between normal list
paragraphs and modify the level of subsequent list parts:

 # Begin

 \B<\>>

 # Level 2, no. one

 # Level 2, no. two

 \B<<>

 # Conclusion


? flagSet(german)

Leider ist die Vorlage hier nicht mehr hundertprozentig intuitiv: die 
hierarchische Listenstruktur läßt sich beim Blick auf den Text bestenfalls 
erahnen. Man hätte sich vielleicht gewünscht, die untergeordneten Ebenen 
eingerückt darzustellen, aber auch Einrückungen sind Einleitungen für einen 
speziellen Paragraphentyp - der noch dazu wesentlich häufiger auftritt als 
verschachtelte Listen: in Anlehnung an \I<POD> wird \B<Beispielcode> in die 
Vorlage eingefügt, indem man dessen erste Zeile einrückt.

 Ein kleines Beispiel verdeutlich das.

   @sorted=sort byNumber (@array);

   sub byNumber
    {
     ...
    }

? flagSet(english)

Perhaps you might think that this is not very intuitive. It would be nicer to
indicate sublevel lists by indentation. But indentation is reserved for another
important paragraph type: \B<example code>. This is similar to POD. If you want to
include a code example in your presentation, you just copy it to your \PP
file and indent it with one ore more spaces. It is sufficient to indent the first
line (because this determines the paragraph type) but usually you will use the same
indentation for all lines of your example block.

 A little example makes this clear:

   @sorted=sort byNumber (@array);

   sub byNumber
    {
     ...
    }


? flagSet(german)

Üblicherweise behält man die Initialeinrückung für das gesamte Beispiel bei. 
Zeilenumbrüche bleiben - anders als in Textabschnitten - erhalten. Das gilt 
auch für die Leerzeilen. Obwohl sie wie üblich dem Abschluß des Paragraphen 
dienen, werden sie jedoch automatisch als Teil des Beispiels interpretiert, 
sobald unmittelbar darauf ein weiterer Beispielparagraph folgt. \PP faßt 
aufeinanderfolgende Beispielabsätze also automatisch zusammen, um die 
Handhabung so weit wie möglich zu vereinfachen. Auf diese Weise ist es möglich, 
Code mit minimaler Nachbearbeitung direkt aus einem Script in die Vorlage zu 
übernehmen. Bei Bedarf lassen sich benachbarte Beispiele aber auch trennen:

 sort() kann auf verschiedene Arten
 aufgerufen werden:

   @sorted=sort(@array);

 \B<->

   @sorted=sort byFunction @array;

 \B<->

   @sorted=sort {$a<=>$b} @array;

? flagSet(english)

Normally, empty lines terminate a paragraph. However, in code examples,
consecutive blocks are combined to form one big example block. Only another
paragraph type like bullets or headlines terminate the example.

But if you insist to separate example blocks you can use a special
paragraph type to enforce this. This \B<control paragraph> contains nothing
but a minus sign (\C<"-">):

 sort() can be called in different ways:

   @sorted=sort(@array);

 \B<->

   @sorted=sort byFunction @array;

 \B<->

   @sorted=sort {$a<=>$b} @array;


? flagSet(german)

Der aus einem einfachen Bindestrich bestehende \I<Steuerparagraph> macht dem 
Leser und \PP hier gleichermaßen deutlich, daß jedes Beispiel für sich 
behandelt werden soll. (Die Bindestriche gehen nicht in das 
Übersetzungsergebnis ein.)

? flagSet(english)

This minus sign paragraph indicates to \PP (and to the human reader) that
examples have to be separated. The \C<-> characterwill not be made part of
the result.

? flagSet(german)

Alternativ zu Einrückungen kann man auch \I<Here Documents> verwenden, um 
Beispiele einzufügen.

 <<EOE

 In diesem Beispiel muß man keinerlei
 Rücksicht mehr auf \PP nehmen.
 Der Text oder Code läßt sich 1:1 aus
 anderen Quellen kopieren.

 EOE   

Im Gegensatz zu eingerückten Beispielen werden solche \B<verbatim blocks> nicht 
nach weiteren \PP-Elementen durchsucht. Wir kommen später darauf zurück, 
wenn diese Elemente vorgestellt werden.

? flagSet(english)

Alternatively to indented example blocks, you can also use \B<verbatim blocks>:

 <<EOE

 In this example you need not to deal with
 \PP syntax. This text is printed
 "as is" (without regarding tags etc.)
 You may copy it 1:1 from another source.

 EOE   

In contrary to indented example blocks, such verbatim blocks are not searched for
\PP tags (see below).


? flagSet(german)

In der Liste der Basissprachmittel fehlen jetzt nur noch \B<Kommentare>. Auch 
sie sind ein spezieller Absatztyp. Da das in Perl und vielen Unix-Utilities 
eingesetzte \C<#> bereits für geordnete Listen vergeben war, haben wir uns für 
die C++-Lösung entschieden: Kommentare beginnen mit doppelten Slashes.

 // hier könnte man noch
 // über andere Dinge sprechen

Um Vorlagen lesbar zu halten, wurde für Kommentare eine Sonderregelung 
eingeführt: sie werden immer mit dem Ende der Zeile abgeschlossen - man braucht 
also keine zusätzliche Leerzeile.

Titel, Texte, Anstriche, Listen, Beispiele und Kommentare bilden den 
\PP-Grundwortschatz. Er ist einfach, übersichtlich, in wenigen Minuten 
erlernbar und bewußt auf die in Präsentationen üblichen Darstellungslemente 
ausgerichtet. Man kann sofort "loslegen".

? flagSet(english)

In our list of basic \PP elements there is only one thing missing: \B<comments>.
Of course they are also represented by a special paragraph type. These comment
paragraphs start with two slashes: ("//"). The hash sign was already used for numbered lists,
so we decided to introduce the C++ solution for comments.

  // some hints for the printed version 
  // ....

To make the \PP input more readable, comments need no subsequent empty line to be
terminated. Each comment is automatically terminated with the end of its line.

Headlines, texts, bullet items, numbered lists, examples and comments are the \I<basic
vocabulary> of \PP. It is easy to learn and you can start at once to write simple
presentations.



? flagSet(german)

=Erweiterte Sprachmittel

\INCLUDE{file="extended.pp" type=pp}

? flagSet(english)

=Extended PerlPoint Language

\INCLUDE{file="extended.pp" type=pp}



? flagSet(german)

=Die interne Architektur

Während sich \PP dem Anwender als "ganz normaler" Text präsentiert, den 
man lediglich nach ein paar einfachen Regeln strukturieren muß, ist es aus 
interner Sicht eine \I<Programmiersprache>, die dem Anwender so viele 
Freiheiten läßt, daß er das gar nicht bemerkt. Diese Sprache muß analysiert, 
der gewonnene Inhalt geeignet strukturiert und schließlich mit den Mitteln der 
Zielsprache (HTML, TeX, ...) wieder ausgedrückt werden. Ein 
\PP-Übersetzer ist in diesem Sinne also ein Compiler, und im Compilerbau 
werden (u.a.) tatsächlich die Phasen der Analyse, der Zwischencodeerzeugung und 
der Codegenerierung unterschieden. Während einfache Filter die einzelnen 
Schritte ohne weiteres gemeinsam implementieren können, bietet es sich bei 
komplexeren Übersetzern an, die entsprechenden Aufgaben von spezialisierten 
Modulen ausführen zu lassen, die dann geeignet zusammenarbeiten. Dieses Modell 
findet bei vielen Compilern Anwendung und erschien auch für \PP geeignet.

? flagSet(english)

=Internal Architecture

For the user, \PP looks like normal text which must be structured according
to some simple rules. But internally it is a kind of \I<programming language> (which
offers the power of Perl, see below)! This language must be analyzed, the contents must be structured
and finally expressed with the means of the target language (e. g. HTML or LaTeX).
In this meaning, a \PP converter is a kind of compiler. We have the phases of lexial
analysis, generation of intermediate code and finally code generation. A simple filter
can combine all theses steps but this is not very flexible. Therefore we decided to use
a modular concept by separating theses steps into dedicated modules.


? flagSet(german)

==Ein modulares Konzept

Die \PP-Scripts der ersten Generation waren durchweg monolithisch 
aufgebaut, der Code für Analyse und Generierung war also ineinander verwoben. 
Das funktionierte zwar gut, es wurde mit zunehmender Weiterentwicklung aber 
schwieriger, diesen Code zu pflegen und weiterzuentwickeln. Darüber hinaus 
hätte man für jeden neuen Übersetzer wesentliche Teile herauslösen und kopieren 
müssen. Die bereits angedeutete Modularisierung des Neuentwurfes schaffte hier 
Abhilfe.

\IMAGE{src="../images/PerlPoint-Structure3.gif" epsfxsize=14cm}

Grundlage aller Übersetzer ist das für die Analyse zuständige Parsermodul 
\B<PerlPoint::Parser>, das die übergebene Vorlage auf Fehlerfreiheit 
untersucht, in ihre Bestandteile zerlegt und das Ergebnis in einem 
Zwischenformat (Stream) bereitstellt. \B<PerlPoint::Backend> ist auf das vom 
Parser erzeugte Streamformat spezialisiert und kann einem Übersetzer als Basis 
für die Generierung des jeweiligen Präsentationsformats dienen.

? flagSet(english)

==A Modular Concept

The \PP scripts of the first generation were monolithic, performing all parts of source
translation by one code. This worked well, but with increasing complexity it became
more and more difficult to maintain the code. To write another converter
for another target language, we would have had to extract large parts of the
code and adapt it to a new program. An enhancements after that would have had to
be integrated in many different places. Modularisation helped us out of this situation:

\IMAGE{src="../images/PerlPoint-Structure3.gif" epsfxsize=14cm}

The basic module underlying all converters is the parser module
\BC<PerlPoint::Parser>. The parser scans the passed \PP source, validates it
and splits it into its components. The result is an intermediate stream format.
The \BC<PerlPoint::Backend> module is specialized to this stream format and serves as
a basis of converter programs which generate certain output (or presentation) formats.


? flagSet(german)

Mit dieser Architektur gewinnt man die größtmögliche Flexibilität.

* Die Verarbeitung der Vorlage ist in allen Übersetzern gleich, ein 
\PP-Autor kann sich also darauf verlassen, daß die für einen bestimmten 
Übersetzer geschriebene Vorlage auch sicher und in gleicher Weise von jedem 
anderen erkannt wird. Gleichzeitig entsteht ein gesunder Druck auf die 
\PP-Sprachdefinition, so allgemein wie möglich zu bleiben, sich also 
nicht zu sehr in die Richtung eines bestimmten Zielformats drängen zu lassen.

* Neue Features des Parsers kommen automatisch allen Übersetzern zugute.

* Die hohe Spezialisierung der Module ermöglicht den Einsatz optimierter 
Algorithmen.

* Das Zwischenformat läßt sich bei Bedarf durch ein anderes ersetzen, ohne daß 
die Übersetzer angepaßt werden müßten.

* Die aus einer Vorlage gewonnene Zwischendarstellung kann mehrfach ausgewertet 
werden. Sie läßt sich zwischenspeichern oder per IPC zwischen Prozessen 
austauschen.

? flagSet(english)

This architecture provides a great flexibility.

* All converters read sources the same way. It is possible to
  process the same source by various converters.

* All converters can profit from new parser features instantly.

* Specialization of the modules allows to use optimized algorithms.

* The intermediate stream format could be changed or replaced by
  another format without breaking existing converter programs.

* The intermediate stream format gained from one \PP source file can be
  processed multiply by different backend converters. The intermediate format
  could be stored for later processing or transfered to another process.


? flagSet(german)


* Das Schreiben eines neuen Übersetzers reduziert sich im wesentlichen auf die 
Umwandlung der vom Backend-Modul gelieferten Symbole in die Entsprechungen der 
jeweiligen Zielsprache. (Dazu kommen dann natürlich die Spezialitäten, die der 
Übersetzerautor den Anwendern anbieten möchte.)

* Die offene Architektur erlaubt auch das Schreiben individueller 
Erweiterungen, etwa für den Inhouse-Gebrauch, ohne daß Eingriffe in die 
Basissoftware nötig werden.

? flagSet(english)

* Converter authors are relieved from common tasks. Writing of a new converter
  is essentially reduced to transforming the stream symbols provided by the
  \BC<PerlPoint::Backend> module to their corresponding elements in the target
  language. (Special features for the end user, however, can always be added
  by the author of a converter program).

* The open architecture allows also adding of individual features, for example
  for in-house usage, without modifying the basic software.

? flagSet(german)


==Vorlagenverarbeitung

\IMAGE{src="../images/PerlPoint-Parser.gif" epsfxsize=8cm}

\B<PerlPoint::Parser> ist eine Klasse, deren Objekte PerlPoint-Eingaben lesen, 
auf Fehler untersuchen und in das Stream-Zwischenformat umsetzen können. Obwohl 
der Begriff "Parser" strenggenommen nur für die syntaktische Analyse steht, 
führt ein solches Objekt also auch die lexikalische und semantische Analyse aus 
und generiert das Zwischenformat gleich mit. Das ist ein durchaus übliches 
Vorgehen.

Das Anlegen eines Objektes und die Anwendung gestalten sich sehr einfach:

? flagSet(english)

==Parsing sources

\IMAGE{src="../images/pp-src-stream-e.png" epsfxsize=8cm}

\BC<PerlPoint::Parser> is a class whose objects read \PP input,
check it for syntactical errors and translate it to the intermediate
stream format. Although strictly spoken the term \I<parser> is reserved for pure syntactical
analysis, the parser objects also do lexical analysis and some semantic checks and produce the
intermediate format. This is usual practise.

Creating of a parser object and its usage are simple:


// TODO!

? 1

  # pragmata
  use strict;

  # load modules, declare tags
  \B<use PerlPoint::Parser;>
  \B<use PerlPoint::Tags::Basic;>

  # declare variables
  my (@stream);

  # build parser
  my \B<$parser=new PerlPoint::Parser>;

  # and call it
  \B<$parser-\>run(
               files   =\> \\@ARGV,
               stream  =\> \\@stream,
               ...
              )>;

? flagSet(german)

Das ist ein vollständiges, gültiges Script. Es untersucht die beim Aufruf 
übergebenen Dateien, akzeptiert darin die mit dem Parameter \C<tags> per 
Hashreferenz deklarierten Tags und liefert das Ergebnis in \C<@stream>.

Das Anlegen mehrerer Parser-Objekte ist derzeit möglich, aber nicht sinnvoll - 
\C<run()> kann zu einem gegebenen Zeitpunkt ja immer nur einmal laufen. 

? flagSet(english)

This is an almost complete script. (There are more options to specify but this code demonstrates the main parts of a parser call.) It scans all files specified by the command line, accepts all basic \PP tags and produces the intermediate stream format which is provided in the \C<@stream> array.

It is possible to create more than one parser object but does not make sense
because the \C<run> method can only be used once at a time.


? flagSet(german)

===Das Parser-Design

Beim Einlesen eines Eingabetextes kommt es darauf an, ihn anhand bestimmter 
Merkmale zu strukturieren. Einfache Scanner versuchen oft, das Problem durch 
reine Mustererkennung zu lösen. Gerade Perl-Anwender sind hier vielleicht 
manchmal besonders "gefährdet", da sie die Stärken regulärer Ausdrücke kennen 
und oft ganz selbstverständlich darauf zurückgreifen. Und tatsächlich sind 
Muster ein sehr mächtiges Werkzeug und könnten für \PP beispielsweise so 
verwendet werden, daß man das erste Zeichen eines Paragraphen untersucht und 
daraus den Paragraphentyp bestimmt. Anschließend muß man im wesentlichen nur 
noch die Tags aus dem Text herausfiltern, den Rest des Textes kann man 
eigentlich direkt übernehmen ... Wenn man diesen Ansatz implementiert, kommt 
man jedoch bald in große Schwierigkeiten:

? flagSet(english)

===Parser Design

Scanning an input text requires structuring of the text according to certain patterns.
Simple scanners do that by pure pattern recognition and with Perl's powerful
pattern matching this should be easy. Indeed, we could try to recognize each paragraph
looking at the starting character(s). Then only the tags must be extracted and the rest of
the input text could be used "as is". The implementation of this idea, however, leads to
real difficulties:

? flagSet(german)

* Man muß darüber Buch führen, wann ein neuer Paragraph beginnen kann.

* Wenn sich Konstruktionen (wie etwa Tags) in verschiedenen Zeilen öffnen und 
schließen, steigt entweder der Zusatzaufwand zur Buchführung oder die 
Komplexität der verwendeten Muster stark an. Die Les- und Wartbarkeit des Codes 
nimmt mindestens im selben Maße ab.

* Listen, Aufzählungen und Rekursion (wie die beliebige Verschachtelung von 
Tags) sind mit Mustern allein definitiv nicht beherrschbar.

* Syntaktische Fehler in der Eingabe werden leicht übersehen. Sie lassen sich 
nur empirisch abfangen.

* Der entstehende Code kann Änderungen der Sprachdefinition ab einem bestimmten 
Punkt nicht mehr folgen.

? flagSet(english)

* You must handle conditions under which a new paragraph can start or not.

* When tags are opened and closed in different lines (see below) then internal book keeping
  becomes complex or you need very complex patterns for pattern matching. Readability
  of the code decreases and it becomes harder to maintain.

* Lists, enumerations and recursive structures (like arbitrarily combined tags) cannot
  be handled by pure pattern recognition.

* Syntactical errors in the input can easily be overlooked. They can only be handled by
  emperical rules or heuristics.

* While the language design is improved, it becomes more and more difficult to adapt
  the resulting code accordingly. At a certain point, it may become almost impossible.


? flagSet(german)

Derartige Scanner auf Musterbasis eignen sich meines Erachtens darum nur für 
einfache Eingaben mit klar überschaubarer Struktur, oder zum Extrahieren 
bestimmter Informationen aus einer Fülle ansonsten uninteressanter Daten.

Mittel der Wahl sind an dieser Stelle vielmehr Grammatiken. Sie beschreiben die 
formale Syntax einer Sprache, also die Regeln für das Bilden eines fehlerfreien 
"Satzes" aus einzelnen Basiselementen ("Wörtern"). ("Welche Wortart ist wann 
erlaubt? Welche Interpunktionszeichen muß ich wo setzen? Wie baue ich 
Schachtelsätze?") Die eben erwähnte Rekursion kann in einer Grammatik 
beispielsweise sehr einfach abgebildet werden:

? flagSet(english)

That's why in my opinion simple pattern based scanners are only appropriate for simply structured inputs or to extract information from a bunch of otherwise non-interesting data.

The best remedy for our problem is a \I<grammar>. A grammar describes the formal
syntax of a language by providing a set of rules. These rules determine how 
correct \I<sentences> are produced from basic elements (\I<words>): Which type of
word can be used under which conditions? Which punctuation has to be used where?
How can complex sentences be constructed? The recursion mentioned above can be
described easily by a grammar:

? flagSet(german)

  \B<tag> : tag_name \I<tag_body>

  \I<tag_body> : "<" \I<words> ">"

  \I<words> : \I<word>
        | words \I<word>

  \I<word> : this
       | that
       | \B<tag>

  (Interpretation: "x : y | v z" kann man
   als "ein x besteht aus einem y oder aus
   einer Folge von v und z" lesen.)

? flagSet(english)

  \B<tag> : tag_name \I<tag_body>

  \I<tag_body> : "<" \I<words> ">"

  \I<words> : \I<word>
        | words \I<word>

  \I<word> : this
       | that
       | \B<tag>

  (Interpretation: "x : y | v z" means:
   "x is comprised by one y or a sequence
   of v and z")

? flagSet(german)

Die gezeigte Darstellung ist nur eine unter mehreren Möglichkeiten, auf die wir 
im Rahmen dieses Artikels aber nicht weiter eingehen können. (Wir verweisen 
stattdessen auf das während des Workshops angebotene Parsing-Tutorial von 
Damian Conway.) Grammatiken sind ein sehr mächtiges Hilfsmittel und haben den 
unschätzbaren Vorteil, daß sie im Rahmen des Compilerbaus jahrzehntelang 
ausgiebig untersucht wurden, so daß ausdrucksstarke Beschreibungsmöglichkeiten 
und mächtige Codegeneratoren zur Verfügung stehen - inzwischen auch für Perl. 
\B<PerlPoint::Parser> greift auf \B<Parse::Yapp> zurück, eine Entsprechung für 
das unter C verwendete Utility \B<yacc>.

? flagSet(english)

This grammar format is only one of several possibilities, please refer to the many parsing intros around, e.g. at "The man of Descent" by Damian Conway, for further details. In short, grammars are a powerful tool. They have been thoroughly investigated and are widley used for building compilers. Efficient code generators are available, in the meantime even for Perl. \BC<PerlPoint::Parser> uses \BC<Parse::Yapp> which corresponds to the UNIX \B<yacc> utility for C.


? flagSet(german)

Ich bin gefragt worden, warum ich mich für dieses Modul entschieden habe. Das 
hat vor allem drei Gründe, von denen zwei einfach historischer Natur sind: ich 
habe mehrfach erfolgreich mit \B<yacc> gearbeitet, ich mag die Prägnanz 
linksrekursiver Regeln, und ich weiß, daß \B<Parse::RecDescent> als 
alternatives (und sehr mächtiges!) Modul den Parser jedesmal erneut zur 
Laufzeit aus der Grammatik konstruiert, was viel Zeit kostet. \B<Parse::Yapp> 
generiert aus der Grammatik dagegen \I<einmal> ein neues Parser-Modul, das ohne 
Verzögerung mit der Quelltextanalyse beginnen kann. Auch durch die Art der 
verwendeten Grammatik ("bottom up") entsteht für \B<Parse::Yapp> ein 
prinzipbedingter Geschwindigkeitsvorteil. Da \B<Parse::Yapp>-Grammatiken 
außerdem direkt von yacc verarbeitet werden können, wird sich die Performance 
des Parsers voraussichtlich noch einmal deutlich steigern lassen, falls einmal 
ein Modul zur direkten Integration von Yacc-Parsern in Perl zur Verfügung steht 
(Tests von Vladimir Jebelev zufolge bleiben (mit \C<byacc> konstruierte) reine 
Perl-Parser etwa um den Faktor 400 hinter C-Lösungen zurück).

? flagSet(english)

? flagSet(german)

Die grundsätzliche Konstruktion entspricht also dem üblichen Schema: es gibt 
einen \I<Lexer>, der Folgen einzelner Zeichen untersucht und darin "Worte" der 
Sprache \PP ausmacht, sogenannte \I<Token>. Hat der Lexer ein Token in 
der Eingabe gefunden, informiert er den Parser darüber, der dann in der (in 
Tabellenform) hinterlegten Grammatik erforscht, ob dieses Token syntaktisch zur 
Zeit korrekt ist oder nicht. Im Erfolgsfall stößt er sogenannte semantische 
Aktionen an, die die Eingabe \I<inhaltlich> überprüfen, mit bereits früher 
erhaltenen Informationen mischen oder für die spätere Weiterverarbeitung 
speichern. Als Ergebnis aller semantischen Aktionen entsteht die 
Stream-Umsetzung der Vorlage.

? flagSet(english)

The \PP parser architecture follows a common scheme: There is a \C<lexer> which parses
the sequence of characters and detects "words" which are relevant to \PP, so called
\I<tokens>. Each time the lexer finds a token he informs the parser which checks
if that token is allowed at that time and in the current context. This is done
by using the grammar which is stored in a table format internally. If the token can
be accepted, so called semantic actions are started which do some semantical checks,
merge the input with stuff collected earlier or store the text for further use.
The result of all semantical actions is the intermediate stream format.

? flagSet(german)

Im \PP-Fall gibt es allerdings einige Besonderheiten. Die Eingabesprache 
ist \I<viel> weniger formal als Programmiersprachen. Da der Autor einer Vorlage 
größtmögliche Freiheit bei der Formulierung genießen soll und letztendlich 
Sätze einer natürlichen Sprache übergibt, sind Leerzeichen im Gegensatz zu 
Programmiersprachen normale Token und nicht etwa ignorierbare Trennzeichen. 
Sonderzeichen können zum Vorlageninhalt gehören oder eine spezielle 
\PP-Bedeutung haben: ein "<"-Zeichen kennzeichnet den Beginn des 
Textbereiches, auf den ein Tag angewendet werden soll - aber nur, wenn 
unmittelbar davor auch ein Tag begonnen wurde. An anderen Stellen muß dieses 
Zeichen als normaler String behandelt werden (sonst wäre es jedesmal durch 
einen Backslash zu entwerten). Tags und Backslashes sind überall zulässig, in 
"verbatim blocks" und eingestreuten Fremdsprachenabschnitten jedoch ohne 
weitere Behandlung als schlichter Text zu werten. Ähnliches gilt für alle 
Sonderzeichen und Konstruktionen (wie \C<"\<\<EOM">), die einen Paragraphen 
eröffnen können - in diesem Augenblick haben sie eine Sonderstellung, steht der 
Paragraphentyp jedoch fest, sind sie lediglich Zeichen(ketten). Zeilenumbrüche 
verlieren in Textparagraphen, Überschriften und Listenpunkten ihre eigentliche 
Bedeutung - der Lexer liefert sie darum gleich als einfache Leerzeichen. 
Andererseits schließen sie aber Kommentare ab, markieren das Ende von 
Tabellenzeilen und müssen in "verbatim blocks" als Bestandteil der Eingabe 
erhalten bleiben.

? flagSet(english)

Different to common grammars, the \PP grammar has to deal with special cases because the language
is \I<much> less formal than, let's say, programming languages. Spaces are tokens, not token delimiters (which are usually ignored). Special characters can have a special meaning or not, depending on their contents: \C<"<">, for example, flags the start of a tag body, but only if a tag has been started. Everywhere else it is a plain string. Tags and backslashes are valid everywhere except of verbatim blocks and embedded parts. Very similar, special characters and constructions like \C<<<EOM> which can open a paragraph are special only when a new paragraph is expected but meaningless strings otherwise. Newlines are no real newlines but spaces if used in text, headlines or lists, but they complete comments and table headlines (occasionally) and must be streamed in verbatim blocks.

? flagSet(german)

Um all diesen Forderungen gerecht werden zu können, wird der Lexer sehr stark 
vom Parser gesteuert, der Parser wirkt also auf den Lexer zurück. Vereinfacht 
gesagt hat das zur Folge, daß der Lexer Token in Abhängigkeit vom gerade 
erreichten grammatischen Status erkennt. Vor dem Erkennen eines neuen 
Paragraphen sind beispielsweise alle zulässigen Paragrapheneröffnungszeichen 
als Spezialzeichen eingetragen und werden dann entsprechend geliefert, 
unmittelbar nach dem Feststehen des Paragraphentyps kürzt der Parser dann über 
eine \C<stateManager()>-Funktion die Spezialzeichenliste rigoros zusammen, bis 
der Paragraph wieder abgeschlossen ist. Über den State Manager wird auch 
bestimmt, wie der Lexer auf \C<\\n>, Leerzeilen und Einrückungen am Anfang 
einer Zeile reagiert - sie können ignoriert, als Leerzeichen gemeldet oder eben 
auch "wirklich" erkannt werden. Auf diese Weise erreicht man trotz einer fest 
verdrahteten Grammatik ein sehr flexibles Verhalten des Gesamtsystems - 
allerdings mit der Folge, daß der Parser nur mit einem auf diese Weise 
steuerbaren Lexer wirklich \PP parsen kann. Der Lexer wurde daher auch 
nicht von einem Generator erzeugt, sondern von Hand geschrieben. 

? flagSet(english)

To handle all this, \I<the parser controls the lexer> which simply means that the lexer recognizes tokens depending on the current grammar context. For example, all characters opening a paragraph are stored in a special hash when a new paragraph is expected. But once the parser knows about the type of a new paragraph it removes all entries of this hash by a special \C<stateManager()> function. The state manager as well controls how the lexer deals with \C<\n>, spaces and line indentations - they can be ignored, reported as simple spaces or recognized as they are. With this implementation, the lexer/parser system can act very flexible even with a fix \C<yacc> like grammar. Of course this only works if the lexer can be controled by the parser as described, so the lexer is not generated but handcrafted.

? flagSet(german)

===Tags

Wie bereits früher erwähnt, werden Tags vom Parser nur sehr allgemein 
unterstützt. Die Deklaration der akzeptierten Tagnamen liegt ganz in den Händen 
des Übersetzerautors. Auf diese Weise soll \PP möglichst offen für 
Erweiterungen bleiben, ohne daß die Basissoftware für jeden neuen Übersetzer 
angepaßt werden muß - für ein spezielles Ausgabeformat wichtige Tags könnten in 
einem anderen überhaupt keine Bedeutung haben.

? flagSet(english)

===Tags

As mentioned above, only the general syntax of tags is part of the base language definition.
The declaration of the accepted tags is almost completely the task of the author of a \PP
converter because tags are very converter specific. They usually reflect a feature of the target format or a special feature the converter author wants to provide.

  Hyperlinks, for example, are essential if converting
  to HTML. They can be used in PDF as well. But if you
  are writing a converter to \I<pure text>, they might
  be useless.

  Or: one author wants to provide footnotes, while another
  one does not.

To implement all wished tags in the parser would make the converter framework of parser and backend modules very inflexible and hard to maintain. Such an approach could end up with a huge, difficult to maintain or even unusable tag library. All tag implementation details of all converters would need to be well coordinated. So that's no real alternative.

Instead of this, \PP (or its \I<base> definition) only defines the \I<syntax> of a tag (and reserves a small set of tags implementing base features like tables or image integration). \I<The definition of concrete tags, however, is a task of the several converters.> So a converter author is free to define all the tags he wants, and he can modify this set without changes to the framework. A definition currently includes the tag name, option and body declarations, and controls how the parser handles tag occurences. It's even possible to hook into the parsers tag processing.

Tags are defined by \I<Perl modules>, for a simple reason: we looked for a way to make their usage as easy as possible. And what could be easier than to write something like

  use \PP::Tags::\B<MyFormat>;

\? Hardly nothing.

But there are even more advantages. Defining tags by modules provides a simple way to \I<combine> definitions, to publish them in a central tag repository (CPAN) and to use them in various converters. \PP even offers a way to say the parser "We do not implement the tags of target language SuperDooper, but please treat them as tags anywhere (we will ignore them in the backend running subsequently)." - which makes it easy to process one and the same source by numerous converters defining completely different tag sets.


====Tag definitions

Let's have a look at a tag definition module. The tags of a certain converter are declared by a hash reference:

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
\BC<PerlPoint::Constants> (which comes with the framework). Omitted \C<options> or \C<body> slots mean that options or body are \I<optional>. Depending on the declaration, the parser will strictly require options or body (mandatory), recognize but not require them (optional) or completely ignore any occurence of them (obsolete). This means that a tag declaration controls the way a parser handles input. In other words, they are a grammar extension.

If further checks are necessary a tag author can even hook into the parser by using the \C<hook> key, specifying a subroutine:

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

Whenever the parser detects an occurence of a hook tag, it will invoke the hook function and pass the source line, a reference to a hash of option name / value pairs to check, and a body array. Using the option hash reference, \I<the hook can modify the options>. Different to this, the body array is \I<a copy> of the body part of the stream. Therefore the hook cannot modify the body part.

The value replied by a hool function determines how the parser continues to work. A hook can express that the tag was ok, and the parser will continue to process the source. Alternatively, the hook can enforce the parser to stop immediately, declaring the parsed input to be valid or syntactically incorrect.


====Tag activation

Now, in a translator software where a parser object should be built, tag
declarations can be accessed by simply loading the declaration modules,
just as usual:

  # declare all the tags to recognize
  use PerlPoint::Tags::New;

This updates a structure in the \BC<PerlPoint::Tags> namespace. \I<The parser
knows about this structure and will automatically evaluate it.>

Several declaration modules can be loaded subsequently. Each \I<new> tag is
added to the internal structure, while \I<predeclared> tags are overwritten
by new declarations.

  # declare all the tags to recognize
  use PerlPoint::Tags::Basic;
  use PerlPoint::Tags::HTML;
  use PerlPoint::Tags::SDF;
  use PerlPoint::Tags::New;

Certain translators might only want to support \I<subsets> of tags declared in a
\B<PerlPoint::Parser> submodule. This is possible as well, similar to the usual
import mechanism:

  # declare all the tags to recognize
  use PerlPoint::Tags::New \B<qw(COLORIZE)>;

This does only declare the \C<COLORIZE> tag, but ignores \C<EMPHASIZE> and \C<FONTIFY>.

And if a tag definition module declared a "tag set" by something like

  %sets=(
         \B<pointto> => [qw(EMPHASIZE COLORIZE)],
        );

various tags can be activated at once:

  # declare all the tags to recognize
  use PerlPoint::Tags::New \B<qw(:pointto)>;


====Accepting unknown tags

Every converter supports a set of tags, but users can process the same sources by \I<several> converters which support different tags, so a source processed by one converter may contain tags which are not supported. Fortunately a user only needs to specify \C<-tagset FORMAT> to make all definitions of pp2format known to every other \PP converter.

  If a document was initially written to be processed
  by pp2\B<html> and is now passed to another converter,
  a user can use "-tagset \B<HTML>".

How does this work? When \C<-tagset> is used, \PP extends the converters tag definitions by loading the specified foreign tag definition files additionally.

  If "-tagset \B<HTML>" is specified, the definition
  module \PP::Tags::\B<HTML> is loaded.

Different to usual tag activation, no warning is displayed here if a loaded foreign tag is named like an own one, and the \I<original> converter definition will remain established to give the converter first priority.

By this mechanism, each source should be accepted by every converter. Of course, accepting the foreign tags does not mean that they are translated into the target format. Instead of this, foreign tags will be simply ignored when the converters backend processed the intermediate stream.


? flagSet(german)

==Das Stream-Zwischenformat

? flagSet(english)

==The stream format

? 1

\IMAGE{src="../images/PerlPoint-Stream.gif"}

? flagSet(german)

Alle vom Parser gewonnenen Informationen werden in einer Datenstruktur 
abgelegt, die eine Folge von Symbolen repräsentiert - einem Stream. Wenn man so 
will, handelt es sich nur um eine leicht modifizierte Version des in der 
Vorlage gefundenen Eingabe-Streams. Die eigentlichen Inhalte (Wörter und 
Interpunktionszeichen) werden sogar überhaupt nicht verändert.

? flagSet(english)

All informations gathered from the sources are stored in an intermediate, internal data structure which represents a sequence of symbols - a stream. One could say that this is just a slightly modified version of the \I<input> stream. And indeed, the literal \I<contents> (words etc.) is simply copied.

? flagSet(german)

Implementiert ist das mit einem einfachen Array. Reine Inhalte finden sich hier 
als Strings wieder, während Steueranweisungen - öffnende und schließende Tags, 
der Beginn eines eingebetteten "Fremdsprachen"-Abschnittes, ein Hinweis auf ein 
einzufügendes Bild usw. - immer Arrayreferenzen sind. Dieser Entwurf macht es 
später einfach, auf Steueranweisungen gezielt zu reagieren, während man die 
Inhalte meist 1:1 in das Ergebnis übernehmen kann.

? flagSet(english)

The current stream implementation is a simple array. Pure contents is stored by strings, while logical elements or control directives - opening and closing tags, embedded parts in another language, image hints etc. - are array references. This design makes it very easy to recognize control directives while processing the stream, while literal contents can usually be copied to the output unchanged.

? flagSet(german)

 Der Vorlagentext \B<"Ich schreibe \\I\<manchmal\> kursiv.">
 wird beispielsweise etwa so im Stream abgelegt:

 (
  "Ich", " ", "schreibe", " ",
  [DIRECTIVE_TAG, DIRECTIVE_START, "I"],
  "manchmal",
  [DIRECTIVE_TAG, DIRECTIVE_COMPLETE, "I"],
  " ", "kursiv."
 )

? flagSet(english)

  The source \B<"\\I<Sometimes> I'm writing italicized.">
  is stored by something like

 (
  [DIRECTIVE_TAG, DIRECTIVE_START, "I"],
  "Sometimes",
  [DIRECTIVE_TAG, DIRECTIVE_COMPLETE, "I"],
  " I'm writing italicized."
 )

? flagSet(german)

Der Platzbedarf ist kleiner, als man auf den ersten Blick vermutet, da 
\C<DIRECTIVE_TAG> und alle anderen Direktiven numerische Konstanten sind.

Das Format ist recht flexibel, zusätzliche Informationen wie die Optionen eines 
Tags lassen sich einfach als weitere Elemente im Array der Direktive speichern:

? flagSet(english)

This format consumes less space than might be guessed at first sight because all directives are stored by numeric constants like \C<DIRECTIVE_TAG>. It is relatively flexible because additional informations like tag options can be easily stored as directive array fields.

? 1

  [
   DIRECTIVE_TAG,
   DIRECTIVE_START,
   "FONT",
   \B<{color =\> "red"}>,
  ]

? flagSet(german)

Streams sind nicht unbedingt die übliche Form eines Zwischenformats für 
Übersetzer. Viele Compiler verwenden einen Baum, also eine Datenstruktur, in 
der die einzelnen Elemente hierarchisch miteinander verknüpft sind. Bäume 
bieten Codegeneratoren eine gut erforschte und für viele nötige Operationen gut 
geeignete Basis. Warum also hier ein Stream?

? flagSet(english)

Streams are not necessarily the prefered format of storing intermediate informations in a translator. Compilers usually use trees, a hierarchical data structure which is well known in translator theory. So why a stream?

? flagSet(german)

Die einfache Antwort ist die, das es die naheliegende Lösung war: \PP ist 
ebenso wie viele Zielsprachen ein Streamformat. Darüber hinaus hat sie sich 
aber auch als robust und platzsparend bewährt. Der Aufwand für den Aufbau, die 
Verwaltung und das Durchlaufen eines Baums erscheinen unnötig. Viele in 
Compilern für Programmiersprachen übliche Aufgaben fallen beim Verarbeiten von 
\PP einfach nicht an - es gibt praktisch keine Operatoren, keinen 
Vorrang, keine Assoziativität, keine Operationen, die dementsprechend in 
Basisschritte zerlegt werden müßten usw. Die Natur einer \PP-Vorlage ist 
vielmehr nahe verwandt mit der eines Buchtextes - sie wird von links nach 
rechts gelesen (und auch wieder ausgegeben). Veränderungen wie der Wechsel in 
eine kursive Schriftdarstellung sind Schalter, die auf diesem Weg betätigt 
werden und aktiv bleiben, bis ein geeigneter anderer Schalter sie wieder 
zurücknimmt. Die Struktur der Sprache ist fast überall linear.

? flagSet(english)

The simple answer is that it looked very appropriate: \PP itself \I<is> a stream format, and numerous target formats as well. Even more, the stream solution is now prooved to be very stable and relatively compact. There's no need of the additional effort of managing a tree. Most of the usual compiler tasks which require trees do not need to be performed when processing \PP - there are no operators, no priority, no associativity, no operations to split into base parts accordingly etc. Instead, the nature of a \PP source is comparable to a book: it is read (and translated) from left to right. Changes like activation of italic formatting are toggling switches which are activated and deactivated while walking the source way. The source structure is almost everywhere very linear.

? flagSet(german)

Nun, nicht überall. Überschriften verschiedener Ebenen sind das beste Beispiel 
für enthaltene Hierarchien. Übersetzer wie \B<pp2html>, die ein 
Inhaltsverzeichnis aufbauen, müssen die gefundenen Überschriften dafür beim 
Auswerten des Streams sammeln. Hier wäre eine Baumstruktur des Zwischenformats 
geeignet, den Übersetzern Arbeit abzunehmen. Auch für Querverweise oder die 
Implementierung eines \PP-Editors würden sich Vorteile ergeben. Es könnte 
deshalb sein, daß sich das Zwischenformat in Zukunft ändert - ein Grund mehr, 
nur mit Hilfe von \B<PerlPoint::Backend> darauf zuzugreifen.

? flagSet(english)

Well, there \I<are> exceptions. Headlines are the best example of hierarchies. Converters like \C<pp2html> writing a table of contents need to collect the headlines while the stream is processed. A tree structure would relieve converter authors at this point. Hyperlinks are another example. For these reasons, the intermediate format might be modified in future releases. Existing converters will not be affected by such a change - assumed they use the converter framework to process the stream.


? flagSet(german)

==Übersetzer schreiben

? flagSet(english)

==Writing converters

? 1

\IMAGE{src="../images/pp-stream-result-e.png" epsfxsize=14cm}

? flagSet(german)

Auch wenn das Zwischenformat sehr einfach aufgebaut ist, wäre es doch unsinnig, 
jedem Übersetzerautor neu die Beschäftigung damit zuzumuten, zumal 
Weiterentwicklungen des Formats dann nur noch schwer möglich wären. 
\B<PerlPoint::Backend> kapselt darum den Zugriff auf einen von 
\B<PerlPoint::Parser> erzeugten Stream. Wer einen Übersetzer schreiben will, 
braucht lediglich ein Objekt dieser Klasse anzulegen

? flagSet(english)

The stream format is currently very easy, but it would make no sense to let every converter author deal with it again, which would make it hard to modify the format as well. So \B<PerlPoint::Backend> encapsulates the stream access. Whoever want to write a converter only needs to make an object of this class

? 1

  # load the module:
  use PerlPoint::Backend;

  # build the backend
  my \B<($backend)=new PerlPoint::Backend(name=\>'html')>;

? flagSet(german)

und Handler für die in den Stream eingestreuten Direktiven anzumelden, die er 
auswerten möchte, beispielsweise für eine Überschrift.

? flagSet(english)

and to register callbacks to handle all directives (like headlines or tags) which will be found in the stream.

? 1

  # register headline handler
  $backend->\B<register(DIRECTIVE_HEADLINE, \\&handleHeadline)>;

? flagSet(german)

Nach Abschluß der Vorbereitungen wird das Backend gestartet, um einen vom 
Parser erzeugten Stream in die Zielsprache (hier HTML) umzusetzen.

? flagSet(english)

When all preparations are completed the backend can be started to process a stream generated by the parser.

? 1

  # translate
  $backend->\B<run(\\@stream)>;

? flagSet(german)

Die Methode \C<run()> durchläuft den Stream und ruft für jedes Element in 
Abhängigkeit vom Typ einen der hinterlegten Handler auf - falls kein Handler 
angemeldet wurde, wird das Element einfach ignoriert (auch für einfache Strings 
benötigt man also einen Handler). Das kann durchaus sinnvoll sein, wenn eine 
Zielsprache nicht alle von \PP angebotenen Möglichkeiten unterstützt.

? flagSet(english)

\C<run()> walks through the stream and detects the type of each entry. If a callback was registered to handle this type, it will be invoked, otherwise the entry is ignored. This means that a converter means to register callbacks for simple contents (literal strings) as well. Ignoring parts is useful if a target format does not provide all features of \PP.

? flagSet(german)

Angenommen, \C<run()> entdeckt eine Direktive, die den Beginn einer Überschrift 
anzeigt, dann ruft die Methode den angemeldeten Handler \C<handleHeadline()> 
mit den Parametern \C<DIRECTIVE_HEADLINE>, \C<DIRECTIVE_START> und der im 
Stream gefundenen Überschriftenebene auf. Der Handler könnte daher so aussehen:

? flagSet(english)

Let's assume that \C<run()> detects a directive which flags the begin of a headline. In this case, the method invokes the registered callback \C<handleHeadline()> and passes the parameters \C<DIRECTIVE_HEADLINE>, \C<DIRECTIVE_START> and the headline level which is stored in the directive array. To deal with these parameters, a headline handler could look like this:

? 1

  sub handleHeadline
   {
    # get and check parameters
    my \B<($directive, $startStop, $level)=@_>;
    confess "Something is wrong\\n"
      unless $directive==DIRECTIVE_HEADLINE;

    # begin or close a headline
    if ($startStop==DIRECTIVE_START)
      {print "<head$level>";}
    else
      {print "</head>";}
   }

? flagSet(german)

Dieser Handler würde einfach das einleitende HTML-Überschriften-Tag erzeugen. 
Wird die Überschrift später durch eine weitere Direktive abgeschlossen, 
übergibt \C<run()> dem Handler anstelle von \C<DIRECTIVE_START> das Flag 
\C<DIRECTIVE_COMPLETE>, und er kann das entsprechende schließende Tag ausgeben.

? flagSet(english)

This handler would simply write the beginning HTML headline tag. Later on, when the headline will be completed by another directive in the stream, \C<run()> will invoke the function with \C<DIRECTIVE_COMPLETED> instead of \C<DIRECTIVE_START> which will enforce the callback to write the closing headline tag.

? flagSet(german)

Dieses einfache Prinzip hat sich für die bisher erzeugten Zielsprachen als sehr 
wirkungsvoll erwiesen.

? flagSet(english)

This simple principle has been very sufficient in the converters already implemented.


? flagSet(german)

==Caching

Auszeichnungssprachen haben gegenüber WYSIWYG-Tools einen Nachteil: man muß sie 
erst "übersetzen", bevor man sich das Ergebnis anschauen kann. Um die 
Turn-Around-Zeiten bei der Bearbeitung längerer Dokumente möglichst kurz zu 
halten, kann \B<PerlPoint::Parser> deshalb auf Wunsch mit einem Cache arbeiten. 
Auch bei kurzfristigen Änderungen unmittelbar vor oder sogar während einer 
Präsentation ist es vorteilhaft, wenn nur noch die modifizierten Teile erneut 
geparst werden müssen. 

Die Paragraphenorientierung von \PP kam der Cacheimplementierung sehr 
entgegen. Der Cache wird für jede Vorlage als Datei \C<.\<vorlage\>.ppcache> 
verwaltet, in dem die Ergebnisse bereits gelesener Paragraphen als 
Stream-Fragmente bereitstehen. Diese Dateien sind mit \B<Storable> 
serialisierte Hashes, in denen jeweils eine (mit Hilfe von \B<Digest::SHA1> 
gebildete) SHA-Prüfsumme des Paragraphen als Schlüssel und der zugehörige 
Stream-Ausschnitt als Wert hinterlegt sind.

Ist der Cache aktiviert, liest \C<PerlPoint::Parser::run()> beim Start die 
serialisierten Daten ein. Perls \C<\<\>>-Operator, der im Parser ja 
normalerweise zeilenweise arbeitet, wird beim Erreichen eines neuen Paragraphen 
kurzfristig in den Paragraphenmodus umgeschaltet, so daß sich der Paragraph mit 
\I<einem> \C<\<\>>-Aufruf einlesen läßt. Nach der Bildung der Prüfsumme läßt 
sich schnell feststellen, ob bereits ein Eintrag existiert - wenn ja, kann das 
dafür gespeicherte Stream-Fragment direkt in den neuen Ergebnisstream eingefügt 
werden, und der Parser kann sich sofort dem nächsten Paragraphen zuwenden. Da 
gegebenenfalls auch der von \B<Parse::Yapp> konstruierte Parser-Automat über 
die neue Eingabe informiert werden muß, ist die Grammatik so erweitert worden, 
daß die Eingabe auch mit einem Cache-Hit syntaktisch korrekt bleibt, wie zum 
Beispiel hier in der Grammatik einer Überschrift:

  # headline
  headline : headline_level basics Empty_line
           \B<| Headline_cache_hit>

Die Namen der den Paragraphen entsprechenden Token-Strings 
(\C<"Headline_cache_hit">) sind ebenfalls im Cache hinterlegt.

Falls für einen Paragraphen kein Treffer im Cache gefunden werden kann, ist der 
dazugehörige Stream natürlich erst auf die übliche Weise aufzubauen. Der Parser 
positioniert den Dateipointer dazu wieder an der ursprünglichen Stelle und 
schaltet in den Zeileneingabemodus zurück. Wurde der Paragraph schließlich 
vollständig bearbeitet, landet das Ergebnis - zusammen mit der solange 
aufbewahrten Prüfsumme - im Cache-Hash, den \C<run()> nach der Bearbeitung der 
gesamten Eingabedatei wieder mit \B<Storable> serialisiert.

Trotz der mit dem mehrfachen Lesen verbundenen Verzögerung, des 
Cache-Verwaltungs-Overheads und der Tatsache, daß viele Paragraphen sich durch 
ihre variablen Inhalte (Verwendung von Variablen und Makros oder eingebettete 
"Fremdsprachen" einschließlich Perl, Deklaration von Makros und Variablen etc.) 
einem Caching völlig entziehen, können mit dem Cache beachtliche 
Beschleunigungen erreicht werden. (Für umfangreiche (echte!) 
Schulungsunterlagen, die ausgiebig von Makros Gebrauch machten, lag der 
Zeitgewinn zwischen 20 und 30%.)

Der Umgang mit dem Paragraph-Modus des \C<\<\>>-Operators hat auch seine 
Tücken. Perl liefert nämlich immer nur \I<ein> \C<\\n> am Ende eines derartig 
gelesenen Paragraphen - auch wenn in der Eingabe eigentlich mehrere davon 
vorhanden waren. Dieses undokumentierte Verhalten hat leider die Konsequenz, 
daß die vom Parser angezeigten Zeilennummern nach Cache-Hits zu klein sein 
können - es gibt keine (uns bekannte) Möglichkeit, die wahre Zeilenanzahl zu 
ermitteln. (Auch ein Ablegen der Zeilenzahl im Cache hilft da nicht weiter - 
denn die Zeilen zwischen den Paragraphen gehen ja gerade nicht in die 
Cache-Prüfsummen ein.)

\PP-Caches wachsen mit jeder übersetzten Änderung eines Dokuments. (Das 
kann natürlich auch vorteilhaft sein, wenn man einen Paragraphen einmal wieder 
in seine ursprüngliche Form zurückversetzt hat!) \C<PerlPoint::Parser::run()> 
bietet für die Option \C<cache> aber nicht nur die Einstellungen \C<CACHE_ON> 
und \C<CACHE_OFF>, sondern auch \C<CACHE_CLEANUP> an, die einen bestehenden 
Cache zunächst einmal neu initialisiert - indem er gelöscht wird.

? flagSet(german)

=Verfügbare Übersetzer

\INCLUDE{file="translators.pp" type=pp}

? flagSet(english)

=Available Translators

\INCLUDE{file="translators.pp" type=pp}




























? flagSet(german)

=Vergleich mit anderen Lösungen

\PP ist nicht das einzige Präsentationssoftware-Projekt. Schon im 
Perl-Umfeld existiert mit dem \B<GNU Portable Presenter> ein weiteres Programm. 
\I<MagicPoint> wurde mit Hilfe der X11-Bibliotheken in C realisiert. Und 
\I<PythonPoint> ist nicht nur dem Namen nach an \PP angelehnt, sondern 
wurde einem Hinweis auf der Homepage zufolge direkt von Tom Christiansens 
ursprünglicher Idee inspiriert. (Es handelt sich aber um ein völlig 
eigenständiges Projekt mit eigenen Formaten und Features.) Jedes dieser Pakete 
generiert Präsentationen aus Textvorlagen. Jedes dieser Pakete setzt eigene 
Akzente und bietet zum Teil raffinierte Möglichkeiten. Der folgende Vergleich 
ist rein technischer Natur und natürlich trotz allem subjektiv. Ich muß 
vorausschicken, daß ich alle Programme nur aus der Dokumentation kenne und nie 
selbst eingesetzt habe.


==Eingaben

Jedes Paket definiert seine eigene Vorlagensprache. Solche Sprachen sind zum 
einen sehr stark eine Frage des persönlichen Geschmacks (und entziehen sich 
damit jedem sinnvollen Vergleich), andererseits gibt es aber auch 
konzeptionelle Unterschiede.

PythonPoint verarbeitet \I<XML>, Portable Presenter bietet ein optionales 
XML-Frontend an. Standardmäßig sind Portable-Presenter-Vorlagen 
\I<Perl>programme. Sowohl Perl als auch XML sind (auf verschiedene Weise) sehr 
ausdrucksstark und mächtig. Beide bieten allerdings auch eine relativ hohe 
Einstiegshürde, ganz besonders Anwendern, die \I<nicht> aus dem 
Programmierumfeld stammen. Der Weg bis zu ersten brauchbaren Ergebnissen ist 
(für Einsteiger) also unter Umständen recht lang.

Ich persönlich halte es für schwierig, lange Texte flüssig (und fehlerfrei) in 
XML zu schreiben oder in einer solchen Vorlage "mal eben so" eine Ergänzung zu 
machen. Auf der anderen Seite erschließt man sich damit alle  Programme und 
Generatoren, die XML erzeugen können.

\PP setzt auf ein möglichst "natürlichsprachiges", weitgehend intuitiv 
erfaßbares Textformat, das schnell erlernbar ist. Auch nichtprogrammierende 
Mitarbeiter eines Projektes können es sich in relativ kurzer Zeit aneignen.


==Ausgaben

Der aus meiner Sicht größte Unterschied zwischen den erwähnten Programmen und 
\PP ist der, daß sie auf ein bestimmtes Präsentationsformat festgelegt 
sind. PythonPoint setzt dabei auf PDF, während MagicPoint und Portable 
Presenter eigene Projektionskomponenten mitbringen, die die hauseigenen Formate 
abspielen können. Diese Projektoren bieten verschiedene Effekte, die sich 
direkt aus der Vorlage steuern lassen. Im Gegensatz dazu ist \PP in der 
aktuellen Implementierung \I<nicht> fest mit einem Ausgabeformat verknüpft. 
\PP an sich ist \I<kein> Präsentations\I<tool>, sondern ein \I<Format> 
zur Beschreibung von Präsentationen \I<plus ein Toolset> zur Generierung 
entsprechender Ausgaben. pp2\I<html> generiert \I<HTML>-Foliensets zum 
"Abspielen" in Webbrowsern. Es läßt sich aber jederzeit auch ein pp2\I<xy> 
entwickeln, das eine Vorlage in prinzipiell \I<jedes> offengelegte Format 
\I<XY> übersetzen kann. "XY" könnte also durchaus auch das Eingabeformat von 
MagicPoint oder Portable Presenter sein! Aus der Sicht von \PP sind 
MagicPoint und Portable Presenter einfach weitere potentielle Projektoren. 
PythonPoint stellt sich aus diesem Blickwinkel als ein Übersetzer dar, der 
Acrobat als Projektionssoftware erschließt.

Die Kehrseite des allgemeineren \PP-Ansatzes ist natürlich die, daß das 
Vorlagenformat im Gegensatz zu den genannten anderen "Projektionssprachen" 
\I<keine> speziellen Steueranweisungen für den adressierten Projektor bietet. 
Ein Überblendeffekt ist beispielsweise in der am Inhalt orientierten Sprache 
nicht vorgesehen. \PP-Ergebnisse tendieren von Haus aus eher dazu, 
statisch zu sein, während der flexible Portable-Presenter-Ansatz am anderen 
Ende der Skala zur \I<Präsentationszeit> Perlcode ausführt und so (im Rahmen 
der von Perl/Tk gebotenen Möglichkeiten) jede mit Perl realisierbare Dynamik 
erlaubt, die einem Präsentationsautor geboten erscheint. (Ob das Ausführen von 
Perlcode während einer Präsentation allerdings eine sicherheitstechnisch 
erwünschte Lösung ist, ist wieder eine andere Frage - ganz besonders, wenn man 
die Präsentation nicht selbst geschrieben hat.)

\I<Diese \PP-Einschränkung besteht allerdings nur auf den ersten Blick.> 
Jeder Übersetzerautor kann neue Tags mit spezieller Semantik definieren, die 
auf seine Zielsprache zugeschnitten sind und die er auf geeignete Weise in 
Effekte umsetzen lassen kann. Und das freie \I<Einbetten> anderer Sprachen 
erlaubt es, MagicPoint-Elemente (oder die jedes anderen Formats) völlig frei in 
die \PP-Vorlage zu mischen. So gesehen bietet \PP sogar die größere 
Flexibilität.

// Diesen Absatz eventuell streichen?
\PP läßt sich bei Bedarf also gut mit den anderen Programmen 
\I<kombinieren>; sie schließen sich nicht aus, sondern können sich aufgrund der 
offenen \PP-Architektur ergänzen.


==Präsentation

Wer MagicPoint- oder Portable-Presenter-Präsentationen abspielen möchte, muß 
die entsprechende Software (inklusive perl bzw. sogar Perl/Tk) installiert 
haben. Wenn das eigene Notebook während des Vortrags streikt, sollte die 
Ersatzmaschine also schon präpariert sein! MagicPoint setzt auf X11 auf und ist 
daher auf Maschinen mit X-Server beschränkt. Die "Einstiegshürde" für eine 
\I<pp2html>-Präsentation ist deutlich niedriger: jeder installierte Webbrowser 
reicht aus. Eine mit PythonPoint erzeugte Präsentation läßt sich auf einem 
typischen Rechner ähnlich schnell darstellen.

\PP erlaubt als einziges System die direkte Publikation im Web.


=Mehr als Präsentieren

\PP ist kein Redaktionssystem, kein Publishing-Tool und auch keine 
Textverarbeitung. Dennoch kann es für etliche Aufgaben aus den entsprechenden 
Gebieten eingesetzt werden. Und auch bei Präsentationen bietet es sich für mehr 
als die reine Foliengenerierung an. Denkbar sind

? flagSet(english)

=More than presentations

\PP is no contents managment system, no publishing tool and no text processor, but nevertheless is can be used to perform several tasks in these fields. And even as a presentation tool it can be used for more than just the slide production. Think of


? flagSet(german)

* \B<Präsentationsbegleitende Materialen.> Handouts und Rednernotizen können 
zusammen mit den Folien in \I<einer> Vorlage gepflegt werden. Sie lassen sich 
mit einer Ausgabe in Dokumentenformate (Latex, PostScript, PDF, HTML, ..., 
eventuell über SDF) extrahieren und anschließend ausdrucken. 
\PP-Bedingungen in der Vorlage sorgen dafür, daß Folien- und 
Handout-Ausgaben bei Bedarf sauber getrennt werden oder die Texte in den 
Handouts vielleicht mehr Informationen enthalten als die reinen Schlagwörter 
auf den Folien.

? flagSet(english)

* \B<Presentation supplements.> Handouts and speaker notes can be maintained together with the slide source, in \I<one> document. They can be transformed into the document format of ones choice (Latex, PostScript, PDF, HTML, maybe via SDF) and subsequently printed. \PP conditions control that slide and handout versions are as different as necessary - handouts could provide more details than the usually short slide statements.

? flagSet(german)

* \B<Textverarbeitung.> Das Vorlagenformat ist \I<SDF> nicht unähnlich, und mit 
\I<pp2latex> und \I<pp2sdf> stehen bereits zwei Übersetzer in Formate zur 
Verfügung, aus denen sich direkt oder indirekt gute Druckergebnisse gewinnen 
lassen. Warum sollte man \PP nicht auch als Dokumentenformat oder 
Auszeichnungsspache betrachten? Dieser Artikel ist beispielsweise vollständig 
in \PP verfaßt. Falls man den Text später ganz oder teilweise auch in 
anderen (von Übersetzern direkt oder indirekt abgedeckten) Formaten publizieren 
möchte oder sogar an eine zusätzliche Präsentation der Materialien denkt, kann 
man die bereits gemachten Eingaben gut weiterverwenden. (Es sind sogar 
zukünftige Übersetzer denkbar, die aus mehreren Artikeln ganze Tagungsbände 
oder Ähnliches erzeugen.)

? flagSet(english)

* \B<Text processing.> The source format is similarly structured to SDF, and there are several converters to well printable formats available. Why not treat \PP as a document format or markup language? This article, for example, is completely authored in \PP. A source written today may be partially or completely published in another format in the future, so already written parts will be reusable. Future converters may even allow to produce complete conference materials or something similar from various \PP articles.

? flagSet(german)

* \B<Dokumentation.> Dynamische Inhalte erlauben die Anbindung an Datenbanken 
oder Systemprozesse. Das \I<\\INCLUDE-Tag> gestattet es Projektteams auf 
einfache Weise, Dokumentationen aus beliebig verschachtelten (und auch autonom 
übersetzbaren) Teilvorlagen zusammenzusetzen und auf diese Weise verteiltes 
Wissen koordiniert zu dokumentieren - gegebenenfalls kann ein Redakteur über 
die erneute Erzeugung des Gesamtdokuments entscheiden. Bedingungen in den 
Vorlagen ermöglichen die Beschreibung eines Sachverhalts aus verschiedenen 
Perpektiven (Implementierung, Installation, Anwendung, Support, ...) und die 
anschließende Erzeugung entsprechend spezialisierter Dokumente.

? flagSet(english)

* \B<Documentation.> Dynamic contents allow to make documents out of databases or system states and process results. \C<\\INCLUDE> allows project teams to compose documentations from numerous nested (and standalone usable) partial documents. An editor could control the way a composed document is built. Conditions allow to describe one and the same object from various points of view (implementation, installation, usage, support, ...) and to generate accordingly specialized  documents from a source.

? flagSet(german)

* \B<Schulung.> Mit dem Fortschreiten der Schulung lassen sich durch den 
Einsatz von Bedingungen immer neue Themen anzeigen. Durch die Ausgabe in 
verschiedene Formate (Präsentation und druckbares Format) erzeugt man 
gegebenenfalls aus derselben Vorlage sowohl die Folien als auch die 
Schulungsunterlagen. Lösungen könnten in die Trainerfassung der Präsentation 
integriert, in der an die Trainierten weitergegebenen Fassung aber (zunächst) 
nicht dargestellt sein. Je nach Kurs oder Leistungsniveau kann man Teile ein- 
oder ausblenden. Verschiedene Mitarbeiter des Trainerteams können verschiedene 
Teile der Schulungsunterlagen pflegen.

? flagSet(english)

* \B<Training.> While going on with the lessons, conditions allow to show more and more themes. Various output formats allow to produce both slides and training materials from the same source. Solutions could be integrated into the trainers version, but hidden in the slides made available to trainees. Materials can be easily adapted to the level of a class or a certain training. Several trainers can provide parts of the materials easily.


? flagSet(german)

=Ausblick

Die weitere Entwicklung von \PP wird nicht nur von unseren Ideen, sondern 
auch vom Einsatz durch die Anwender bestimmt. Wir sind neugierig darauf, welche 
Projekte mit der Software verwirklicht werden, welche Möglichkeiten Anwender 
darin entdecken und welche Wünsche sie beim Einsatz äußern.

Auf unserer persönlichen Wunschliste steht ein Generator für XML ganz oben. 
XML-Präsentationen wären noch mächtiger als ihre HTML-Pendants und würden 
(zukünftig) wahrscheinlich noch weit mehr Projektoren finden. Meines Wissens 
soll auch Open Office auf XML-Basis arbeiten - damit könnte \PP dann 
beispielsweise auch Präsentationen für dessen Präsentationskomponente erzeugen.

? flagSet(english)

=Future versions

Further \PP development will not only be determined by our ideas but by the usage which will be made of the tools. We are curious how users realize projects using \PP, which ways of handling they discover and what they ask to be implemented.

Our personal todo list includes a converter to XML. XML presentations would be even more powerful than HTML ones, and there will be a growing number of projectors to display HTML, including Open Office and KPresenter. \PP could then produce presentations to run there as well.


? flagSet(german)

=Anhang

Ohne die ursprüngliche Idee und Software von \I<Tom Christiansen> wäre diese 
Software nicht entstanden. Wir freuen uns auch darüber, daß er uns die 
Verwendung des ursprünglichen Namens für die neue Implementierung gestattet hat.

Diesem Artikel liegen \B<PerlPoint::Package> 0.29 und \B<PerlPoint::Converters> 
0.007 zugrunde. Beide Pakete sind im CPAN erhältlich.

\PP ist zur Zeit ausschließlich in Perl implementiert und läuft deshalb 
überall, wo perl erfolgreich installiert werden kann. Zum Darstellen der 
Ergebnisse ist perl nicht zwingend erforderlich.

Für den freien Windows-Editor "Notetab" steht eine "Clipbook"-Datei zur 
Verfügung, die die \PP-Formatierung unterstützt. Ähnliche Dateien für 
andere Editoren gibt es noch nicht.

? flagSet(english)

=Appendix

This software wouldn't be there without the idea and first implementation by Tom Christiansen. Thanks to him as well that he allowed us to use the \PP name for this new implementation.

This article is based on \BC<\PP::Package> 0.34 and \BC<\PP::Converters> 0.10 which are available on CPAN.

\PP is currently implemented in Perl only and should therefore run everywhere perl can be installed successfully. (This is even true for Windows even if \BC<\PP::Package> tests cannot be performed successfully there at the moment.)

Support libraries for several editors including \C<emacs>, \C<vim> and \C<NoteTab> (Windows) are available and provided with \BC<\PP::Package>.

There's a mailing list to support both users and converter developers. To join, send an empty message to \L{url="mailto:perlpoint-subscribe@perl.org"}<perlpoint-subscribe@perl.org>.


? flagSet(german)

\B<Einige Quellverweise:>

@|
Adresse                                              | Beschreibung
\L{url="http://language.perl.com/misc/perlpoint.notice"}<language.perl.com/misc/perlpoint.notice>              | Toms Anmerkungen zur ersten Version
\L{url="http://ppresenter.org"}<ppresenter.org>                                 | GNU Portable Presenter
\L{url="http://www.mew.org/mgp"}<www.mew.org/mgp>                               | MagicPoint
\L{url="http://www.reportlab.com/demos/pythonpoint/pythonpoint.html"}<www.reportlab.com/demos/pythonpoint/pythonpoint.html> | PythonPoint


? flagSet(english)

\B<Further reading>

@|
Adresse | Beschreibung
\L{url="http://language.perl.com/misc/perlpoint.notice"}<language.perl.com/misc/perlpoint.notice>              | Toms initial announcement
\L{url="http://www.linux-enterprise.de"}<www.linux-enterprise.de> | article "Auf dem Präsentierteller", issue 7/2001
\L{url="http://ppresenter.org"}<ppresenter.org>                                 | GNU Portable Presenter
\L{url="http://www.mew.org/mgp"}<www.mew.org/mgp>                               | MagicPoint
\L{url="http://www.reportlab.com/demos/pythonpoint/pythonpoint.html"}<www.reportlab.com/demos/pythonpoint/pythonpoint.html> | PythonPoint


