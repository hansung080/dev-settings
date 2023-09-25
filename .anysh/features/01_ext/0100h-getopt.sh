: "${H_ANYSH_DIR:=$HOME/.anyshrc.d}"
source "$H_ANYSH_DIR/hidden/h-source.sh"
h_source 'util'

h_is_option_sourced() {
  return 0
}

h_check_optarg() {
  if [[ "$2" == -* ]]; then
    h_error "h_check_optarg: option $1 requires an argument"
    [ -n "$3" ] && "$3"
    return 1
  fi
  return 0
}

h_get_lopts() {
  local _opts _name="$2"
  IFS=',' read -ra _opts <<< "$1"
  shift 2

  OPTIND=${OPTIND:-1}
  local _o _cur="${!OPTIND}" _len
  for _o in "${_opts[@]}"; do
    # If an option has an argument
    if [[ "$_o" == *: ]]; then
      _len=$((${#_o} - 1))
      _o="${_o:0:$_len}"
      if [[ "$_cur" == "--$_o" ]]; then
        ((++OPTIND))
        if ((OPTIND <= $#)); then
          eval "$_name"="$_o"
          OPTARG="${!OPTIND}"
          ((++OPTIND))
        # Error: option requires an argument
        else
          eval "$_name"=':'
          OPTARG="$_o"
        fi
        return 0
      elif [[ "$_cur" == "--$_o="* ]]; then
        eval "$_name"="$_o"
        OPTARG="${_cur#*=}"
        ((++OPTIND))
        return 0
      fi
    # If an option doesn't have an argument
    else
      if [[ "$_cur" == "--$_o" ]]; then
        eval "$_name"="$_o"
        unset -v OPTARG
        ((++OPTIND))
        return 0
      fi
    fi
  done

  # Error: illegal option
  if [[ "$_cur" == --* ]]; then
    eval "$_name"='?'
    OPTARG="${_cur%%=*}"
    OPTARG="${OPTARG:2}"
    ((++OPTIND))
    return 0
  # End of Option: 1. not option but argument 2. option index out of range
  else
    eval "$_name"='?'
    unset -v OPTARG
    return 1
  fi
}

h_get_options_usage() {
  h_error "Run 'h_get_options -h' for more information on the usage."
}

h_get_options_help() {
  h_echo 'Usage:'
  h_echo '  h_get_options [<options...>] [--] [<arguments...>]'
  h_echo
  h_echo 'Options:'
  h_echo '  -o <optstring>  Specify the short options to be recognized'
  h_echo '  -l <optstring>  Specify the long options to be recognized'
  h_echo '  -V              Display the version of h_get_options'
  h_echo '  -h              Display this help message'
}

h_get_options() {
  local opt='' OPTIND=1 OPTARG='' sopts='' lopts=''
  while getopts ':o:l:Vh' opt; do
    case "$opt" in
      'o')
        h_check_optarg "-$opt" "$OPTARG" h_get_options_usage || return 2
        sopts="$OPTARG"
        ;;
      'l')
        h_check_optarg "-$opt" "$OPTARG" h_get_options_usage || return 2
        lopts="$OPTARG"
        ;;
      'V')
        h_echo 'h_get_options v1.0.0 for bash'
        return 0
        ;;
      'h')
        h_get_options_help
        return 0
        ;;
      '?')
        h_error "h_get_options: illegal option -$OPTARG"
        h_get_options_usage
        return 2
        ;;
      ':')
        h_error "h_get_options: option -$OPTARG requires an argument"
        h_get_options_usage
        return 2
        ;;
    esac
  done

  shift $((OPTIND - 1))

  local opt='' OPTIND=1 OPTARG='' args=() out='' err=' --'
  while ((OPTIND <= $#)); do
    case "${!OPTIND}" in
      --)
        for ((++OPTIND; OPTIND <= $#; ++OPTIND)); do
          args+=("'${!OPTIND}'")
        done
        break
        ;;
      --*)
        h_get_lopts "$lopts" opt "$@" || { h_error "h_get_options: h_get_lopts error: $?"; h_echo "$err"; return 1; }
        if [[ "$opt" == '?' || "$opt" == ':' ]]; then
          OPTARG="--$OPTARG"
        else
          opt="--$opt"
        fi
        ;;
      -*)
        getopts ":$sopts" opt || { h_error "h_get_options: getopts error: $?"; h_echo "$err"; return 1; }
        if [[ "$opt" == '?' || "$opt" == ':' ]]; then
          OPTARG="-$OPTARG"
        else
          opt="-$opt"
        fi
        ;;
      *)
        args+=("'${!OPTIND}'")
        ((++OPTIND))
        continue
        ;;
    esac

    case "$opt" in
      '?')
        h_error "h_get_options: illegal option $OPTARG"
        h_echo "$err"
        return 1
        ;;
      ':')
        h_error "h_get_options: option $OPTARG requires an argument"
        h_echo "$err"
        return 1
        ;;
      *)
        out+=" $opt${OPTARG+ '$OPTARG'}"
        ;;
    esac
  done

  if ((${#args[@]} == 0)); then
    out+=" --"
  else
    out+=" -- ${args[*]}"
  fi

  h_echo "$out"
}

h_is_gnu_getopt() {
  command getopt -T > /dev/null
  [ $? -eq 4 ]
}

h_check_gnu_getopt() {
  if ! h_is_gnu_getopt; then
    h_error -t 'GNU getopt not installed on your system'
    h_is_mac && h_error 'To install gnu-getopt on macOS, run: brew install gnu-getopt'
    return 1
  fi
  return 0
}

getopt() {
  if h_is_bash; then
    h_get_options "$@"
  else
    h_check_gnu_getopt || return 1
    command getopt "$@"
  fi
}
