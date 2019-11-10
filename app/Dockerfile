# Latest version of Erlang-based Elixir installation: https://hub.docker.com/_/elixir/
FROM elixir:1.9-alpine

# Create and set home directory
ENV HOME /opt/backend
WORKDIR $HOME

RUN mkdir -p /app
ARG VERSION=0.1.0
COPY _build /app
WORKDIR /app
ENV PORT 4000
CMD ["/app/prod/rel/grafik/bin/grafik", "start"]
