docs	= cryptoparty-intro
tex_ext	= pdf aux log toc nav snm out

TEX_FLAGS	= -interaction=nonstopmode

TEX2PDF	= pdflatex $(TEX_FLAGS)
DOT2PNG	= dot -Tpng
SVG2PDF = inkscape 
MKIDX	= makeindex
SED	= sed

pdf_docs	= $(patsubst %,%.pdf,$(docs))
dot_figs	= $(wildcard graphs/*.dot)
svg_figs        = $(wildcard images/*.svg)
svgpdf_figs     = $(patsubst %.svg,%.pdf,$(svg_figs))
png_figs	= $(patsubst %.dot,%.png,$(dot_figs))
tex_docs	= $(wildcard *.tex include/*.tex)

targets		= $(pdf_docs)

### helpers

ifeq (1,$(V))
verbose		:= true
else
verbose		:= false
endif

# print output on failure only
define try
tmp=`mktemp`; \
($(1)) >$$tmp; \
ret=$$?; \
if $(verbose) || test $$ret -ne 0; then \
	cat $$tmp; \
fi; \
exit $$ret
endef

### generic rules

.PHONY: all
all: $(targets)

flotum:
	ln -sf about_flotum.tex about.tex
	ln -sf layout_floccc.tex layout.tex
	ln -sf metadata_flotum.tex metadata.tex
	ln -sf outro_floccc.tex outro.tex
	ln -sf email_floccc.tex email.tex

floccc:
	ln -sf about_floccc.tex about.tex
	ln -sf layout_floccc.tex layout.tex
	ln -sf metadata_floccc.tex metadata.tex
	ln -sf outro_floccc.tex outro.tex
	ln -sf email_floccc.tex email.tex

michiccc:
	ln -sf about_michiccc.tex about.tex
	ln -sf layout_michiccc.tex layout.tex
	ln -sf metadata_michiccc.tex metadata.tex
	ln -sf outro_michiccc.tex outro.tex
	ln -sf email_michiccc.tex email.tex

michilit:
	ln -sf about_michiccc.tex about.tex
	ln -sf layout_michiccc.tex layout.tex
	ln -sf metadata_michilit.tex metadata.tex
	ln -sf outro_michiccc.tex outro.tex
	ln -sf email_michiccc.tex email.tex

$(png_figs): %.png: %.dot
	@echo "DOT	$*"; \
	$(DOT2PNG) $^ > $@

$(svgpdf_figs): %.pdf: %.svg
	@echo "SVG      $*"; \
	$(SVG2PDF) --export-pdf=$@ $<

.DELETE_ON_ERROR: $(pdf_docs)
%.pdf: %.tex
	@if test ! -h 'about.tex'; then echo "Select flavour by running 'make <enterFlavourHere>'"; false; fi
	@echo "AUX	$*"; \
	$(call try,cd `dirname $*` && $(TEX2PDF) `basename $*` && cd -)
	@if test -f $*.glo; then \
		echo "GLS	$*"; \
		$(call try,$(MKIDX) $*.glo -s nomencl.ist -o $*.gls 2>&1); \
		$(call try,cd `dirnrame $*` && $(TEX2PDF) `basename $*` && cd -); \
	fi
	@echo "PDF	$*"; \
	$(call try,cd `dirname $*` && $(TEX2PDF) `basename $*` && cd -)

.PHONY: clean
clean:
	@for i in $(docs); do \
		echo "CLEAN	$$i"; \
			for e in $(tex_ext); do \
			rm -f $$i.$$e; \
		done; \
	done; \
	for i in $(dot_figs); do \
		f=`basename $$i .dot`; \
		echo "CLEAN	$$f"; \
		rm -f $$f.png; \
	done; \
	for i in $(svg_figs); do \
		f=`basename $$i .svg`; \
		echo "CLEAN	$$f"; \
		rm -f $$f.pdf; \
	done; \
	rm -f .tex_dep

### automatic dependencies

.tex_dep: $(tex_docs)
	@$(MAKE) --no-print-directory dep

.PHONY: dep
dep:
	@echo "DEP	$@"; \
	for i in $(tex_docs); do \
		echo "$$i:" `$(SED) -n 's#^[^%]*\\includegraphics\(\[[^]]*\]\)\?{\([^}]*\)}.*$$#\2#p' $$i; \
		         $(SED) -n 's/^[^%]*\\input{\([^}]*\)}.*$$/\1/p' $$i; \
		         $(SED) -n 's/^[^%]*\\include{\([^}]*\)}.*$$/\1.tex/p' $$i`; \
		echo "	@touch \$$@"; \
		echo; \
	done > .tex_dep

ifneq ($(MAKECMDGOALS),dep)
-include .tex_dep
endif
