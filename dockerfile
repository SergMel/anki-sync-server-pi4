# Dockerfile
FROM rustlang/rust:nightly-slim AS builder

RUN apt-get update && \
    apt-get install -y \
    protobuf-compiler \
    libsqlite3-dev \
    pkg-config \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app
RUN cargo init --bin
COPY Cargo.toml .
RUN cargo fetch

RUN cargo install --locked \
    --git https://github.com/ankitects/anki.git \
    --branch main \
    --target aarch64-unknown-linux-gnu \
    anki-sync-server

FROM debian:bookworm-slim

RUN apt-get update && \
    apt-get install -y \
    libsqlite3-0 \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

COPY --from=builder /usr/local/cargo/bin/anki-sync-server /usr/local/bin/

VOLUME /data
ENV SYNC_BASE=/data
EXPOSE 27701
CMD ["anki-sync-server"]
