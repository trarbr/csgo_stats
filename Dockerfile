FROM debian:9.11-slim AS builder

RUN apt-get update && \
    apt-get install -y \
    wget \
    gnupg \
    git \
    ssh \
    build-essential \
    curl \
    software-properties-common

# Setup UTF-8
RUN apt-get install -y locales locales-all && \
    locale-gen "en_US.UTF-8"

ENV LANG='en_US.UTF-8' LANGUAGE='en_US:en' LC_ALL='en_US.UTF-8'

# Install Node
ARG NODE_VERSION=12
RUN curl -sL https://deb.nodesource.com/setup_${NODE_VERSION}.x | bash - && \
    apt-get install -y nodejs

# Install Erlang
ARG ERLANG_VERSION=22.1.8-1
RUN wget https://packages.erlang-solutions.com/erlang-solutions_1.0_all.deb && \
    dpkg -i erlang-solutions_1.0_all.deb && \
    apt-get update && \
    apt-get install -y esl-erlang=1:${ERLANG_VERSION}

# Install Elixir
ARG ELIXIR_VERSION=1.9.4-1
RUN apt-get install -y elixir=${ELIXIR_VERSION}

RUN /usr/bin/mix local.hex --force && \
    /usr/bin/mix local.rebar --force && \
    /usr/bin/mix hex.info

WORKDIR /app

COPY assets assets
COPY config config
COPY lib lib
COPY priv priv
COPY mix.exs .
COPY mix.lock .

ENV MIX_ENV=prod

RUN mix do deps.get --only prod, deps.compile && \
    cd assets && \
    npm install && \
    npm run deploy && \
    cd .. && \
    mix phx.digest && \
    mix release

FROM debian:9.11-slim

RUN apt-get update && \
    apt-get install -y openssl

# Setup UTF-8
RUN apt-get install -y locales locales-all && \
    locale-gen "en_US.UTF-8"

ENV LANG='en_US.UTF-8' LANGUAGE='en_US:en' LC_ALL='en_US.UTF-8'

WORKDIR /app

COPY --from=builder /app/_build/prod/rel/* ./

ENTRYPOINT ["/app/bin/csgo_stats", "start"]
