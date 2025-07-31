.PHONY: clean all

TYP_FILES := $(wildcard *.typ)
HTML_FILES := $(TYP_FILES:.typ=.html)
PDF_FILES := $(TYP_FILES:.typ=.pdf)

all: $(HTML_FILES) $(PDF_FILES)

# Rule to build .html from .typ
%.html: examples/%.typ
	typst compile --root . --features html --format html $< $@

# Rule to build .pdf from .typ
%.pdf: examples/%.typ
	typst compile --root . --features html --format pdf $< $@

clean:
	rm -f *.html *.pdf */*.pdf */*.html
