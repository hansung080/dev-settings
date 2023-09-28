: "${H_ANYSH_DIR:=$HOME/.anyshrc.d}"
source "$H_ANYSH_DIR/hidden/source.sh"
h_source 'util'

u_test_user() {
  h_echo 'user test'
}
