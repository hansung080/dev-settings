#!/bin/bash

THIS_DIR='/Users/hansung/work/ws/hansung080/dev-settings/.anysh'
HIDDEN_DIR="$THIS_DIR/hidden"
FEATURES_DIR="$THIS_DIR/features"
LIST_DIR="$THIS_DIR/list"
HIDDEN_LIST="$LIST_DIR/hidden.txt"
FEATURES_LIST="$LIST_DIR/features.txt"

if [ ! -d "$LIST_DIR" ]; then
  rm -rf "$LIST_DIR" && mkdir "$LIST_DIR"
fi

IFS=$'\n'
for file in $(find "$HIDDEN_DIR" -type f -name '*.sh' -exec basename {} + | sort); do
  echo "$file" >> "$HIDDEN_LIST"
done

for file in $(find "$FEATURES_DIR" -type f -name '*.sh' -exec basename {} + | sort); do
  echo "$file" >> "$FEATURES_LIST"
done
