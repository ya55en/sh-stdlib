#: Main Makefile for the mashmallow-0 project.
#: See https://makefiletutorial.com/


PROJECT_NAME := sh-stdlib

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


.PHONY: bin-shtest setenv
