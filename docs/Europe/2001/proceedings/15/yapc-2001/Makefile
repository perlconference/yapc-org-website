
ARTICLE = PP-Article/slide0000.htm
CONVERTERS = wrco/slide0000.htm

all: $(ARTICLE) $(CONVERTERS)

$(ARTICLE): PerlPoint-talk.pp PerlPoint-talk.cfg extended.pp translators.pp
	pp2html @PerlPoint-talk.cfg PerlPoint-talk.pp

$(CONVERTERS): writing-converters.pp writing-converters.cfg
	pp2html @writing-converters.cfg writing-converters.pp
