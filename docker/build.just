# Image build recipes, declared as `mod build` by the justfile beside this
# file. Invoke as `just build` (both images), `just build base`, or
# `just build golang`.
#
# Versions come from versions.env, passed as --build-arg-file so the file is the
# single source of truth and needs no per-version flags. Override one for a
# single run with an explicit --build-arg, which podman merges over the file:
#   podman build ... --build-arg-file versions.env --build-arg DSH_VERSION=0.2.3
# Every recipe is one line so `just --dry-run` prints the exact podman command.

# Modules do not inherit the parent justfile's variables, so import the shared
# image name/tags; the recipes below run in this directory, so the Dockerfiles
# and the build context resolve as written.
import 'images.just'

# Build both images: the base image first, then the Go image on top.
default: base golang

# Build the base image.
base:
    podman build --file base.dockerfile --build-arg-file {{build_arg_file}} --tag {{image}}:{{base_tag}} .

# BASE_IMAGE is passed explicitly rather than left to the Dockerfile default, so
# the Go image sits on the base this justfile just built rather than a stale one
# from the registry.
#
# Build the Go image on top of the base.
golang: base
    podman build --file golang.dockerfile --build-arg-file {{build_arg_file}} --build-arg BASE_IMAGE={{base_image}} --tag {{image}}:{{tag}} .
