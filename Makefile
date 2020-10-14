all: bin/dev
test:unit-test

PLATFORM=local

.PHONY: bin/dev
bin/dev:
	@docker build . --target bin \
	--output bin/ \
	--platform ${PLATFORM}

.PHONY: uni-test
unit-test:
	@docker build . --target unit-test

.PHONY: lint
lint:
	@docker build . --target lint
