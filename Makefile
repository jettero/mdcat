PREFIX := /usr/local
INSTALL := sudo install
NAMES  := mdcat mdless mdpick
DOCS   := README.md CHANGELOG.md LICENSE config.toml.example
OUT    := target/dist
BIN    := $(PREFIX)/bin
MAN1   := $(PREFIX)/man/man1
DOC    := $(PREFIX)/share/doc/mdcat
BASH   := $(PREFIX)/share/bash-completion/completions
ZSH    := $(PREFIX)/share/zsh/site-functions
FISH   := $(PREFIX)/share/fish/vendor_completions.d

FILES  := $(NAMES:%=$(BIN)/%) $(NAMES:%=$(MAN1)/%.1.gz) $(DOCS:%=$(DOC)/%) \
	$(NAMES:%=$(BASH)/%) $(NAMES:%=$(ZSH)/_%) $(NAMES:%=$(FISH)/%.fish)

.PHONY: install uninstall
install: $(FILES)

uninstall:
	sudo rm -fvd $(FILES) $(DOC)

# generated artifacts

target/release/mdless target/release/mdpick: target/release/mdcat
	ln -sf mdcat $@

$(OUT):
	install -d $@

$(OUT)/mdcat.1.gz: mdcat.1.adoc | $(OUT)
	asciidoctor -b manpage -a reproducible -o - $< | gzip -n > $@

$(OUT)/%.bash: target/release/% | $(OUT)
	$< --completions bash > $@

$(OUT)/_%: target/release/% | $(OUT)
	$< --completions zsh > $@

$(OUT)/%.fish: target/release/% | $(OUT)
	$< --completions fish > $@

# installed files

$(BIN) $(MAN1) $(DOC) $(BASH) $(ZSH) $(FISH):
	$(INSTALL) -d -o 0 -g 0 -m 0755 $@

$(BIN)/mdcat: target/release/mdcat | $(BIN)
	$(INSTALL) -o 0 -g 0 -m 0755 $< $@

$(BIN)/mdless $(BIN)/mdpick: $(BIN)/mdcat
	ln -sf mdcat $@

$(MAN1)/mdcat.1.gz: $(OUT)/mdcat.1.gz | $(MAN1)
	$(INSTALL) -o 0 -g 0 -m 0644 $< $@

$(MAN1)/mdless.1.gz $(MAN1)/mdpick.1.gz: $(MAN1)/mdcat.1.gz
	ln -sf mdcat.1.gz $@

$(DOC)/%: % | $(DOC)
	$(INSTALL) -o 0 -g 0 -m 0644 $< $@

$(BASH)/%: $(OUT)/%.bash | $(BASH)
	$(INSTALL) -o 0 -g 0 -m 0644 $< $@

$(ZSH)/_%: $(OUT)/_% | $(ZSH)
	$(INSTALL) -o 0 -g 0 -m 0644 $< $@

$(FISH)/%.fish: $(OUT)/%.fish | $(FISH)
	$(INSTALL) -o 0 -g 0 -m 0644 $< $@
