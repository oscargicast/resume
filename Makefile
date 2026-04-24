MAIN       := resume
TEX        := $(MAIN).tex
PDF        := $(MAIN).pdf
BUILD_DIR  := build
SECTIONS   := $(wildcard sections/*.tex)
ASSETS     := $(wildcard assets/*)

LATEXMK       := latexmk
LATEXMK_FLAGS := -pdf -interaction=nonstopmode -halt-on-error \
                 -output-directory=$(BUILD_DIR)

.PHONY: all view watch clean distclean help
.DEFAULT_GOAL := all

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

clean: ## Remove build artifacts (keeps committed $(PDF))
	rm -rf $(BUILD_DIR)

distclean: clean ## Also remove the generated $(PDF) at repo root
	rm -f $(PDF)

help: ## Show this help
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  \033[36m%-10s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)
