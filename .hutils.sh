H_RESET='\033[0m'
H_RED_BOLD='\033[1;31m'
H_ERROR="${H_RED_BOLD}error${H_RESET}"

H_SHELL_NAME="$(ps -p $$ | tail -1 | awk '{ print $4 }')"
if [[ "${H_SHELL_NAME:0:1}" == '-' ]]; then
  H_SHELL_NAME="${H_SHELL_NAME:1}"
elif expr "$H_SHELL_NAME" : '.*/.*' &> /dev/null; then
  H_SHELL_NAME="$(expr "$H_SHELL_NAME" : "$(dirname "$H_SHELL_NAME")/\(.*\)$")"
fi

h_is_bash() {
  if [[ "$H_SHELL_NAME" == 'bash' ]]; then
    return 0
  fi
  return 1
}

h_is_zsh() {
  if [[ "$H_SHELL_NAME" == 'zsh' ]]; then
    return 0
  fi
  return 1
}

h_set_path_array() {
  if h_is_zsh; then
    H_PATH_ARRAY=(${(@s/:/)PATH})
  else
    IFS=':' read -r -a H_PATH_ARRAY <<< "$PATH"
  fi
}

h_in_path() {
  h_set_path_array
  local p
  for p in ${H_PATH_ARRAY[@]}; do
    if [[ "$p" == "$1" ]]; then
      return 0
    fi
  done
  return 1
}

h_add_path() {
  local p
  for p in $@; do
    if ! h_in_path "$p"; then
      if [ -z "$PATH" ]; then
        export PATH="$p"
      else
        export PATH="$PATH:$p"  
      fi
    fi
  done
}

h_deduplicate_path() {
  local original_path
  if h_is_zsh; then
    original_path=(${(@s/:/)PATH})
  else
    IFS=':' read -r -a original_path <<< "$PATH"
  fi

  PATH=''
  local p
  for p in ${original_path[@]}; do
    h_add_path "$p"
  done
}

h_print_path() {
  h_set_path_array
  local start=0
  local end=${#H_PATH_ARRAY[@]}
  # The array's index starts with 1 in Zsh, while it starts with 0 in Bash.
  if h_is_zsh; then
    start=1
    end=$((end + 1))
  fi
  
  local i
  for ((i=start; i<end; ++i)); do
    if h_is_zsh; then
      echo "$i: ${H_PATH_ARRAY[$i]}"
    else
      echo "$((i + 1)): ${H_PATH_ARRAY[$i]}"
    fi  
  done
}

h_make_check_args() {
  local project="$1"
  local type="$2"
  local usage="usage: $3 <project> [bin | lib]"

  if [[ "$project" == '' ]]; then
    echo -e "$H_ERROR: <project> not provided"
    echo "$usage"
    return 1
  fi

  if [[ "$type" != 'bin' ]] && [[ "$type" != 'lib' ]]; then
    echo -e "$H_ERROR: <type> must be either bin or lib"
    echo "$usage"
    return 1
  fi
  return 0
}

h_print_c_main() {
  local content="\
#include <stdio.h>

int main(int argc, char* argv[]) {
    printf(\"Hello, $1!"'\\n'"\");
    return 0;
}"
  echo "$content"
}

h_make_new() {
  local project="$1"
  local type="$2"
  if ! h_make_check_args "$project" "$type" 'h_make_new'; then
    return 1
  fi

  mkdir -p "$project/src" "$project/test"
  local makefile="$type.mk"
  curl -fsSL "https://raw.githubusercontent.com/hansung080/study/master/c/examples/make-sample/$makefile" | sed "s/make-sample/$project/g" > "$project/$makefile"
  curl -fsSL 'https://raw.githubusercontent.com/hansung080/study/master/c/examples/make-sample/project.mk' | sed "s/bin\.mk/$makefile/g" > "$project/Makefile"
  h_print_c_main "$project-test" > "$project/test/main.c"
  if [[ "$type" == 'bin' ]]; then
    h_print_c_main "$project" > "$project/src/main.c"
  else
    touch "$project/src/lib.c"
  fi
}

h_make_update() {
  local project="$1"
  local type="$2"
  if ! h_make_check_args "$project" "$type" 'h_make_update'; then
    return 1
  fi

  local makefile="$type.mk"
  curl -fsSL "https://raw.githubusercontent.com/hansung080/study/master/c/examples/make-sample/$makefile" | sed "s/make-sample/$project/g" > "$makefile"
}

alias makev='make __verbose=true'
