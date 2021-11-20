#: Main Makefile for the sh-stdlib project.
#: See https://makefiletutorial.com/

PROJECT_NAME := sh-stdlib

# current build version
_version_ := $(shell ./scripts/dump-version.sh)

# current branch
branch := $(shell git branch --no-color --show-current)

# Anything in src/ matters for re-creating the dist tarball (but install.sh)
EXCLUDED := install.sh
SOURCES := $(shell find ./src/ -type f -name "*" -a ! -name $(EXCLUDED) -a ! -wholename "src/bin/*")
DISTFILE := ./dist/sh-stdlib-v$(_version_).tgz


$(DISTFILE):  $(SOURCES)
	@echo "_version_=[$(_version_)]"
	@for f in $(SOURCES); do echo $$f; done
	@echo $(_version_) > ./src/version
	@[ -d ./dist/ ] || mkdir -p ./dist
	@rm -f $(DISTFILE)
	@tar czvf $(DISTFILE) -C src --exclude=$(EXCLUDED) --exclude='*/bin/*' .
	@echo "Created $(DISTFILE)."


dist:  $(DISTFILE)


clean-dist:
	rm -r ./dist


clean-all:  clean-dist


#: Create symlink src/bin/shtest -> src/unittest/shtest
bin-shtest:
	@if [ -e src/bin/shtest ]; then : \
	; else \
		mkdir -p src/bin \
			&& cd src/bin \
			&& ln -s ../unittest/shtest \
	;fi

#: Set environment variables so that this project's mash is active.
#: (Do "eval `make setenv`" to get these variables take effect.)
setenv:  bin-shtest
	@./scripts/4make/setenv.sh


.PHONY: bin-shtest setenv clean-dist clean-all
