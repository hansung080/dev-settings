SHELL_NAME="$(ps -p $$ | tail -1 | awk '{ print $4 }')"
if [[ "${SHELL_NAME:0:1}" == "-" ]]; then
  SHELL_NAME="${SHELL_NAME:1}"
elif expr "$SHELL_NAME" : '.*/.*' &> /dev/null; then
  SHELL_NAME="$(expr "$SHELL_NAME" : "$(dirname "$SHELL_NAME")/\(.*\)$")"
fi

is_bash() {
  if [[ "$SHELL_NAME" == "bash" ]]; then
    return 0
  fi
  return 1
}

is_zsh() {
  if [[ "$SHELL_NAME" == "zsh" ]]; then
    return 0
  fi
  return 1
}

set_path_array() {
  if is_zsh; then
    PATH_ARRAY=(${(@s/:/)PATH})
  else
    IFS=':' read -r -a PATH_ARRAY <<< "$PATH"
  fi
}

in_path() {
  set_path_array
  
  local p
  for p in ${PATH_ARRAY[@]}; do
    if [[ "$p" == "$1" ]]; then
      return 0
    fi
  done
  return 1
}

add_path() {
  local p
  for p in $@; do
    if ! in_path "$p"; then
      if [ -z "$PATH" ]; then
        export PATH="$p"
      else
        export PATH="$PATH:$p"  
      fi
    fi
  done
}

deduplicate_path() {
  local original_path
  if is_zsh; then
    original_path=(${(@s/:/)PATH})
  else
    IFS=':' read -r -a original_path <<< "$PATH"
  fi

  PATH=""
  local p
  for p in ${original_path[@]}; do
    add_path "$p"
  done
}

print_path() {
  set_path_array

  local start=0
  local end=${#PATH_ARRAY[@]}
  # The array's index starts with 1 in Zsh, while it starts with 0 in Bash.
  if is_zsh; then
    start=1
    end=$((end + 1))
  fi
  
  local i
  for ((i=start; i<end; ++i)); do
    if is_zsh; then
      echo "${i}: ${PATH_ARRAY[$i]}"
    else
      echo "$((i + 1)): ${PATH_ARRAY[$i]}"
    fi  
  done
}

make_new() {
  if [ $# -ne 1 ]; then
    echo "Usage) make_new <project>"
    return 1
  fi

  local project="$1"
  mkdir -p "$project/src" "$project/test"
  curl -fsSL 'https://raw.githubusercontent.com/hansung080/study/master/c/examples/hello-make/Makefile' | sed "s/hello-make/$project/g" > "$project/Makefile"
  print_c_main "$project" > "$project/src/main.c"
  print_c_main "$project-test" > "$project/test/main.c"
}

print_c_main() {
  local content="\
#include <stdio.h>

int main(int argc, char* argv[]) {
    printf(\"Hello, $1!"'\\n'"\");
    return 0;
}"
  echo "$content"
}
