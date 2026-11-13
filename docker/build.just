# Image build recipes, declared as `mod build` by the justfile beside this
# file. Invoke as `just build` (both images), `just build base`, or
# `just build golang`.
#
# Both images come from the single Dockerfile beside this file, selected by
# --target. The golang stage declares `FROM base`, so building it rebuilds the
# base inside the same build and the two can never drift.
#
# Versions come from versions.env, passed as --build-arg-file so the file is the
# single source of truth and needs no per-version flags. Override one for a
# single run with an explicit --build-arg, which podman merges over the file:
#   podman build ... --build-arg-file versions.env --build-arg DSH_VERSION=0.2.3
# Every recipe is one line so `just --dry-run` prints the exact podman command.

# Modules do not inherit the parent justfile's variables, so import the shared
# image name/tags; the recipes below run in this directory, so the Dockerfile
# and the build context resolve as written.
import 'images.just'

# Build both images.
default: base golang

# Build the base image, without any language toolchain.
base:
    podman build --file Dockerfile --target base --build-arg-file {{build_arg_file}} --tag {{image}}:{{base_tag}} .

# Build the Go image, which includes the base built from the same source.
golang:
    podman build --file Dockerfile --target golang --build-arg-file {{build_arg_file}} --tag {{golang_image}}:{{tag}} .
