#!/usr/bin/env bash

set -eo pipefail

export ECS_CLUSTER=$(buildkite-agent meta-data get "ecs_cluster")
export DOCKER_TAG_PREFIX=$(buildkite-agent meta-data set "docker_tag_prefix")

docker-compose run --rm deployment ./deploy_ecs.rb
