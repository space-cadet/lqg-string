# Makefile for LaTeX project with biblatex/biber
# Project: LQG-String Theory Paper

# Main document name (without .tex extension)
MAIN = lqg-strings

# Additional documents
TEMPLATE = lqg-template
RESPONSE = AoP/response-to-referee

# LaTeX compiler
LATEX = pdflatex
BIBER = biber

# Compilation flags
LATEXFLAGS = -interaction=nonstopmode -halt-on-error -file-line-error
BIBERFLAGS = --validate-datamodel

# Output directory
OUTDIR = PDF

# Source files
TEXFILES = $(MAIN).tex $(TEMPLATE).tex
BIBFILES = $(MAIN).bib $(MAIN)Notes.bib
FIGDIR = figures

# Generated files to clean
AUXFILES = *.aux *.bbl *.bcf *.blg *.fdb_latexmk *.fls *.log *.out *.run.xml *.toc *.tdo *.dep *.dvi

.PHONY: all main template response clean distclean help watch pdf quick

# Default target
all: main

# Main document compilation
main: $(MAIN).pdf

$(MAIN).pdf: $(MAIN).tex $(MAIN).bib
	@echo "Compiling $(MAIN)..."
	$(LATEX) $(LATEXFLAGS) $(MAIN)
	@if grep -q "\\\\bibliography\|\\\\printbibliography" $(MAIN).tex; then \
		echo "Running biber..."; \
		$(BIBER) $(BIBERFLAGS) $(MAIN); \
		echo "Recompiling with bibliography..."; \
		$(LATEX) $(LATEXFLAGS) $(MAIN); \
		$(LATEX) $(LATEXFLAGS) $(MAIN); \
	fi
	@echo "Compilation complete: $(MAIN).pdf"

# Template document
template: $(TEMPLATE).pdf

$(TEMPLATE).pdf: $(TEMPLATE).tex
	@echo "Compiling $(TEMPLATE)..."
	$(LATEX) $(LATEXFLAGS) $(TEMPLATE)
	@if grep -q "\\\\bibliography\|\\\\printbibliography" $(TEMPLATE).tex; then \
		$(BIBER) $(BIBERFLAGS) $(TEMPLATE); \
		$(LATEX) $(LATEXFLAGS) $(TEMPLATE); \
		$(LATEX) $(LATEXFLAGS) $(TEMPLATE); \
	fi

# Response document
response: $(RESPONSE).pdf

$(RESPONSE).pdf: $(RESPONSE).tex
	@echo "Compiling response document..."
	cd AoP && $(LATEX) $(LATEXFLAGS) response-to-referee
	@if [ -f AoP/response-to-referee.bcf ]; then \
		cd AoP && $(BIBER) $(BIBERFLAGS) response-to-referee; \
		cd AoP && $(LATEX) $(LATEXFLAGS) response-to-referee; \
		cd AoP && $(LATEX) $(LATEXFLAGS) response-to-referee; \
	fi

# Quick compilation (single pass, no biber)
quick: $(MAIN).tex
	@echo "Quick compilation (single pass)..."
	$(LATEX) $(LATEXFLAGS) $(MAIN)

# Move PDF to output directory
pdf: main
	@mkdir -p $(OUTDIR)
	@cp $(MAIN).pdf $(OUTDIR)/
	@echo "PDF moved to $(OUTDIR)/"

# Watch mode using latexmk
watch:
	@echo "Starting watch mode (Ctrl+C to stop)..."
	latexmk -pdf -pvc -interaction=nonstopmode $(MAIN)

# Clean auxiliary files
clean:
	@echo "Cleaning auxiliary files..."
	rm -f $(AUXFILES)
	rm -f AoP/*.aux AoP/*.bbl AoP/*.bcf AoP/*.blg AoP/*.log AoP/*.out AoP/*.run.xml

# Clean everything including PDFs
distclean: clean
	@echo "Cleaning all generated files..."
	rm -f $(MAIN).pdf $(TEMPLATE).pdf
	rm -f AoP/response-to-referee.pdf
	rm -rf $(OUTDIR)

# Count words (requires texcount)
wordcount:
	@if command -v texcount >/dev/null 2>&1; then \
		echo "Word count for $(MAIN).tex:"; \
		texcount -brief $(MAIN).tex; \
	else \
		echo "texcount not found. Install with: tlmgr install texcount"; \
	fi

# Check for common LaTeX errors
check:
	@echo "Checking for common issues..."
	@if grep -n "\\\\cite{.*,.*}" $(MAIN).tex; then \
		echo "Warning: Found multi-citations that might need brackets"; \
	fi
	@if grep -n "\\\\ref{.*}" $(MAIN).tex | grep -v "\\\\autoref\|\\\\eqref"; then \
		echo "Info: Found \\ref commands (consider \\autoref or \\eqref)"; \
	fi

# Archive for submission
archive: clean main
	@echo "Creating submission archive..."
	@mkdir -p submission
	@cp $(MAIN).tex $(MAIN).bib $(MAIN).pdf submission/
	@if [ -d figures ]; then cp -r figures submission/; fi
	@if [ -f revtex4-2.cls ]; then cp revtex4-2.cls submission/; fi
	@tar -czf $(MAIN)-submission-$(shell date +%Y%m%d).tar.gz submission/
	@rm -rf submission
	@echo "Archive created: $(MAIN)-submission-$(shell date +%Y%m%d).tar.gz"

# Debug biber issues
debug-bib:
	@echo "Debugging bibliography..."
	$(LATEX) $(LATEXFLAGS) $(MAIN)
	$(BIBER) --debug $(MAIN)

# Help message
help:
	@echo "Available targets:"
	@echo "  all        - Compile main document (default)"
	@echo "  main       - Compile $(MAIN).tex"
	@echo "  template   - Compile $(TEMPLATE).tex"
	@echo "  response   - Compile response document"
	@echo "  quick      - Quick single-pass compilation"
	@echo "  pdf        - Compile and move PDF to $(OUTDIR)/"
	@echo "  watch      - Watch mode with automatic recompilation"
	@echo "  clean      - Remove auxiliary files"
	@echo "  distclean  - Remove all generated files"
	@echo "  wordcount  - Count words in document"
	@echo "  check      - Check for common LaTeX issues"
	@echo "  archive    - Create submission archive"
	@echo "  debug-bib  - Debug bibliography issues"
	@echo "  help       - Show this help message"
