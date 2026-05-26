# Build stage
FROM rust:1.95.0-trixie@sha256:f49565f188ee00bc2a18dd418183f2c5f23ef7d6e691890517ed341a598f67c3 AS builder

WORKDIR /usr/src/git-mirror

# Copy only necessary files for build
COPY Cargo.toml Cargo.lock ./
COPY src src

# Build application
RUN cargo install --path .

# Runtime stage
FROM debian:13.5-slim@sha256:b6e2a152f22a40ff69d92cb397223c906017e1391a73c952b588e51af8883bf8

# Install dependencies and clean up in single RUN
RUN set -eux ; \
    apt-get update -qq ; \
    apt-get install -qqy --no-install-recommends git-core git-lfs ; \
    apt-get clean ; \
    rm -rf /var/lib/apt/lists/* ;

WORKDIR /usr/local/bin
COPY --from=builder /usr/local/cargo/bin/git-mirror .
