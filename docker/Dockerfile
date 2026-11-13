# The DSH image, as one file with two stages.
#
#   base    the harness plus the tools every session needs, no language
#           toolchain. Not published.
#   golang  the base plus the Go toolchain and gopls. This is what is published,
#           as ghcr.io/langbeck/dsh.
#
# The published image is built FROM the base in the same file, so a
# `--target golang` build always uses the base from the same source revision
# rather than one fetched from a registry. Keeping `base` a named stage is also
# what lets the harness be built and tested on its own. Selecting a stage and
# naming the output is the caller's job:
#
#   docker build --target base   --tag dsh-base .
#   docker build --target golang --tag ghcr.io/langbeck/dsh:latest .

# The Ubuntu base, overridable so an exact digest can be pinned without editing
# this file: --build-arg UBUNTU_IMAGE=ubuntu@sha256:<digest>. Left as a mutable
# tag by default, since a digest would also freeze out security updates.
ARG UBUNTU_IMAGE=ubuntu:26.04

FROM ${UBUNTU_IMAGE} AS base

# Re-declared after FROM, where build args actually become visible to RUN.
ARG UBUNTU_IMAGE

# The base that was actually used, recorded so a built image can be traced back
# to it without consulting the build log.
ENV DSH_UBUNTU_IMAGE=${UBUNTU_IMAGE}

ENV DEBIAN_FRONTEND=noninteractive

# Core packages. `just` is not reliably packaged in every Ubuntu release, so it
# is installed from its official release tarball below instead of apt.
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        git \
        jq \
        procps \
        ripgrep \
        unzip \
        xz-utils \
        libatomic1 \
    && rm -rf /var/lib/apt/lists/*

ARG JUST_VERSION=1.36.0
RUN curl -fsSL "https://github.com/casey/just/releases/download/${JUST_VERSION}/just-${JUST_VERSION}-x86_64-unknown-linux-musl.tar.gz" \
        | tar -xz -C /usr/local/bin just \
    && just --version

# Install node via nvm
ENV NVM_DIR=/root/.nvm
ARG NODE_VERSION=26.13.1
ARG COREPACK_VERSION=0.36.0
ARG NVM_VERSION=0.41.0
ARG NPM_VERSION=12.2.2

RUN curl -o- "https://raw.githubusercontent.com/nvm-sh/nvm/v${NVM_VERSION}/install.sh" | bash \
    && . "$NVM_DIR/nvm.sh" \
    && nvm install ${NODE_VERSION} \
    && nvm alias default ${NODE_VERSION}

# Add the installed Node version to PATH
ENV PATH="$NVM_DIR/versions/node/v$NODE_VERSION/bin:$PATH"

# Update npm
RUN npm install -g npm@${NPM_VERSION}

# Install DSH. Pinned exactly: npm's `latest` dist-tag currently points at an
# older release than `next`, so an unpinned install would silently build a
# different harness than the version named here.
ARG DSH_VERSION=0.2.2-rc.2
RUN npm config set allow-scripts=@deepseek-ai/dsh-subprocess-local,koffi,node-pty,@google/genai,protobufjs --location=user
RUN npm install -g "@deepseek-ai/dsh@${DSH_VERSION}" \
    && dsh --version

# Use corepack to cleanly enable and lock down pnpm. The version is explicit
# because a bare `pnpm` resolves from corepack's bundled known-good table, whose
# contents depend on COREPACK_VERSION and cannot be read off this file.
ARG PNPM_VERSION=12.18.0
RUN npm install -g corepack@${COREPACK_VERSION}
ENV COREPACK_ENABLE_DOWNLOAD_PROMPT=0
RUN corepack enable \
    && corepack install --global pnpm@${PNPM_VERSION} \
    && pnpm --version

ENTRYPOINT ["dsh"]


FROM base AS golang

# Every build argument used above has to be re-declared inside a stage that
# needs it; only those the Go stage itself references are repeated here.

# Go toolchain. gopls v0.24.0 declares `go 1.27.0`, so the distro's Go package
# is too old to build it; install the official toolchain instead.
ARG GO_VERSION=1.27.3
ARG TARGETARCH=amd64
RUN curl -fsSL "https://go.dev/dl/go${GO_VERSION}.linux-${TARGETARCH}.tar.gz" -o /tmp/go.tgz \
    && tar -C /usr/local -xzf /tmp/go.tgz \
    && rm /tmp/go.tgz

ENV GOROOT=/usr/local/go
ENV GOPATH=/root/go
# Appended rather than prepended so the base stage's Node binaries keep
# precedence.
ENV PATH="$PATH:$GOROOT/bin:$GOPATH/bin"

# gopls: the MCP server (`gopls mcp`) needs both `go` and the gopls binary on
# PATH at runtime, since gopls shells out to the toolchain to load packages.
ARG GOPLS_VERSION=v0.24.0
RUN go install "golang.org/x/tools/gopls@${GOPLS_VERSION}" \
    && go version \
    && gopls version \
    && go clean -cache -modcache
