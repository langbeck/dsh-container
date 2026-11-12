# Image name and tags shared by the justfile and the build module. A module has
# its own variable scope, so both files import this one. Override with the
# IMAGE, BASE_TAG, and TAG environment variables, e.g.
# `IMAGE=my-dsh TAG=dev just build`.
#
# The default names the published image, so a local build produces exactly what
# CI publishes and `just run`/`just web` exercise the same reference users pull.
image := env_var_or_default("IMAGE", "ghcr.io/langbeck/dsh")
base_tag := env_var_or_default("BASE_TAG", "base")
tag := env_var_or_default("TAG", "golang")

# The base image the Go image is built FROM: the base just built locally under
# `image`, so the Go build never reaches out to the registry. CI builds both
# images in one job and passes the same value, keeping the pair in step.
# Override with BASE_IMAGE to build the Go image on some other base.
base_image := env_var_or_default("BASE_IMAGE", image + ":" + base_tag)

# Versions pinned in versions.env, handed to podman as-is. podman's
# --build-arg-file takes exactly that format (KEY=VALUE lines, # comments and
# blank lines ignored) and merges any explicit --build-arg over it, so the file
# needs no translation into a command-line list. This is podman-specific: docker
# has no equivalent, which is why CI extracts the same file in its own step.
build_arg_file := "versions.env"
