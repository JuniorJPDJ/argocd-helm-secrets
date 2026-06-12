#!/bin/bash
# KSOPS wrapper for K8S ServiceAccount Hashicorp Vault auth

if [[ -n "$VAULT_ADDR" ]] ; then
  source /usr/local/lib/vault-token-k8s.sh
fi

exec /usr/local/bin/ksops "$@"
