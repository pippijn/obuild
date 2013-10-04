prefix ?= /usr/local

TARGET := $(DESTDIR)$(prefix)/share/obuild

SUBDIRS := licences rules script
FILES :=					\
	$(shell find $(SUBDIRS) -type f)	\
	debian/camlp4-3.12.patch		\
	debian/rules.common			\
	CONTRIBUTING.md				\
	COPYING.MPL-2.0				\
	README.md

INSTALLED := $(addprefix $(TARGET)/,$(FILES))
INSTALLED += $(DESTDIR)$(prefix)/bin/obuild
INSTALLED += $(DESTDIR)$(prefix)/lib/obuild/oquery

build: src/oquery.native

clean:
	ocamlbuild -clean

src/oquery.native: $(wildcard src/*.ml*)
	cd $(@D) && ocamlbuild -use-menhir -use-ocamlfind $(@F)

install: $(INSTALLED)

INSTALL := install #--verbose

$(DESTDIR)$(prefix)/lib/obuild/oquery: src/oquery.native
	@mkdir -p $(@D)
	@$(INSTALL) --mode 755 $< $@

$(DESTDIR)$(prefix)/bin/obuild:
	@echo "Generating $@"
	@mkdir -p $(@D)
	@echo '#!/bin/sh' > $@
	@echo 'export OBUILD_LIBDIR="$(prefix)/lib/obuild"' >> $@
	@echo 'exec $(prefix)/share/obuild/script/obuild "$$@"' >> $@

$(TARGET)/rules/%: rules/%
	@mkdir -p $(@D)
	@$(INSTALL) --mode 644 $< $@

$(TARGET)/script/%: script/%
	@mkdir -p $(@D)
	@$(INSTALL) --mode 755 $< $@

$(TARGET)/debian/%: debian/%
	@mkdir -p $(@D)
	@$(INSTALL) --mode 644 $< $@

$(TARGET)/licences/%: licences/%
	@mkdir -p $(@D)
	@$(INSTALL) --mode 644 $< $@

$(TARGET)/%: %
	@mkdir -p $(@D)
	@$(INSTALL) --mode 644 $< $@
