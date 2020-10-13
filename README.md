# go_CI-CD
## Containerize Go env

Sample Go application to demonstrate the use of Docker to define a Go Development environment in code.

The Dockerfile is configured in a way to shrink the build context (add `.dockerignore` file) to speed up the build time.

It also uses caching by seperating the downloading of dependencies from the build step.

It uses the experimental [builkit](https://docs.docker.com/develop/develop-images/build_enhancements/).
