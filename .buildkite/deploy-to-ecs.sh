#!/usr/bin/env bash

set -eo pipefail

export ECS_CLUSTER=$(buildkite-agent meta-data get "ecs-cluster")
export DOCKER_TAG_PREFIX=$(buildkite-agent meta-data get "docker-tag-prefix")

docker-compose run --rm deployment ./deploy_ecs.rb
