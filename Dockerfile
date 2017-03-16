FROM elixir:1.4

RUN mkdir -p /app/deps

WORKDIR /app

RUN mix local.hex --force
RUN mix local.rebar --force

COPY . /app

COPY bin/tini-static /tini-static
ENTRYPOINT ["/tini-static", "--"]
CMD ["/app/dev-entrypoint.sh"]
