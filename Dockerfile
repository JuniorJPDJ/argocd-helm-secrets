FROM quay.io/argoproj/argocd:v2.10.2
ARG BUILDPLATFORM=linux/amd64
# Should be overwritten by buildx
# Supported:
#  - linux/amd64
#  - linux/arm64

ARG SOPS_VERSION="3.8.1"
ARG VALS_VERSION="0.35.0"
ARG HELM_SECRETS_VERSION="4.6.0"
ARG KUBECTL_VERSION="1.29.2"

# vals or sops
ENV HELM_SECRETS_BACKEND="sops" \
    HELM_SECRETS_HELM_PATH=/usr/local/bin/helm \
    HELM_PLUGINS="/home/argocd/.local/share/helm/plugins/" \
    HELM_SECRETS_VALUES_ALLOW_SYMLINKS=false \
    HELM_SECRETS_VALUES_ALLOW_ABSOLUTE_PATH=false \
    HELM_SECRETS_VALUES_ALLOW_PATH_TRAVERSAL=false \
    HELM_SECRETS_WRAPPER_ENABLED=false

USER root
RUN apt-get update && \
    apt-get install -y \
      curl && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN curl -fsSL https://dl.k8s.io/release/v${KUBECTL_VERSION}/bin/linux/${BUILDPLATFORM##*/}/kubectl \
    -o /usr/local/bin/kubectl \
    && chmod +x /usr/local/bin/kubectl

# sops backend installation (optional)
RUN curl -fsSL https://github.com/getsops/sops/releases/download/v${SOPS_VERSION}/sops-v${SOPS_VERSION}.linux.${BUILDPLATFORM##*/} \
    -o /usr/local/bin/sops \
    && chmod +x /usr/local/bin/sops

# vals backend installation (optional)
RUN curl -fsSL https://github.com/helmfile/vals/releases/download/v${VALS_VERSION}/vals_${VALS_VERSION}_linux_${BUILDPLATFORM##*/}.tar.gz \
    | tar xzf - -C /usr/local/bin/ vals \
    && chmod +x /usr/local/bin/vals

RUN ln -sf "$(helm env HELM_PLUGINS)/helm-secrets/scripts/wrapper/helm.sh" /usr/local/sbin/helm

USER argocd

RUN helm plugin install --version ${HELM_SECRETS_VERSION} https://github.com/jkroepke/helm-secrets
