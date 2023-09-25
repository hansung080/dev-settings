: "${H_ANYSH_DIR:=$HOME/.anyshrc.d}"
source "$H_ANYSH_DIR/hidden/h-source.sh"
h_source 'util'

h_is_user_sourced() {
  return 0
}

u_test_user() {
  h_echo 'user test'
}
