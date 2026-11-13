# Image build recipes, declared as `mod build` by the justfile beside this
# file. Invoke as `just build` (the published image) or `just build base` (the
# harness alone, for testing without the Go toolchain).
#
# Both targets come from the single Dockerfile beside this file. The golang
# stage declares `FROM base`, so it always sits on the base built from the same
# source, and `base` remains available on its own even though only golang is
# published.
#
# Versions come from versions.env, passed as --build-arg-file so the file is the
# single source of truth and needs no per-version flags. Override one for a
# single run with an explicit --build-arg, which podman merges over the file:
#   podman build ... --build-arg-file versions.env --build-arg DSH_VERSION=0.2.3
# Every recipe is one line so `just --dry-run` prints the exact podman command.

# Modules do not inherit the parent justfile's variables, so import the shared
# image name; the recipes below run in this directory, so the Dockerfile and the
# build context resolve as written.
import 'images.just'

# Build the published image, which is the golang stage.
default: golang

# The stage is FROM base, so the base is produced inside this same build rather
# than reused from an earlier one, and nothing is pulled.
#
# Build the image that gets published.
golang:
    podman build --file Dockerfile --target golang --build-arg-file {{build_arg_file}} --tag {{image}}:{{tag}} .

# Build the harness alone, without the Go toolchain. Not published.
base:
    podman build --file Dockerfile --target base --build-arg-file {{build_arg_file}} --tag {{image}}:{{base_tag}} .
