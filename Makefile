prefix ?= /usr/local

TARGET := $(DESTDIR)$(prefix)/share/obuild

FILES :=				\
	licences/COPYING.AGPL-3.0	\
	licences/COPYING.GPL-2.0	\
	licences/COPYING.GPL-3.0	\
	licences/COPYING.LGPL-3.0	\
	licences/COPYING.MPL-2.0	\
	rules/build/aldor/compile.om	\
	rules/build/aldor/configure.om	\
	rules/build/aldor/library.om	\
	rules/build/aldor/program.om	\
	rules/build/aldor/testsuite.om	\
	rules/build/c/compile.om	\
	rules/build/c/configure.om	\
	rules/build/c/library.om	\
	rules/build/c/pkg-config.om	\
	rules/build/c/program.om	\
	rules/build/ocaml/compile.om	\
	rules/build/ocaml/configure.om	\
	rules/build/ocaml/install.om	\
	rules/build/ocaml/library.om	\
	rules/build/ocaml/meta.om	\
	rules/build/ocaml/pack.om	\
	rules/build/ocaml/program.om	\
	rules/build/aldor.om		\
	rules/build/c.om		\
	rules/build/common.om		\
	rules/build/java.om		\
	rules/build/latex.om		\
	rules/build/ocaml.om		\
	rules/codegen/atdgen.om		\
	rules/codegen/dypgen.om		\
	rules/codegen/foamj.om		\
	rules/codegen/glrgen.om		\
	rules/codegen/graphviz.om	\
	rules/codegen/js_of_ocaml.om	\
	rules/codegen/lablgtk2.om	\
	rules/codegen/lex.om		\
	rules/codegen/menhir.om		\
	rules/codegen/merr.om		\
	rules/codegen/msgcat.om		\
	rules/codegen/noweb.om		\
	rules/codegen/ocamllex.om	\
	rules/codegen/protobuf.om	\
	rules/codegen/re2ml.om		\
	rules/codegen/treematch.om	\
	rules/codegen/yacc.om		\
	rules/codegen/zacc.om		\
	rules/target/check.om		\
	rules/target/clean.om		\
	rules/target/common.om		\
	rules/target/install.om		\
	rules/target/library.om		\
	rules/target/program.om		\
	rules/target/recurse.om		\
	rules/util/mlmake.om		\
	rules/util/timer.om		\
	rules/collect-targets.om	\
	rules/common.om			\
	rules/configure.om		\
	rules/default.om		\
	rules/messages.om		\
	script/mlmake/automake.ml	\
	script/mlmake/configure.ml	\
	script/mlmake/target.ml		\
	script/aldep			\
	script/aldepex			\
	script/check-format		\
	script/clean-noweb		\
	script/dcmm			\
	script/ditz-browse		\
	script/levenshtein.c		\
	script/obuild			\
	script/prepare-tree		\
	script/remake			\
	script/runmerr			\
	script/testdriver		\
	script/testissues		\
	script/testreport		\
	script/travis-depend		\
	script/update-licences		\
	CONTRIBUTING.md			\
	COPYING.MPL-2.0			\
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
	@echo 'exec $(prefix)/share/obuild/script/obuild' >> $@

$(TARGET)/rules/%: rules/%
	@mkdir -p $(@D)
	@$(INSTALL) --mode 644 $< $@

$(TARGET)/script/mlmake/%: script/mlmake/%
	@mkdir -p $(@D)
	@$(INSTALL) --mode 644 $< $@

$(TARGET)/script/%: script/%
	@mkdir -p $(@D)
	@$(INSTALL) --mode 755 $< $@

$(TARGET)/licences/%: licences/%
	@mkdir -p $(@D)
	@$(INSTALL) --mode 644 $< $@

$(TARGET)/%: %
	@mkdir -p $(@D)
	@$(INSTALL) --mode 644 $< $@
