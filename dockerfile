
# Dockerfile
FROM --platform=linux/arm64 rust:1.75-slim-bookworm AS builder

RUN apt-get update && \
    apt-get install -y protobuf-compiler libsqlite3-dev && \
    rm -rf /var/lib/apt/lists/*

RUN cargo install --locked --git https://github.com/ankitects/anki.git anki-sync-server

FROM --platform=linux/arm64 debian:bookworm-slim

RUN apt-get update && \
    apt-get install -y libsqlite3-0 ca-certificates && \
    rm -rf /var/lib/apt/lists/*

COPY --from=builder /usr/local/cargo/bin/anki-sync-server /usr/local/bin/

VOLUME /data
ENV SYNC_BASE=/data
EXPOSE 27701

CMD ["anki-sync-server"]
