all: bin/dev
test:unit-test
export DOCKER_BUILDKIT = 1 

PLATFORM=local

.PHONY: bin/dev
bin/dev:
	@DOCKER_BUILDKIT=1 docker build . --target bin \
	--output bin/ \
	--platform ${PLATFORM}

.PHONY: uni-test
unit-test:
	@DOCKER_BUILDKIT=1 docker build . --target unit-test

.PHONY: lint
lint:
	@DOCKER_BUILDKIT=1 docker build . --target lint
