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
COPY . .  

FROM base AS build
ARG TARGETOS
ARG TARGETARCH
#the --mount option attached to the run command. This mount option means that
#each time the go build command is run, the container will have the cache
#mounted to Go's compiler cache folder
RUN --mount=type=cache,target=/root/.cache/go-build \
GOOS=${TARGETOS} GOARCH=${TARGETARCH} go build -o /out/dev-env .

#go tests use the same cache as teh build so we mount the cache for this stage
#too. This allows Go to ony run tests if there have been code changes which
#makes teh tests run quicker
FROM base AS unit-test
RUN --mount=type=cache,target=/root/.cache/go-build \
go test -v .


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
