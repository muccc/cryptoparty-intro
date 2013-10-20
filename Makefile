docs	= cryptoparty-intro
tex_ext	= pdf aux log toc nav snm

TEX_FLAGS	= -interaction=nonstopmode

TEX2PDF	= pdflatex $(TEX_FLAGS)
DOT2PNG	= dot -Tpng
MKIDX	= makeindex
SED	= sed

pdf_docs	= $(patsubst %,%.pdf,$(docs))
dot_figs	= $(wildcard graphs/*.dot)
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

$(png_figs): %.png: %.dot
	@echo "DOT	$*"; \
	$(DOT2PNG) $^ > $@

.DELETE_ON_ERROR: $(pdf_docs)
%.pdf: %.tex
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
