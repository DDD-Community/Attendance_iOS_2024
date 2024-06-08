GENERATE = tuist generate
FETCH = tuist fetch
BUILD = tuist build
CACHE = tuist cache BeatMaster
CLEAN = tuist clean
INSTALL = tuist install

CURRENT_DATE = $(shell run scripts/current_date.swift)

# Define your targets and dependencies

.PHONY: generate
generate:
	 TUIST_ROOT_DIR=${PWD} $(GENERATE)

.PHONY: build
build: $(CLEAN) $(FETCH) $(FETCH) TUIST_ROOT_DIR=${PWD} $(GENERATE)

.PHONY: clean
clean:
	$(CLEAN)

.PHONY: fetch
install:
	$(INSTALL)

.PHONY: cache

cache:
	 $(CACHE)


module:
	tuist scaffold  $(template) \
         --layer ${layer} \
	 --name ${name} \
	 --author "서원지"
	 	 

# Additional targets can be added as needed
