# DSH base image: the harness plus the tools every session needs, with no
# language-specific toolchain. Language images (e.g. golang.dockerfile) build
# on top of this one.
#
# Published as ghcr.io/langbeck/dsh:base.

# The Ubuntu base, overridable so an exact digest can be pinned without editing
# this file: --build-arg UBUNTU_IMAGE=ubuntu@sha256:<digest>. Left as a mutable
# tag by default, since a digest would also freeze out security updates.
ARG UBUNTU_IMAGE=ubuntu:26.04
FROM ${UBUNTU_IMAGE}

# Re-declared after FROM, where build args actually become visible to RUN.
ARG UBUNTU_IMAGE

# Ubuntu release name, recorded so the built image can be traced back to a base
# without consulting the build log.
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
