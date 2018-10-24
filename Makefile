VERSION := $(shell git describe --tag --always --dirty)

.PHONY: linter-install
linter-install: ## Install gometalinter
	curl -L https://git.io/vp6lP | sh

.PHONY: setup
setup: ## Install all the build and lint dependencies
	go get -u golang.org/x/tools/cmd/cover

.PHONY: test
test: ## Run all the tests
	echo 'mode: atomic' > coverage.txt && go test -covermode=atomic -coverpkg=./... -coverprofile=coverage.txt -race -timeout=30s ./...

.PHONY: fasttest
fasttest: ## Run short tests
	echo 'mode: atomic' > coverage.txt && go test -short -covermode=atomic -coverprofile=coverage.txt -race -timeout=30s ./...

.PHONY: cover
cover: test ## Run all the tests and opens the coverage report
	go tool cover -html=coverage.txt

.PHONY: fmt
fmt: ## Run goimports on all go files
	find . -name '*.go' -not -wholename './vendor/*' | while read -r file; do goimports -w "$$file"; done

.PHONY: lint
lint: ## Run all the linters
	#linter disabled: gosimple, errcheck, staticcheck
	gometalinter --vendor --disable-all \
		--enable=deadcode \
		--enable=ineffassign \
		--enable=gofmt \
		--enable=goimports \
		--enable=misspell \
		--enable=vet \
		--enable=vetshadow \
		--enable=gosec \
		--deadline=10m \
		./...
#--enable=golint \

.PHONY: ci
ci: lint test ## Run all the tests and code checks

.PHONY: build
build: ## Build a version
	go build -tags=jsoniter -v

.PHONY: clean
clean: ## Remove temporary files
	go clean

.PHONY: install
install: ## install project and it's dependancies, useful for autocompletion feature
	go install -i

.PHONY: version
version: ## display version of gormungandr
	@echo $(VERSION)

# Absolutely awesome: http://marmelab.com/blog/2016/02/29/auto-documented-makefile.html
.PHONY: help
help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.DEFAULT_GOAL := build