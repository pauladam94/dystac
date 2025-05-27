PHONY: ex clean

watch_html:
	typst watch example.typ --features html --format html --open
watch_pdf:
	typst watch example.typ --features html --format pdf --open
ex:
	typst compile --features html --format html example.typ examples/index.html 

clean:
	rm examples/*
