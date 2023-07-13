# .zshrc

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
  curl -fsSL https://raw.githubusercontent.com/hansung080/study/master/c/examples/hello-make/Makefile | sed "s/hello-make/$project/g" > "$project/Makefile"
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

setopt PROMPT_SUBST
#PROMPT='%(!.%F{red}.%F{cyan})%n%f@%F{yellow}%m%f:%{$(pwd|grep --color=always /)%${#PWD}G%}%(!.%F{red}.)%#%f '
#PROMPT='%F{red}%n%f@%{$(pwd|grep --color=always /)%${#PWD}G%}%# '
PROMPT='%n@%{$(pwd)%${#PWD}G%}%# '

# General Aliases
alias ll='ls -alF'
alias work='cd /Users/hansung/work'
alias ws='cd /Users/hansung/work/ws'

WORK_HOME="/Users/hansung/work"
export PATH="$PATH:$WORK_HOME/bin"

HOMEBREW_HOME="/opt/homebrew"
export PATH="$PATH:$HOMEBREW_HOME/bin"

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"
export JAVA_HOME="/Users/hansung/.sdkman/candidates/java/8.0.352-zulu/zulu-8.jdk/Contents/Home"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# Use the following version of Node.js.
nvm use 18.12.1 > /dev/null

export GVM_DIR="$HOME/.gvm"
[[ -s "$HOME/.gvm/scripts/gvm" ]] && source "$HOME/.gvm/scripts/gvm"

#export GOROOT="/usr/local/go/current"
#export GOPATH="/Users/hansung/work/ws/go/system"
export GOBIN="$GOPATH/bin"
export GO111MODULE="on" # for go1.11 ~ go1.15
#export PATH="$PATH:$GOROOT/bin"
#export PATH="$PATH:$GOPATH/bin"

alias goenv='go env | grep GOROOT; go env | grep GOPATH; go env | grep GOBIN; go env | grep GO111MODULE'

export RUSTUP_HOME="/Users/hansung/.rustup"
export CARGO_HOME="/Users/hansung/.cargo"
[[ -s "$HOME/.cargo/env" ]] && source "$HOME/.cargo/env"

deduplicate_path

[ ! -z "$PS1" ] && echo '.zshrc'
