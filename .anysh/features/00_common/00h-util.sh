H_RESET=$'\033[0m'
H_BLACK=$'\033[0;30m'
H_BLACK_BOLD=$'\033[1;30m'
H_RED=$'\033[0;31m'
H_RED_BOLD=$'\033[1;31m'
H_GREEN=$'\033[0;32m'
H_YELLOW=$'\033[0;33m'
H_BLUE=$'\033[0;34m'

h_is_util_sourced() {
  return 0
}

h_is_debug() {
  [ -n "$H_DEBUG" ]
}

h_is_release() {
  [ -z "$H_DEBUG" ]
}

h_is_bash() {
  [ -n "${BASH_VERSION}" ]
}

h_is_zsh() {
  [ -n "${ZSH_VERSION}" ]
}

h_is_linux() {
  [[ "$(uname -s)" == 'Linux' ]]
}

h_is_mac() {
  [[ "$(uname -s)" == 'Darwin' ]]
}

h_echo() {
  echo -e "$@"
}

h_error() {
  [[ "$1" == '-t' ]] && { >&2 h_echo -n "${H_RED_BOLD}error${H_RESET}: "; shift; }
  >&2 h_echo "$@"
}

h_warn() {
  [[ "$1" == '-t' ]] && { >&2 h_echo -n "${H_YELLOW}warning${H_RESET}: "; shift; }
  >&2 h_echo "$@"
}

h_shell() {
  ps -p $$ | tail -1 | awk '{ print $4 }'
}

h_shell_name() {
  local sh
  sh="$(h_shell)"
  if [[ "${sh:0:1}" == '-' ]]; then
    h_echo "${sh:1}"
  else
    basename "$sh"
  fi
}

h_repeat() {
  local i out
  for ((i == 0; i < $2; ++i)); do
    out+="$1"
  done
  h_echo "$out"
}

h_split_by() {
  if h_is_zsh; then
    eval "${3:-$2}"='("${(@s/'"$1"'/)'"$2"'}")'
  else
    IFS="$1" read -ra "${3:-$2}" <<< "${!2}"
  fi
}

h_join_array_by() {
  local IFS="$1"
  eval h_echo '"${'"$2"'[*]}"'
}

h_join_elems_by() {
  local IFS="$1"
  shift
  h_echo "$*"
}

h_in_array() {
  local target="$1" elem
  eval set -- '"${'"$2"'[@]}"'
  for elem in "$@"; do
    [[ "$elem" == "$target" ]] && return 0
  done
  return 1
}

h_in_elems() {
  local target="$1" elem
  shift
  for elem in "$@"; do
    [[ "$elem" == "$target" ]] && return 0
  done
  return 1
}

h_test_style() {
  h_echo "${H_BLACK}black${H_RESET}"
  h_echo "${H_BLACK_BOLD}black bold${H_RESET}"
  h_echo "${H_RED}red${H_RESET}"
  h_echo "${H_RED_BOLD}red bold${H_RESET}"
  h_echo "${H_GREEN}green${H_RESET}"
  h_echo "${H_YELLOW}yellow${H_RESET}"
  h_echo "${H_BLUE}blue${H_RESET}"
}
