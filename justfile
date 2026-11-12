# Root task runner for this repository. The container image tasks live beside
# the Dockerfiles in docker/justfile, which also works standalone from inside
# docker/; exposing it here lets the same recipes be run from the repo root.
#
#   just docker::build          build both images (base, then Go)
#   just docker::build base     build only the base image
#   just docker::build golang   build the Go image (and the base it needs)
#   just docker::web            serve the Web UI
#   just docker::run <profile>  run dsh with arbitrary arguments
#   just docker::bash           open a shell in the same container
#
# An explicit path is required because docker/ contains a justfile of its own:
# `mod docker` alone would discover that file and then have to be resolved by
# rule, whereas naming the file keeps the module and the file it loads visibly
# the same thing.

set shell := ["bash", "-uc"]

# The container recipes, namespaced so they cannot collide with future
# root-level recipes. Invoke as `just docker::<recipe>`.
mod docker 'docker/justfile'
