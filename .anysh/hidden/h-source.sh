: "${H_ANYSH_DIR:=$HOME/.anyshrc.d}"
H_FEATURES_DIR="$H_ANYSH_DIR/features"
__H_SOURCE_FILES=()

__h_is_debug() {
  [ -n "$H_DEBUG" ]
}

__h_source_one() {
  local IFS=$'\n'
  local reset=$'\033[0m' red_bold=$'\033[1;31m' yellow=$'\033[0;33m'
  local feature="$1" file base name
  if __h_is_debug || ! h_is_"$feature"_sourced 2> /dev/null; then
    ((${#__H_SOURCE_FILES[@]} == 0)) && __H_SOURCE_FILES=($(find "$H_FEATURES_DIR" -type f -name '*.sh'))
    for file in "${__H_SOURCE_FILES[@]}"; do
      base="$(basename "$file")"
      name="${base#*-}"
      name="${name%.sh}"
      if [[ "$name" == "$feature" ]]; then
        if [[ "${base:0:1}" == '.' ]]; then
          echo >&2 -e "${red_bold}error${reset}: $feature is off"
          return 2 # turned off (error)
        else
          source "$file"
          echo >&2 -e "${yellow}warning${reset}: $feature just sourced: $file"
          return 1 # just sourced (debug)
        fi
      fi
    done
    echo >&2 -e "${red_bold}error${reset}: $feature not found"
    return 3 # not found (error)
  fi
  return 0 # already sourced (release)
}

h_source() {
  local __H_SOURCE_FILES=()
  local name r ret=0
  for name in "$@"; do
    __h_source_one "$name"; r=$?
    ((r > ret)) && ret="$r"
  done
  return "$ret"
}
