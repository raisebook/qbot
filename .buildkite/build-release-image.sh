#!/usr/bin/env bash

set -eo pipefail

ECS_CLUSTER=$(buildkite-agent meta-data get "ecs-cluster")

case ${ECS_CLUSTER} in
  default)
    DOCKER_TAG_PREFIX=production
    export MIX_ENV=prod
    ;;
  production)
    DOCKER_TAG_PREFIX=production
    export MIX_ENV=prod
    ;;
  *)
    DOCKER_TAG_PREFIX=${ECS_CLUSTER}
    export MIX_ENV=${ECS_CLUSTER}
esac

buildkite-agent meta-data set "docker-tag-prefix" ${DOCKER_TAG_PREFIX}

IMAGE=038451313208.dkr.ecr.ap-southeast-2.amazonaws.com/qbot:${DOCKER_TAG_PREFIX}-${BUILDKITE_COMMIT:-local}

function inline_image {
  printf '\033]1338;url='"$1"';alt='"$2"'\a\n'
}

if [[ $(docker network ls | grep --count raisebook_raisebook-dev-net) -eq 0 ]]; then
  docker network create raisebook_raisebook-dev-net
fi

echo "--- Building the Elixir Release bundle"
bin/qbot mix deps.get
bin/qbot build-release

echo "--- Building the Production Docker image"
# Fix the 'root' owner permissions on the distillery produced binaries
# They get that way because they were built inside of a docker container, with weird uid mappings
sudo /usr/bin/fix-buildkite-agent-builds-permissions "${BUILDKITE_AGENT_NAME}" "raisebook" "qbot"

VOLUME_CONTAINER=$(docker create -v qbot_elixir_build:/_build alpine)
docker cp "${VOLUME_CONTAINER}":/_build/${MIX_ENV}/rel ./_release
docker rm "${VOLUME_CONTAINER}"

docker build --build-arg MIX_ENV=${MIX_ENV} -t "${IMAGE}" -f Dockerfile.release .
docker push "${IMAGE}"

inline_image 'http://i.giphy.com/l3vRi71UbYn4PXcKk.gif' 'SHIPIT'
