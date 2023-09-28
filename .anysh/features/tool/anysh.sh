: "${H_ANYSH_DIR:=$HOME/.anyshrc.d}"
source "$H_ANYSH_DIR/hidden/source.sh"
h_source 'util'

H_ANYSH_VERSION='1.0.0'
H_FEATURES_DIR="$H_ANYSH_DIR/features"

h_anysh_get_groups() {
  find "$H_FEATURES_DIR" -depth 1 -type d -exec basename {} +
}

h_anysh_in_groups() {
  count="$(find "$H_FEATURES_DIR" -depth 1 -type d -name "$1" | wc -l | awk '{ print $1 }')"
  ((count > 0))
}

h_anysh_get_features() {
  local target="$1"
  if [ -z "$target" ]; then
    find "$H_FEATURES_DIR" -type f -name '*.sh' -exec bash -c "x='{}'; echo \"\${x#$H_FEATURES_DIR/}\"" \;
  elif [[ "${target:0:1}" == ':' ]]; then
    target="${target:1}"
    if ! h_anysh_in_groups "$target"; then
      h_error -t "invalid group: $target"
      return 1
    fi
    find "$H_FEATURES_DIR/$target" -type f -name '*.sh' -exec bash -c "x='{}'; echo \"\${x#$H_FEATURES_DIR/}\"" \;
  else
    # khs working here...
    # Consider to change the invalid group error just like the invalid feature error
    # Reference: https://unix.stackexchange.com/questions/198254/make-find-fail-when-nothing-was-found
    find "$H_FEATURES_DIR" -type f \( -name "$target.sh" -o -name ".$target.sh" \) -exec bash -c "x='{}'; echo \"\${x#$H_FEATURES_DIR/}\"" \; | grep '.'
    if [ $? -ne 0 ]; then
      h_error -t "invalid feature: $target"
      return 1
    fi
  fi
}

h_anysh_ls() {
  local IFS=$'\n'
  local file files=() sep=':' max=0 len
  for file in $(h_anysh_find_features_basename); do
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

  local fname n state style
  for file in $(h_echo "${files[*]}" | sort); do
    file="${file#*-}"
    fname="${file%$sep*}"
    ((n = max - ${#fname} + 2))
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
  local feature="$1" file base fname
  for file in $(h_anysh_find_features); do
    base="$(basename "$file")"
    fname="${base#*-}"
    fname="${fname%.sh}"
    if [[ "$fname" == "$feature" ]]; then
      if [[ "${base:0:1}" == '.' ]]; then
        mv "$file" "$(dirname "$file")/${base#.}"
        h_echo "$feature is turned on"
      else
        h_echo "$feature is already on"
      fi
      return 0
    fi
  done
  h_error -t "$feature not found"
  return 1
}

h_anysh_off() {
  local IFS=$'\n'
  local feature="$1" file base fname
  for file in $(h_anysh_find_features); do
    base="$(basename "$file")"
    fname="${base#*-}"
    fname="${fname%.sh}"
    if [[ "$fname" == "$feature" ]]; then
      if [[ "${base:0:1}" == '.' ]]; then
        h_echo "$feature is already off"
      else
        mv "$file" "$(dirname "$file")/.$base"
        h_echo "$feature is turned off"
      fi
      return 0
    fi
  done
  h_error -t "$feature not found"
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
