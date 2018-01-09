# MAINTAINER: Gorka Lerchundi Osa <g.lerchundi@saltosystems.com>

SHELL   =  /bin/bash
PACKAGE =  github.com/glerchundi/protoc-gen-templater
NAME    =  $(shell echo $(PACKAGE) | rev | cut -d/ -f1 | rev)
PKGS    =  $(shell go list ./... | grep -v /vendor/)
OS      ?= linux darwin windows
APP     =  protoc-gen-template

# Overridable by CI

COMMIT_SHORT     ?= $(shell git rev-parse --verify --short HEAD)
VERSION          ?= $(COMMIT_SHORT)
VERSION_NOPREFIX ?= $(shell echo $(VERSION) | sed -e 's/^[[v]]*//')

#
# Common methodology based targets
#

.PHONY: prepare
prepare: setup-env

.PHONY: sanity-check
sanity-check: fmt lint vet gosimple staticcheck errcheck

.PHONY: build
build:
	@for app in $(APP) ; do \
		for os in $(OS) ; do \
			ext=""; \
			if [ "$$os" == "windows" ]; then \
				ext=".exe"; \
			fi; \
			GOOS=$$os GOARCH=amd64 CGO_ENABLED=1 \
			go build \
				-a -x -tags netgo -installsuffix cgo -installsuffix netgo \
				-ldflags " \
					-X main.Version=$(VERSION_NOPREFIX) \
					-X main.GitRev=$(COMMIT_SHORT) \
				" \
				-o ./bin/$$app-$(VERSION_NOPREFIX)-$$os-amd64$$ext \
				./cmd/$$app; \
		done; \
	done

.PHONY: test
test:
	@echo "Running unit tests..."
	go test -cover -v $(shell echo $(PKGS) | tr " " "\n")

.PHONY: release
release:

.PHONY: clean
clean:
	rm -f ./bin/*
	@for app in $(APP) ; do \
		rm -f cmd/$$app/*-linux-amd64; \
	done

#
# Custom golang project related targets
#

.PHONY: lint
lint:
	@echo "Running golint..."
	@for dir in $(PKGS) ; do golint $$dir; done

.PHONY: gosimple
gosimple:
	@echo "Running gosimple..."
	@gosimple $(PKGS)

.PHONY: fmt
fmt:
	@echo "Running gofmt..."
	@for dir in $(PKGS) ; do \
		res=$$(gofmt -l $(GOPATH)/src/$$dir/. 2>&1 | grep -v $(GOPATH)/src/$$dir/vendor); \
		if [ -n "$$res" ]; then \
			echo -e "gofmt checking failed:\n$$res"; \
			exit 255; \
		fi \
	done

.PHONY: vet
vet:
	@echo "Running go vet..."
	@go vet $(PKGS)

.PHONY: staticcheck
staticcheck:
	@echo "Running staticcheck..."
	@staticcheck $(PKGS)

.PHONY: errcheck
errcheck:
	@echo "Running errcheck..."
	@errcheck $(PKGS)

.PHONY: generate
generate:
	@echo "Running go generate..."
	go generate $(PKGS)

.PHONY: revendor
revendor:
	@echo "Running revendor..."
	dep ensure
	dep prune

.PHONY: setup
setup: setup-env setup-dev

.PHONY: setup-env
setup-env:
	go get -u github.com/golang/lint/golint
	go get -u honnef.co/go/tools/cmd/gosimple
	go get -u honnef.co/go/tools/cmd/staticcheck
	go get -u github.com/kisielk/errcheck

.PHONY: setup-dev
setup-dev:
	go get -u github.com/kevinburke/go-bindata/...
	@if brew ls --versions "dep" >/dev/null; then \
		HOMEBREW_NO_AUTO_UPDATE=1 brew upgrade "dep"; \
	else \
		HOMEBREW_NO_AUTO_UPDATE=1 brew install "dep"; \
	fi
