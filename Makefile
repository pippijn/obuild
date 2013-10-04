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

build:
	@echo "OBuild does not need to be built"

install: $(INSTALLED)

INSTALL := install #--verbose

$(DESTDIR)$(prefix)/bin/obuild:
	@echo "Generating $@"
	@mkdir -p $(@D)
	@echo '#!/bin/sh' > $@
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
