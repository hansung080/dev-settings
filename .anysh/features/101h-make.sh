: "${H_ANYSH_DIR:=$HOME/.anyshrc.d}"
source "$H_ANYSH_DIR/hidden/h-source.sh"
h_source 'util'

h_is_make_sourced() {
  return 0
}

h_make_check_args() {
  local project="$1"
  local type="$2"
  local usage="usage: $3 <project> [bin | lib]"

  if [[ "$project" == '' ]]; then
    h_echo -e "$H_ERROR: <project> not provided"
    h_echo "$usage"
    return 1
  fi

  if [[ "$type" != 'bin' ]] && [[ "$type" != 'lib' ]]; then
    h_echo -e "$H_ERROR: <type> must be either bin or lib"
    h_echo "$usage"
    return 1
  fi
  return 0
}

h_make_c_main() {
  local content="\
#include <stdio.h>

int main(int argc, char* argv[]) {
    printf(\"Hello, $1!"'\\n'"\");
    return 0;
}"
  h_echo "$content"
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
  h_make_c_main "$project-test" > "$project/test/main.c"
  if [[ "$type" == 'bin' ]]; then
    h_make_c_main "$project" > "$project/src/main.c"
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
