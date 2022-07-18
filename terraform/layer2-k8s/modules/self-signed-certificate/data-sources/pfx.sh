#!/bin/bash
set -eu -o pipefail

export certificate_pem
export private_key_pem

eval "$(jq -r '@sh "certificate_pem=\(.certificate_pem) private_key_pem=\(.private_key_pem)"')"

cert_file="$(mktemp)"
trap 'rm -f $cert_file' EXIT

echo "${certificate_pem}${private_key_pem}" >"$cert_file"

pfx="$(openssl pkcs12 \
  -in "$cert_file" \
  -export \
  -password "pass:" \
  |base64 -)"

jq -n --arg pfx "$pfx" '{"pfx":$pfx}'
