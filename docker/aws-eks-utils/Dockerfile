FROM public.ecr.aws/docker/library/ubuntu:22.04 as sessionmanagerplugin

RUN apt-get update \
    && apt-get install -y curl \
    && curl -Lo "session-manager-plugin.deb" "https://s3.amazonaws.com/session-manager-downloads/plugin/latest/ubuntu_64bit/session-manager-plugin.deb" \
    && dpkg -i "session-manager-plugin.deb"

FROM public.ecr.aws/docker/library/alpine:3.19.1

ARG TERRAFORM_VERSION="1.8.3"
ARG TERRAGRUNT_VERSION="0.58.5"
ARG HELM_VERSION="3.15.0"
ARG HELMFILE_VERSION="0.144.0"
ARG KUBECTL_VERSION="1.30.1"
ENV BASE_URL="https://get.helm.sh"
ENV TAR_FILE="helm-v${HELM_VERSION}-linux-amd64.tar.gz"

#Install python and pip
RUN echo "**** install Python and pip ****" && \
    apk add --update --no-cache python3 py3-pip py3-setuptools py3-wheel

#Install additional packages and helm
RUN echo "**** install additional packages and helm ****" && \
    apk add --update --no-cache openssl git jq bash curl wget unzip ca-certificates && \
    curl -L ${BASE_URL}/${TAR_FILE} |tar xvz && \
    mv linux-amd64/helm /usr/bin/helm && \
    chmod +x /usr/bin/helm

WORKDIR /tmp

#Install tfenv for terraform
RUN echo "**** install tfenv for terraform ****" && \
    git clone https://github.com/tfutils/tfenv.git /usr/bin/.tfenv && \
    ln -s /usr/bin/.tfenv/bin/* /usr/bin

#Intall tgenv for terragrunt
RUN echo "**** install tgenv for terragrunt ****" && \
    git clone https://github.com/cunymatthieu/tgenv.git /usr/bin/.tgenv && \
    ln -s /usr/bin/.tgenv/bin/* /usr/bin

#Install terraform
RUN echo "**** install terraform ****" && \
    tfenv install $TERRAFORM_VERSION

#Install terragrunt
RUN echo "**** install terragrunt ****" && \
    tgenv install $TERRAGRUNT_VERSION

#Install aws-cli
RUN echo "**** install aws-cli ****" && \
    pip install awscli --upgrade --break-system-packages

#Install aws session-manager plugin for cli
RUN echo "**** install aws session manager plugin  for cli ****"
COPY --from=sessionmanagerplugin /usr/local/sessionmanagerplugin/bin/session-manager-plugin /usr/local/bin/

#Install kubectl
RUN echo "**** install kubectl ****" && \
    wget https://storage.googleapis.com/kubernetes-release/release/v"$KUBECTL_VERSION"/bin/linux/amd64/kubectl && \
    chmod +x kubectl && mv kubectl /bin/kubectl

#Install docker
RUN echo "**** install docker ****" && \
    apk add --no-cache --update docker

#Install helmfile
RUN echo "**** install helmfile ****" && \
    wget https://github.com/roboll/helmfile/releases/download/v${HELMFILE_VERSION}/helmfile_linux_amd64 \
    && chmod +x helmfile_linux_amd64 && mv helmfile_linux_amd64 /bin/helmfile

# Install ssh
RUN echo "**** install openssh ****" && \
    apk add openssh

ENTRYPOINT [""]
