#! /bin/sh

SRC_DIR="$(pwd)/src"

cat << EOS
export POSIXSH_STDLIB_HOME="$SRC_DIR"; \
  export PATH="$SRC_DIR/bin:\$PATH"; \
  export POSIXSH_IMPORT_PATH="$SRC_DIR:$SRC_DIR/unittest";
EOS
