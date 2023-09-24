: "${H_ANYSH_DIR:=$HOME/.anyshrc.d}"
source "$H_ANYSH_DIR/hidden/h-source.sh"
h_source 'util'

H_ANYSH_VERSION='1.0.0'
H_FEATURES_DIR="$H_ANYSH_DIR/features"

h_is_anysh_sourced() {
  return 0
}

h_anysh_ls() {
  local IFS=$'\n'
  local file files=() sep=':' max=0 len
  for file in $(find "$H_FEATURES_DIR" -type f -name '*.sh' -exec basename {} +); do
    file="${file%.sh}"
    if [[ "${file:0:1}" == '.' ]]; then
      files+=("${file#.}${sep}off")
    else
      files+=("$file${sep}on")
    fi

    file="${file#*-}"
    len="${#file}"
    if ((len > max)); then
      max="$len"
    fi
  done

  local name n state style
  for file in $(h_echo "${files[*]}" | sort); do
    file="${file#*-}"
    name="${file%$sep*}"
    ((n = max - ${#name} + 2))
    state="${file##*$sep}"
    if [[ "$state" == 'on' ]]; then
      style="$H_BLUE"
    else
      style=''
    fi
    h_echo "$style${file/$sep$state/$(h_repeat ' ' "$n")$state}$H_RESET"
  done
}

h_anysh_ls_remote() {
  :
}

h_anysh_on() {
  local IFS=$'\n'
  local target="$1" file base name
  for file in $(find "$H_FEATURES_DIR" -type f -name '*.sh'); do
    base="$(basename "$file")"
    name="${base#*-}"
    name="${name%.sh}"
    if [[ "$name" == "$target" ]]; then
      if [[ "${base:0:1}" == '.' ]]; then
        mv "$file" "$(dirname "$file")/${base#.}"
        h_echo "$target is turned on"
      else
        h_echo "$target is already on"
      fi
      return 0
    fi
  done
  h_error -t "$target not found"
  return 1
}

h_anysh_off() {
  local IFS=$'\n'
  local target="$1" file base name
  for file in $(find "$H_FEATURES_DIR" -type f -name '*.sh'); do
    base="$(basename "$file")"
    name="${base#*-}"
    name="${name%.sh}"
    if [[ "$name" == "$target" ]]; then
      if [[ "${base:0:1}" == '.' ]]; then
        h_echo "$target is already off"
      else
        mv "$file" "$(dirname "$file")/.$base"
        h_echo "$target is turned off"
      fi
      return 0
    fi
  done
  h_error -t "$target not found"
  return 1
}

h_anysh_update() {
  :
}

h_anysh_usage() {
  h_error "Run 'anysh help' for more information on the usage."
}

h_anysh_help() {
  h_echo 'Usage:'
  h_echo '  anysh <command> [<arguments...>]'
  h_echo
  h_echo 'Usage by Command:'
  h_echo '  anysh ls [<feature>]         List installed features with their on-off state, matching a given <feature> if provided'
  h_echo '  anysh ls-remote [<feature>]  List remote features available for update with their synchronization state, matching a given <feature> if provided'
  h_echo '  anysh on <feature>           Turn on <feature>'
  h_echo '  anysh off <feature>          Turn off <feature>'
  h_echo '  anysh update [<feature>]     Update features into the latest version, matching a given <feature> if provided'
  h_echo '  anysh version                Display the version of anysh'
  h_echo '  anysh help                   Display this help message'
}

anysh() {
  local cmd="$1"
  shift
  case "$cmd" in
    'ls')        h_anysh_ls "$@";;
    'ls-remote') h_anysh_ls_remote "$@";;
    'on')        h_anysh_on "$@";;
    'off')       h_anysh_off "$@";;
    'update')    h_anysh_update "$@";;
    'version')   h_echo "$H_ANYSH_VERSION";;
    'help')      h_anysh_help;;
    *)
      h_error -t "invalid command: $cmd"
      h_anysh_usage
      return 1
      ;;
  esac
}
