
// Verfügbare Übersetzer

// vim: set filetype=pp2html :

? flagSet(german)

Derzeit stehen folgende Übersetzer zur Verfügung:

* pp2html

* pp2latex

* pp2sdf

Die folgenden Abschnitte gehen kurz auf die jeweiligen Besonderheiten dieser Übersetzer
ein.

\B<pp2html> und \B<pp2latex> befinden sich in der Distribution \B<PerlPoint::Converters>,
und \B<pp2sdf> ist Bestandteil der \B<PerlPoint::Package>-Distribution. Beide Pakete sind im CPAN erhältlich. 
Das Programm \C<pp2html> ist schon relativ stabil während \C<pp2latex> noch als Alpha-Software 
zu bezeichen ist. Immerhin wurde die Druckvorlage des vorliegenden Artikels durch \C<pp2latex> 
aus einem PerlPoint-Eingabtext erzeugt.

? flagSet(english)

At the moment, the following converters are available:

* pp2html

* pp2latex

* pp2sdf

* pp2cppp

The following chapters explain shortly some of the features of these PerlPoint converters.

\BC<pp2html> and \BC<pp2latex> are containted in the \BC<PerlPoint::Converters> distribution, while \BC<pp2sdf> and \BC<pp2cppp> are part of the \BC<PerlPoint::Package> distribution. Both
packages are available on CPAN.
\C<pp2html> is already in use for real world projects but \C<pp2latex> is still alpha software.
Nevertheless, the LaTeX file for this article has already been produced with \C<pp2latex>.


? flagSet(german)


==pp2html

Das Perlscript \C<pp2html> ist das bisher umfangreichste Übersetzungsprogramm für das
PerlPoint-Format. \C<pp2html> erzeugt aus einer PerlPoint-Vorlage einen Satz von HTML-Dateien.
Abhängig von den verwendeten Optionen und Template-Dateien kann das Ergebnis sehr unterschiedlich
gestaltet sein: Verschiedene Farbgebung, Verwendung von Framesets, unterschiedliche Schriftgrößen
oder Javscript-Applets im Inhaltsverzeichnis können je nach Art des Zieldokuments sinnvoll
eingesetzt werden. Das folgende Beispiel zeigt eine Seite aus einer umfangreichen
Schulungsunterlage, die vollständig in PerlPoint erstellt wurde:

\IMAGE{src="../images/pp2html.gif" alt="Beispiel für pp2html-Ausgabe" epsfysize=14cm}

\B<Textauszeichnungen:>

\C<pp2html> definiert die folgenden Tags zur Auszeichnung von Text:


<<EOT
\B< .... >        Bold              
\I< .... >        Italic            
\C< .... >        Code              
\SUB< ... >       Subscript (tief gestellt)
\SUP< ... >       Superscript (hochgestellt)
\U< .... >        Unterstrichen
\E< html escape > z.B. \E<uuml>
EOT

? flagSet(english)

==pp2html

The Perl program \C<pp2html> is until now the most enhanced tranlator program for the PerlPoint format.
\C<pp2html> generates a set of HTML files. Dependent on a variety of options and template files, the results
can look quite different. Different colors, background images, frame sets, different text sizes
or a Java Applet for the table of contents are layout elements which can be used to create a variety of
documents. The following example shows a page from a Perl course, which has been written completely in
PerlPoint.

\IMAGE{src="../images/pp2html.gif" alt="example for pp2html-output" epsfysize=14cm}

\B<Text Formatting:>

<<EOT
\B< .... >        Bold              
\I< .... >        Italic            
\C< .... >        Code              
\SUB< ... >       Subscript
\SUP< ... >       Superscript
\U< .... >        Underlined
\E< html escape > z.B. \E<uuml>
EOT

? flagSet(german)

Beispielcode und verbatime Blöcke werden bei \C<pp2html> in farbig hinterlegten Textblöcken
dargestellt. Dies wird im der HTML-Ausgabe durch Tabellen mit farbigen Zellen erreicht.
Die Farbe dieser Textblöcke sowie die darin verwendete Textfarbe ist auf blau und weiß voreingestellt.
Mit Hilfe der speziellen Tags

 \\BOXCOLORS{bg=yellow fg=blue}

kann man die Farben für jede Textbox individuell einstellen.
Textfarbe und Größe lassen sich mit folgendem Tag beeinflussen:

<<EOT
 \F{color=red size=3}< .... >
EOT

? flagSet(english)

Example code and verbatime blocks are presented in a colored boxes in \C<pp2html>.
This is achieved by HTML tables with colored cells. The color of the cells and the text color
in these cells can be individually influenced by the \\BOXCOLORS tag:

 \\BOXCOLORS{bg=yellow fg=blue}

The default settings for background and foreground color are grey and black. The colors can
be reset to their default values with

 \\BOXCOLORS{set=default}


? flagSet(german)

\B<Anker, Hyperlinks, Images:>

Damit man interne Hyperlinks und Querverweise verwenden kann,
muß man sog. Link-Targets oder Anker im laufenden Text einfügen.
Dazu dient das \C<\\A>-Tag:

<<EOT
\A{name="name"}
EOT

Für jede Seitenüberschrift wird automatisch ein solcher Anker
definiert, damit man sich bequem darauf beziehen kann:

<<EOT
\PAGEREF{name="name"}     interner Hyperlink mit Seitennummer als Text

\SECTIONREF{name="name"}  interner Hyperlink mit Page Header als Text
                          wobei \A{name="name"> ein Anker auf der 
                          betreffenden Seite ist
EOT

Hyperlinks auf externe Seiten kann man auf folgende Weise definieren:

<<EOT
\L{url="http://....."}<link text>
EOT


? flagSet(english)

\B<Anchors, Hyperlinks, Images:>

To use internal hyperlinks and cross references, you must insert so called
\I<anchors> or link targets in your text. This is achieved by the \C<\\A> tag.

<<EOT
\A{name="name"}
EOT

For each page header such an anchor is automatically inserted, to make things easy.
The \I<names> of these page anchors are simply the headers of the pages:

<<EOT
\PAGEREF{name="page header"}     internal hyperlink with page number as text

\SECTIONREF{name="page header"}  internal hyperlink with page header as text
                                 \A{name="name"> is an anchor on the 
                                 corresponding page
EOT

Hyperlinks to external pages can be defined with the following tag:

<<EOT
\L{url="http://....."}<link text>
EOT

? flagSet(german)


Bilder werden mit dem \C<\\IMAGE> Tag eingebunden:

<<EOT
\IMAGE{alt="Cool picture of xzy" align="left" src="xyz.gif"}

\IMAGE{src="xyz.gif"}      default für alt ist "Image xyz.gif"
                           (bei HTML als Zielsprache, bei anderen hat der
                           alt-Parameter ev. gar keine Bedeutung)
EOT

Zu beachten ist hier, daß die Pfadnamen für die Bilddateien relativ zu dem mit
der \C<--slide_dir>-Option definierten Verzeichnis anzugeben sind. Das mit \C<--slide_dir>
gewählte Verzeichnis bestimmt, wo \C<pp2html> die HTML-Dateien ablegt.

? flagSet(english)

Images are included with the \C<\\IMAGE> tag:

<<EOT
\IMAGE{alt="Cool picture of xzy" align="left" src="xyz.gif"}

\IMAGE{src="xyz.gif"}      default for alt is "Image xyz.gif"
                           (with HTML as target language; with other target
                           languages the alt parameter may have no effect)
EOT

Note that the pathnames for the image files must be relative to the PerlPoint
input file which contains the \C<\\IMAGE> tag or they must be specified absolutely.

? flagSet(german)


\B<Querverweise und Index Erzeugung:>

Querverweise werden mit dem \\XREF-Tag erzeugt:

<<EOT
  \XREF{name=target}<Text für den Querverweis>
EOT

Für Indexeinträge gibt es das \\X-Tag:

<<EOT
\X< ... >                    Worte erscheinen im Index und im fortlaufenden Text
\X{mode="index_only"}< ... > Worte erscheinen nur im Index
EOT

Der Index wird automatisch am Ende des Dokuments erstellt, es sei denn,
man hat die \C<--no_index> Option von \C<pp2html> benutzt.


? flagSet(english)

\B<Cross References and Generation of Index:>

Cross references are created with the \C<\\XREF> tag:

<<EOT
  \XREF{name=target}<text for cross reference>
EOT

For index entries there is the following tag:

<<EOT
\X< ... >                    words are included in index and in output text
\X{mode="index_only"}< ... > words are included in index only
EOT

The index is created automatically at the end of the document unless the
\C<--no_index> option of \C<pp2html> has been used.


? flagSet(german)


\B<Sonstige Tags:>

Zeilenumbrüche und die berühmten "horizontal lines" in HTML lassen sich durch folgende
Tags erzwingen:

<<EOT
   \LINE_BREAK     alias \BR
   \HR
EOT

Neben den Tags gibt es eine Vielzahl von Optionen, über die sich \C<pp2html> steuern läßt.
Praktischerweise schreibt man diese Optionen in eine Steuerdatei, z.B. \I<pp2html.cfg> und ruft
\C<pp2html> dann wie folgt auf:

 pp2html @pp2html.cfg vorlage.pp

Weitere Informationen liefert der Aufruf von \C<pp2html> mit der \C<--help> Option.

? flagSet(english)

\B<Other Tags:>

Line breaks and the known \I<horizontal lines> in HTML can be achieved be the
following tags:

<<EOT
   \LINE_BREAK     alias \BR
   \HR
EOT

Beside the tags, there are many options in \C<pp2html> which allow to control the appearance of the output.
It is useful to write those options in options files (control files) which can be specified on the
command line while starting the \C<pp2html> program:

 pp2html @pp2html.cfg perlpoint.pp

In this example, all relevant options are contained in the file \I<pp2html.cfg>.
More information about the options of \C<pp2html> can be seen when calling the program
with the \C<--help> switch.

? flagSet(german)


==pp2latex und pp2sdf

Für die Erstellung von druckbaren Ergebnissen sind \C<pp2latex> und \C<pp2sdf> von einiger
Bedeutung. PerlPoint-Vorlagen, die für \C<pp2html> erstellt wurden, sollten ohne größere Probleme
auch von \C<pp2latex> und \C<pp2sdf> verarbeitet werden.

\C<pp2latex> ist noch ziemlich unflexibel, was die Dokumentklassen angeht. In der jetzigen Version
wird einfach ein \B<article>-Vorspann ausgegeben. Beim \C<\\IMAGE>-Tag ist zu beachten, daß man
für jedes verwendete \B<.gif>-File auch ein entsprechendes \B<.eps> anlegen sollte.
\C<pp2latex> bindet dann automatisch diese Postscriptdatei mit ein. Zur Steuerung der Größe
kann man die \I<epsfxsize>- bzw. \I<epsfysize>-Parameter im \C<\\IMAGE>-Tag angeben:

<<EOT
 \IMAGE{epsfxsize=14cm src="../images/PerlPoint-Structure.gif"}
EOT


? flagSet(english)

==pp2latex and pp2sdf

\C<pp2latex> and \C<pp2sdf> can be used for the preparation of printable output formats.
PerlPoint file which have been written for \C<pp2html> should be readable by \C<pp2latex> and \C<ppsdf>.

\C<pp2latex>  is still relatively inflexible concerning document classes. It is possible to supply a
template file which determines the document class and provides a certain setup, but there are 
not many examples. If you use images you should supply an \B<.eps> file for each \B<.gif> or \B<.jpeg> file.
\C<pp2latex> will then automatically inlucde these Postscript files in the LaTeX output.
For controlling the  size, you can use the \I<epsfxsize> or \I<epsfysize> parameter in the \C<\\IMAGE> tag:

<<EOT
 \IMAGE{epsfxsize=14cm src="./images/PerlPoint-Structure.gif"}
EOT

