FROM quay.io/argoproj/argocd:v3.1.9
ARG TARGETARCH

# renovate: datasource=github-releases depName=getsops/sops
ARG SOPS_VERSION="3.10.2"
# renovate: datasource=github-releases depName=helmfile/vals
ARG VALS_VERSION="0.42.1"
# renovate: datasource=github-releases depName=jkroepke/helm-secrets
ARG HELM_SECRETS_VERSION="v4.6.10"
# renovate: datasource=github-releases depName=aslafy-z/helm-git
ARG HELM_GIT_VERSION="1.4.0"
# renovate: datasource=github-releases depName=kubernetes/kubernetes
ARG KUBECTL_VERSION="1.34.1"

ENV HELM_SECRETS_BACKEND="sops" \
    HELM_SECRETS_HELM_PATH=/usr/local/bin/helm \
    HELM_PLUGINS="/home/argocd/.local/share/helm/plugins/" \
    HELM_SECRETS_VALUES_ALLOW_SYMLINKS=false \
    HELM_SECRETS_VALUES_ALLOW_ABSOLUTE_PATH=false \
    HELM_SECRETS_VALUES_ALLOW_PATH_TRAVERSAL=false \
    HELM_SECRETS_WRAPPER_ENABLED=false

USER root
RUN apt-get update && \
    apt-get install -y curl jq && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# kubectl installation
RUN curl -fsSL https://dl.k8s.io/release/v${KUBECTL_VERSION}/bin/linux/${TARGETARCH}/kubectl \
    -o /usr/local/bin/kubectl \
    && chmod +x /usr/local/bin/kubectl

# sops backend installation
RUN curl -fsSL https://github.com/getsops/sops/releases/download/v${SOPS_VERSION}/sops-v${SOPS_VERSION}.linux.${TARGETARCH} \
    -o /usr/local/bin/sops \
    && chmod +x /usr/local/bin/sops

# vals backend installation
RUN curl -fsSL https://github.com/helmfile/vals/releases/download/v${VALS_VERSION}/vals_${VALS_VERSION}_linux_${TARGETARCH}.tar.gz \
    | tar xzf - -C /usr/local/bin/ vals \
    && chmod +x /usr/local/bin/vals

RUN ln -sf /usr/local/bin/helm-vault-k8s-auth-wrapper.sh /usr/local/sbin/helm

USER $ARGOCD_USER_ID

# helm-secrets installation
RUN helm plugin install --version ${HELM_SECRETS_VERSION} https://github.com/jkroepke/helm-secrets

# helm-git installation
RUN helm plugin install --version ${HELM_GIT_VERSION} https://github.com/aslafy-z/helm-git

COPY helm-vault-k8s-auth-wrapper.sh /usr/local/bin/
