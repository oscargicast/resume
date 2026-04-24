## --- Resume sources --------------------------------------------------------
MAIN       := resume
TEX        := $(MAIN).tex
PDF        := $(MAIN).pdf
BUILD_DIR  := build
SECTIONS   := $(wildcard sections/*.tex)
ASSETS     := $(wildcard assets/*)

## --- Cover-letter sources --------------------------------------------------
## Every cover-letters/<slug>/cover-letter.tex yields cover-letters/<slug>/cover-letter.pdf
## via the pattern rule below. Add a new letter by creating a new <slug>/ folder.
COVER_LETTERS_DIR   := cover-letters
COVER_LETTER_COMMON := $(COVER_LETTERS_DIR)/_common/cover-letter-preamble.tex
COVER_LETTER_SRCS   := $(wildcard $(COVER_LETTERS_DIR)/*/cover-letter.tex)
COVER_LETTER_PDFS   := $(COVER_LETTER_SRCS:.tex=.pdf)

## --- Toolchain -------------------------------------------------------------
LATEXMK       := latexmk
LATEXMK_FLAGS := -pdf -interaction=nonstopmode -halt-on-error \
                 -output-directory=$(BUILD_DIR)

.PHONY: all view watch clean distclean help cover-letters docs
.DEFAULT_GOAL := all

## --- Resume targets --------------------------------------------------------
all: $(PDF) ## Compile the resume to $(PDF)

$(PDF): $(TEX) $(SECTIONS) $(ASSETS) | $(BUILD_DIR)
	$(LATEXMK) $(LATEXMK_FLAGS) $(TEX)
	@cp $(BUILD_DIR)/$(PDF) $(PDF)

$(BUILD_DIR):
	@mkdir -p $@

view: $(PDF) ## Compile and open the PDF in the default viewer
	@open $(PDF)

watch: | $(BUILD_DIR) ## Rebuild continuously on file changes (latexmk -pvc)
	$(LATEXMK) -pvc $(LATEXMK_FLAGS) $(TEX)

## --- Cover-letter targets --------------------------------------------------
cover-letters: $(COVER_LETTER_PDFS) ## Compile every cover-letters/*/cover-letter.tex

## Pattern rule: one invocation per cover-letter. Runs latexmk from inside the
## letter's folder so `\input{../_common/cover-letter-preamble.tex}` resolves,
## writes intermediates under build/, then copies the PDF next to the source.
$(COVER_LETTERS_DIR)/%/cover-letter.pdf: $(COVER_LETTERS_DIR)/%/cover-letter.tex $(COVER_LETTER_COMMON)
	@mkdir -p $(BUILD_DIR)/$(COVER_LETTERS_DIR)/$*
	cd $(COVER_LETTERS_DIR)/$* && $(LATEXMK) -pdf -interaction=nonstopmode -halt-on-error \
		-output-directory=../../$(BUILD_DIR)/$(COVER_LETTERS_DIR)/$* cover-letter.tex
	@cp $(BUILD_DIR)/$(COVER_LETTERS_DIR)/$*/cover-letter.pdf $@

## --- Aggregate + maintenance ----------------------------------------------
docs: all cover-letters ## Compile the resume and every cover letter

clean: ## Remove build artifacts (keeps committed $(PDF) and cover-letter PDFs)
	rm -rf $(BUILD_DIR)

distclean: clean ## Also remove generated $(PDF) and cover-letter PDFs
	rm -f $(PDF)
	rm -f $(COVER_LETTER_PDFS)

help: ## Show this help
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  \033[36m%-14s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)
