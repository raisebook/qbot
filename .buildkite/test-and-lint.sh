#!/usr/bin/env bash

set -eo pipefail

function inline_image {
  printf '\033]1338;url='"$1"';alt='"$2"'\a\n'
}

function celebrate {
 if [[ $? == 0 ]]; then
   inline_image 'https://i.giphy.com/hTh9bSbUPWMWk.gif' 'PARTYPARROT'
 else
   inline_image 'https://media.giphy.com/media/3oGRFHSFa8CjBnAmOs/giphy.gif' 'FAIL'
 fi
}
trap celebrate EXIT

if [[ $(docker network ls | grep --count raisebook_raisebook-dev-net) -eq 0 ]]; then
  docker network create raisebook_raisebook-dev-net
fi

bin/qbot mix deps.get
bin/qbot test
bin/qbot lint

