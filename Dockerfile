#syntax = docker/dockerfile:1-experimental

#arguments that will be filled during docker build
#for this to work env var DOCKER_BUILDKIT must be set
FROM --platform=${BUILDPLATFORM} golang:1.15.2-alpine AS base 
WORKDIR /src 
ENV CGO_ENABLED=0

#download dependencies to quicken the build time.
#added the go.* files and download the modules before adding the rest of the
#source. This allows Docker to cache the modules as it will only rerun these
#steps if the go.* files change.

COPY go.* .
RUN go mod download

FROM base AS build
ARG TARGETOS
ARG TARGETARCH
#the --mount option attached to the run command. This mount option means that
#each time the go build command is run, the container will have the cache
#mounted to Go's compiler cache folder
RUN --mount=target=. \
    --mount=type=cache,target=/root/.cache/go-build \
    GOOS=${TARGETOS} GOARCH=${TARGETARCH} go build -o /out/dev-env .

#go tests use the same cache as teh build so we mount the cache for this stage
#too. This allows Go to ony run tests if there have been code changes which
#makes teh tests run quicker
FROM base AS unit-test
RUN --mount=target=. \
     --mount=type=cache,target=/root/.cache/go-build \
    go test -v .

#add a linter
#lint-base stage that runs the lint, mounting a cache to the correct place
FROM golangci/golangci-lint:v1.27-alpine AS lint-base

FROM base AS lint
# Performing a COPY will create an extra layer in the container image which
# slows things down and uses extra disk space. This can be avoided by using 
#`RUN --mount` and bind mounting from the build context, from a stage, or an
#image.

#The default mount is a read only bind mount from the context that you pass
#with the `docker build` command. This means that you can replace the `COPY . .`
#with a `RUN --mount=target=.` wherever you need the files from your context to
#run a command but do not need them to persist in the final image
#COPY --from=lint-base /usr/bin/golangci-lint /usr/bin/golangci-lint
RUN --mount=target=. \
    --mount=from=lint-base,src=/usr/bin/golangci-lint,target=/usr/bin/golangci-lint \
    --mount=type=cache,target=/root/.cache/go-build \
    --mount=type=cache,target=/root/.cache/golangci-lint \
    golangci-lint run --timeout 10m0s ./...

#add a cross compiling target
FROM scratch AS bin-unix
COPY --from=build /out/dev-env /

#from bin-unix add aliases for Unix-like OSes ->  Linux(bin-linux) and macOS(bin-darwin)
FROM bin-unix AS bin-linux
FROM bin-unix AS bin-darwin

FROM scratch AS bin-windows
COPY --from=build /out/dev-env /dev-env.exe

#make a dynamic target(bin) that depends on the TARGETOS var automatically set
#by the docker build platform flag
FROM bin-${TARGETOS} AS bin
#CMD ["./dev-env"]
