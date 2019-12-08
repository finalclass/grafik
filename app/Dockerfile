FROM elixir:1.9.4-alpine

RUN mix local.hex --force && \
    mix local.rebar --force

RUN apk add --update nodejs nodejs-npm gzip curl

RUN curl -L -o elm.gz "https://github.com/elm/compiler/releases/download/0.19.1/binary-for-linux-64-bit.gz" \
        && gunzip elm.gz \
        && chmod +x elm \
        && mv elm /usr/local/bin/

ENV MIX_ENV=prod
ARG SECRET_KEY_BASE
ARG DATABASE_URL
ARG X_FCSTORE_SECRET

WORKDIR /srv/app
COPY ./ /srv/app/

# install dependencies (production only)
RUN mix local.rebar --force
RUN mix deps.get --only prod

RUN mix compile

# RUN npm install --global webpack
RUN cd assets && npm install && npm run deploy
RUN mix phx.digest

RUN mix distillery.release

# alpine version should be the same as build
FROM alpine:3.10
RUN apk add --update bash
ENV REPLACE_OS_VARS=true
WORKDIR /srv/app
COPY --from=0  /srv/app/_build/prod/ .
CMD rel/grafik/bin/grafik foreground
