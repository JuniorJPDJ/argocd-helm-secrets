#!/bin/bash
# ArgoCD + helm-secrets + SOPS + Hashicorp Vault
# Wrapper for helm to make SOPS use Vault K8S Auth
# Author: JuniorJPDJ

# detect if using helm-secrets with basic backend
DECODING_SECRETS=0
for arg in "$@"; do
  if [[ "$arg" == *"secrets://"* ]] ; then
    DECODING_SECRETS=1
    break
  fi
done

if [[ $DECODING_SECRETS = 1 && -n "$VAULT_ADDR" ]] ; then
  source /usr/local/lib/vault-token-k8s.sh
fi

# run helm wrapper from helm-secrets
exec /home/argocd/.local/share/helm/plugins/helm-secrets/scripts/wrapper/helm.sh "$@"
