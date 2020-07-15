#!/bin/bash
set -eu -o pipefail

eval "$(jq -r '@sh "export PRIVATE_KEY_PEM=\(.private_key_pem)"')"

file="$(mktemp)"
trap 'rm -f $file' EXIT

echo "${PRIVATE_KEY_PEM}" > "$file"

P8="$(openssl pkcs8 \
  -in "$file" \
  -topk8 \
  -nocrypt)"

jq -n --arg p8 "$P8" '{"p8":$p8}'
