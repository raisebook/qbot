if [[ ! -o interactive ]]; then
    return
fi

compctl -K _qbot qbot

_qbot() {
  local word words completions
  read -cA words
  word="${words[2]}"

  if [ "${#words}" -eq 2 ]; then
    completions="$(qbot commands)"
  else
    completions="$(qbot completions "${word}")"
  fi

  reply=("${(ps:\n:)completions}")
}
