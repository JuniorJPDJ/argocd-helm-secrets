#!/bin/bash

K8S_SA_TOKEN="$(cat "${K8S_SA_TOKEN_PATH:-/var/run/secrets/kubernetes.io/serviceaccount/token}")"

# https://developer.hashicorp.com/vault/api-docs/auth/kubernetes#login
export VAULT_TOKEN="$(curl -s -X POST -d '{"role": "'"$VAULT_K8S_ROLE"'", "jwt": "'"$K8S_SA_TOKEN"'"}' "$VAULT_ADDR/v1/auth/${VAULT_K8S_MOUNT_PATH:-kubernetes}/login" | jq -r '.auth.client_token | select( . != null )')"
# if auth failed this should be empty
