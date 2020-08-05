FROM jetbrains/teamcity-agent:2020.1.2

USER root

# Install kubectl
RUN curl -LO https://storage.googleapis.com/kubernetes-release/release/`curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt`/bin/linux/amd64/kubectl \
      && chmod +x ./kubectl \
      && cp ./kubectl /usr/bin/kubectl

# Install awscli
RUN curl "https://s3.amazonaws.com/aws-cli/awscli-bundle.zip" -o "awscli-bundle.zip" \
      && unzip awscli-bundle.zip \
      && ./awscli-bundle/install -i /usr/local/aws -b /usr/local/bin/aws \
      && rm -rf awscli-bundle*

# Install helm
RUN curl -L "https://get.helm.sh/helm-v3.2.4-linux-amd64.tar.gz" |tar xvz && \
    mv linux-amd64/helm /usr/bin/helm && \
    chmod +x /usr/bin/helm

#Install helmfile
RUN curl -L "https://github.com/roboll/helmfile/releases/download/v0.125.2/helmfile_linux_amd64" -o "helmfile_linux_amd64" \
    && chmod +x helmfile_linux_amd64 && mv helmfile_linux_amd64 /usr/bin/helmfile

USER buildagent
