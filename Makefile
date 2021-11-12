#!/usr/bin/make -f

SETUP_LETSENCRYPT_GENERATED = "setup-letsencrypt.sh"
SETUP_LETSENCRYPT_TEMPLATE  = "setup-letsencrypt.sh.in"
B64_FILES                   = $(shell cat $(SETUP_LETSENCRYPT_TEMPLATE)  | grep '@B64:.*@' | sed -r -e 's/.*\@B64:([^@]+)\@.*/\1/g')

all: build

build: clean
	@cp $(SETUP_LETSENCRYPT_TEMPLATE) $(SETUP_LETSENCRYPT_GENERATED)
	@for file in $(B64_FILES); do \
	    echo -n "Embedding $$file in setup-letsencrypt.sh ... "; \
	    file_b64=$$(cat $$file | base64); \
	    file_b64=$$(echo $$file_b64 | sed -re 's/\s//g'); \
	    sed -i $(SETUP_LETSENCRYPT_GENERATED) -re "s|\@B64:$$file\@|$$file_b64|g"; \
	    echo "done"; \
	done

clean:
	@echo "Cleaning up (removing previously generated $(SETUP_LETSENCRYPT_GENERATED))"
	@rm -f $(SETUP_LETSENCRYPT_GENERATED)

.PHONY: clean
