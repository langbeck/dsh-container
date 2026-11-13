# Root task runner for this repository. The container image tasks live beside
# the Dockerfile in docker/justfile, which also works standalone from inside
# docker/; exposing it here lets the same recipes be run from the repo root.
#
#   just docker::build          build the published image
#   just docker::build::base    build the harness alone, unpublished
#   just docker::web            serve the Web UI
#   just docker::run <profile>  run dsh with arbitrary arguments
#   just docker::bash           open a shell in the same container
#
# build is a module, so its recipes are selected with `::` -- `just docker::build
# base` would not work, since `base` is a recipe in the build module rather than
# an argument to `build`.
#
# An explicit path is required because docker/ contains a justfile of its own:
# `mod docker` alone would discover that file and then have to be resolved by
# rule, whereas naming the file keeps the module and the file it loads visibly
# the same thing.

set shell := ["bash", "-uc"]

# The container recipes, namespaced so they cannot collide with future
# root-level recipes. Invoke as `just docker::<recipe>`.
mod docker 'docker/justfile'
