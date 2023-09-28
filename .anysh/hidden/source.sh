: "${H_ANYSH_DIR:=$HOME/.anyshrc.d}"
__H_FEATURES_DIR="$H_ANYSH_DIR/features"
__H_FEATURES=()

__h_is_release() {
  [ -z "$H_DEBUG" ]
}

__h_source_one() {
  __h_is_release && return 0 # already sourced
  local IFS=$'\n'
  local reset=$'\033[0m' red_bold=$'\033[1;31m' yellow=$'\033[0;33m'
  local target="$1" feature base fname
  ((${#__H_FEATURES[@]} == 0)) && __H_FEATURES=($(find "$__H_FEATURES_DIR" -type f -name '*.sh'))
  for feature in "${__H_FEATURES[@]}"; do
    base="$(basename "$feature")"
    fname="${base#.}"
    fname="${fname%.sh}"
    if [[ "$fname" == "$target" ]]; then
      source "$feature"
      echo >&2 -e "${yellow}warning${reset}: $target just sourced: $feature"
      return 1 # just sourced
    fi
  done
  echo >&2 -e "${red_bold}error${reset}: $target not found"
  return 2 # not found
}

h_source() {
  local __H_FEATURES=()
  local fname r ret=0
  for fname in "$@"; do
    __h_source_one "$fname"; r=$?
    ((r > ret)) && ret="$r"
  done
  return "$ret"
}
