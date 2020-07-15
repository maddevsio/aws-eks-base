FROM alpine:3.10.1
ARG TERRAFORM_VERSION="0.12.25"
ARG TERRAGRUNT_VERSION="0.22.4"
ARG HELM_VERSION="3.0.2"
ARG HELMFILE_VERSION="0.98.3"
ARG KUBECTL_VERSION="1.15.11"
ENV BASE_URL="https://get.helm.sh"
ENV TAR_FILE="helm-v${HELM_VERSION}-linux-amd64.tar.gz"

#Install python and pip
RUN echo "**** install Python ****" && \
    apk add --no-cache python3 && \
    if [ ! -e /usr/bin/python ]; then ln -sf python3 /usr/bin/python ; fi && \
    \
    echo "**** install pip ****" && \
    python3 -m ensurepip && \    
    pip3 install --no-cache --upgrade pip setuptools wheel && \
    if [ ! -e /usr/bin/pip ]; then ln -s pip3 /usr/bin/pip ; fi

#Install additional packages and helm
RUN apk add --update --no-cache openssl git jq bash curl wget unzip ca-certificates && \
    curl -L ${BASE_URL}/${TAR_FILE} |tar xvz && \
    mv linux-amd64/helm /usr/bin/helm && \
    chmod +x /usr/bin/helm

WORKDIR /tmp

#Install tfenv for terraform
RUN git clone https://github.com/tfutils/tfenv.git /usr/bin/.tfenv && \
    ln -s /usr/bin/.tfenv/bin/* /usr/bin

#Intall tgenv for terragrunt
RUN git clone https://github.com/cunymatthieu/tgenv.git /usr/bin/.tgenv && \
    ln -s /usr/bin/.tgenv/bin/* /usr/bin

#Install terraform
RUN tfenv install $TERRAFORM_VERSION

#Install terragrunt
RUN tgenv install $TERRAGRUNT_VERSION

#Install aws-cli
RUN pip install awscli --upgrade

#Install kubectl
RUN wget https://storage.googleapis.com/kubernetes-release/release/v"$KUBECTL_VERSION"/bin/linux/amd64/kubectl \
  && chmod +x kubectl && mv kubectl /bin/kubectl

#Install AWS IAM authentificator
RUN curl -L https://amazon-eks.s3-us-west-2.amazonaws.com/1.13.7/2019-06-11/bin/linux/amd64/aws-iam-authenticator -o /usr/local/bin/aws-iam-authenticator \
    && chmod +x /usr/local/bin/aws-iam-authenticator

#Install docker 
RUN apk add --no-cache --update docker 

#Install helmfile
RUN wget https://github.com/roboll/helmfile/releases/download/v${HELMFILE_VERSION}/helmfile_linux_amd64 \
    && chmod +x helmfile_linux_amd64 && mv helmfile_linux_amd64 /bin/helmfile

# Install ssh
RUN apk add openssh 


ENTRYPOINT [""]
