SHELL=/bin/bash
export GNUMAKEFLAGS=--no-print-directory

.SHELLFLAGS = -o pipefail -c

all: slack-cli-dev
release: slack-cli

######################################################################
### compiling

# for mounting permissions in docker-compose
export UID = $(shell id -u)
export GID = $(shell id -g)

COMPILE_FLAGS=-Dstatic
BUILD_TARGET=
DOCKER=docker-compose run --rm crystal

.PHONY: build
build:
	@$(DOCKER) shards build $(COMPILE_FLAGS) --link-flags "-static" $(BUILD_TARGET) $(O)

.PHONY: slack-cli-dev
slack-cli-dev: BUILD_TARGET=slack-cli-dev
slack-cli-dev: build

.PHONY: slack-cli
slack-cli: BUILD_TARGET=--release slack-cli
slack-cli: build

.PHONY: console
console:
	@$(DOCKER) sh

######################################################################
### gen : Generates API catalog

SLACK_API_DOCS_URL=https://github.com/aki017/slack-api-docs

GEN_SRCS := $(sort $(wildcard gen/slack-api-docs/methods/*.json))
GEN_DSTS := $(sort $(addprefix gen/catalog/,$(basename $(notdir $(GEN_SRCS)))))

.PHONY: gen
gen:
	@make gen/slack-api-docs
	@make gen/catalog.info
	@rm -rf   gen/catalog gen/catalog.cr
	@mkdir -p gen/catalog
	@make gen/catalog
	@make gen/catalog.tsv.gz
	@make gen/catalog.cr

gen/catalog.cr:
	@truncate -s 0 $@
	@echo "def Slack::Api::StaticCatalog.bundled" >> $@
	@echo "c = Slack::Api::StaticCatalog.new" >> $@
	@(cd gen/catalog; (for api in *; do (echo "c.register_json(\"$${api}\", <<-EOF)"; cat "$${api}"; echo "EOF"); done)) >> $@
	@echo "c" >> $@
	@echo "end" >> $@

gen/catalog.tsv.gz:
	@(cd gen/catalog; (for api in *; do (echo -ne "$${api}\t"; cat "$${api}"); done) > ../catalog.tsv)
	@gzip -f gen/catalog.tsv

.PHONY: gen/catalog
gen/catalog: $(GEN_DSTS)

# Extracts fields(desc, args) and Compacts into oneline
gen/catalog/%:gen/slack-api-docs/methods/%.json
	jq -c '{desc, args}' $< > $@

gen/catalog.info: gen/slack-api-docs
	(cd $< && echo "$(SLACK_API_DOCS_URL) `git log --date=format:"%F" --pretty=format:"[%h](%ad)" 2>/dev/null`") > $@

gen/slack-api-docs:
	mkdir gen
	(cd gen && git clone --depth 1 "$(SLACK_API_DOCS_URL).git")

######################################################################
### testing

.PHONY: ci
ci: check_version_mismatch test slack

.PHONY: test
test: spec

.PHONY: spec
spec:
	@$(DOCKER) crystal spec $(COMPILE_FLAGS) -v --fail-fast

.PHONY: check_version_mismatch
check_version_mismatch: README.cr.md shard.yml
	diff -w -c <(grep version: $<) <(grep ^version: shard.yml)

######################################################################
### versioning

VERSION=
CURRENT_VERSION=$(shell git tag -l | sort -V | tail -1)
GUESSED_VERSION=$(shell git tag -l | sort -V | tail -1 | awk 'BEGIN { FS="." } { $$3++; } { printf "%d.%d.%d", $$1, $$2, $$3 }')

.PHONY : version
version: README.cr.md
	@if [ "$(VERSION)" = "" ]; then \
	  echo "ERROR: specify VERSION as bellow. (current: $(CURRENT_VERSION))";\
	  echo "  make version VERSION=$(GUESSED_VERSION)";\
	else \
	  sed -i -e 's/^version: .*/version: $(VERSION)/' shard.yml ;\
	  sed -i -e 's/^    version: [0-9]\+\.[0-9]\+\.[0-9]\+/    version: $(VERSION)/' $< ;\
	  echo git commit -a -m "'$(COMMIT_MESSAGE)'" ;\
	  git commit -a -m 'version: $(VERSION)' ;\
	  git tag "v$(VERSION)" ;\
	fi

.PHONY : bump
bump:
	make version VERSION=$(GUESSED_VERSION) -s
