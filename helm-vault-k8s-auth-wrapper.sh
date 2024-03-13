#!/bin/bash
# ArgoCD + helm-secrets + SOPS + Hashicorp Vault
# Wrapper for helm to make SOPS use Vault K8S Auth
# Author: JuniorJPDJ

K8S_SA_TOKEN="$(cat "${K8S_SA_TOKEN_PATH:-/var/run/secrets/kubernetes.io/serviceaccount/token}")"

# detect if using helm-secrets with basic backend
DECODING_SECRETS=0
for arg in "$@"; do
  if [[ "$arg" == *"secrets://"* ]] ; then
    DECODING_SECRETS=1
    break
  fi
done

if [[ $DECODING_SECRETS = 1 ]] ; then
  # https://developer.hashicorp.com/vault/api-docs/auth/kubernetes#login
  export VAULT_TOKEN="$(curl -s -X POST -d '{"role": "'"$VAULT_K8S_ROLE"'", "jwt": "'"$K8S_SA_TOKEN"'"}' "$VAULT_ADDR/v1/${VAULT_K8S_MOUNT_PATH:-auth/kubernetes/login}" | jq -r '.auth.client_token | select( . != null )')"
  # if auth failed this should be empty
fi

# run helm wrapper from helm-secrets
exec /home/argocd/.local/share/helm/plugins/helm-secrets/scripts/wrapper/helm.sh "$@"
