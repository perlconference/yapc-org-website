ARTICLE     = PP-Article/slide0000.htm
GETTIN_STARTED = Getting-started-slides/slide0000.htm
FAQ_PP2HTML = FAQ-pp2html-slides/slide0000.htm
FAQ_PARSER  = FAQ-parser-slides/slide0000.htm
REF_PP2HTML = REF-pp2html-slides/slide0000.htm
CONVERTERS  = wrco/slide0000.htm

all:  $(FAQ_PP2HTML) $(REF_PP2HTML) $(FAQ_PARSER) $(GETTIN_STARTED) $(CONVERTERS) \
      $(ARTICLE)

$(ARTICLE): PP-Article.pp PP-Article.cfg extended.pp translators.pp
	../pp2html @PP-Article.cfg PP-Article.pp

$(GETTIN_STARTED): getting-started.pp getting-started.cfg
	../pp2html @getting-started.cfg getting-started.pp


$(FAQ_PP2HTML): pp2html-faq.pp pp2html-faq.cfg parser-tags.pp tagdoc-supported.pp
	../pp2html @pp2html-faq.cfg pp2html-faq.pp

$(FAQ_PARSER): parser-faq.pp parser-faq.cfg
	../pp2html @parser-faq.cfg parser-faq.pp

$(REF_PP2HTML): pp2html-ref.pp pp2html-ref.cfg pp2html-ref-options.pp doc-functions.pp parser-paragraphs.pp \
         parser-active-contents.pp
	../pp2html @pp2html-ref.cfg pp2html-ref.pp

$(CONVERTERS): writing-converters.pp writing-converters.cfg
	../pp2html @writing-converters.cfg writing-converters.pp

pp2html-ref-options.pp: ../pp2html
	extract_pod.pl ../pp2html > pp2html-ref-options.pp

depend:
	gen_depends > .depends

include .depends
