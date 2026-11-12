# Image build recipes, declared as `mod build` by the justfile beside this
# file. Invoke as `just build` (both images), `just build base`, or
# `just build golang`.

# Modules do not inherit the parent justfile's variables, so import the shared
# image name/tags; the recipes below run in this directory, so the Dockerfiles
# and the build context resolve as written.
import 'images.just'

# Build both images: the base image first, then the Go image on top.
default: base golang

# Build the base image.
base:
    podman build --file base.dockerfile --tag {{image}}:{{base_tag}} .

# Build the Go image on top of the base.
golang: base
    # BASE_IMAGE is passed explicitly rather than left to the Dockerfile default,
    # so the Go image sits on the base this justfile just built instead of
    # pulling a stale one from the registry.
    podman build --file golang.dockerfile --build-arg BASE_IMAGE={{base_image}} --tag {{image}}:{{tag}} .
