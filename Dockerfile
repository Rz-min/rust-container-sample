##FROM alpine:latest

FROM rust:1.60 as builder

WORKDIR ./sample-app
COPY ./sample-app/src ./src
COPY ./sample-app/Cargo.toml ./Cargo.toml
RUN USER=root cargo build --release

FROM debian:buster-slim
ARG APP=/usr/src/APP

RUN apt-get update \
    && apt-get install -y ca-certificates \
    && rm -rf /var/lib/apt/lists/*

EXPOSE 8000

ENV APP_USER=appuser

RUN groupadd ${APP_USER} \
    && useradd -g ${APP_USER} ${APP_USER} \
    && mkdir -p ${APP}

COPY --from=builder /sample-app/target/release/sample-app ${APP}/sample-app

RUN chown -R ${APP_USER}:${APP_USER} ${APP}

USER ${APP_USER}
WORKDIR ${APP}

CMD ["./sample-app"]
