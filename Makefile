all: bin/dev
test:unit-test
export DOCKER_BUILDKIT = 1 

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
