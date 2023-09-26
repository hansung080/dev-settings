: "${H_ANYSH_DIR:=$HOME/.anyshrc.d}"
H_FEATURES_DIR="$H_ANYSH_DIR/features"
__H_SOURCE_FILES=()

__h_is_debug() {
  [ -n "$H_DEBUG" ]
}

__h_source_one() {
  local IFS=$'\n'
  local reset=$'\033[0m' red_bold=$'\033[1;31m' yellow=$'\033[0;33m'
  local feature="$1" file base fname
  if __h_is_debug || ! h_is_"$feature"_sourced 2> /dev/null; then
    ((${#__H_SOURCE_FILES[@]} == 0)) && __H_SOURCE_FILES=($(find "$H_FEATURES_DIR" -type f -name '*.sh'))
    for file in "${__H_SOURCE_FILES[@]}"; do
      base="$(basename "$file")"
      fname="${base#*-}"
      fname="${fname%.sh}"
      if [[ "$fname" == "$feature" ]]; then
        if __h_is_debug || [[ "${base:0:1}" != '.' ]]; then
          source "$file"
          echo >&2 -e "${yellow}warning${reset}: $feature just sourced: $file"
          return 1 # just sourced (debug)
        else
          echo >&2 -e "${red_bold}error${reset}: $feature is off"
          return 2 # turned off (error)
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
  local fname r ret=0
  for fname in "$@"; do
    __h_source_one "$fname"; r=$?
    ((r > ret)) && ret="$r"
  done
  return "$ret"
}
