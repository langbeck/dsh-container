# Image name and tags shared by this justfile and the build module. A module has
# its own variable scope, so both files import this one. Override with the IMAGE,
# BASE_TAG, and TAG environment variables, e.g. `IMAGE=my-dsh TAG=dev just build`.
#
# The default names the published image, so a local build produces exactly what
# CI publishes and `just run`/`just web` exercise the same reference users pull.
image := env_var_or_default("IMAGE", "ghcr.io/langbeck/dsh")

# Only one image is published, so `latest` is what a plain pull resolves to.
# BASE_TAG names the tag the base-only recipe uses; the base is not published,
# so its tag only ever exists locally.
base_tag := env_var_or_default("BASE_TAG", "base")
tag := env_var_or_default("TAG", "latest")

# Versions pinned in versions.env, handed to podman as-is. podman's
# --build-arg-file takes exactly that format (KEY=VALUE lines, # comments and
# blank lines ignored) and merges any explicit --build-arg over it, so the file
# needs no translation into a command-line list. This is podman-specific: docker
# has no equivalent, which is why CI extracts the same file in its own step.
build_arg_file := "versions.env"
