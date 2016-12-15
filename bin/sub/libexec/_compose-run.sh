#!/usr/bin/env bash

if [[ $1 == "--no-deps" ]]; then
  shift
  docker-compose run --rm --no-deps qbot $@
else
  docker-compose run --rm qbot $@
fi
