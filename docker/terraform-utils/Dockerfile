FROM alpine:3.13.5
ARG TERRAFORM_VERSION="0.15.1"

WORKDIR /tmp

#Install tfenv for terraform
RUN apk add --update --no-cache openssl git bash curl unzip sudo && \
    git clone https://github.com/tfutils/tfenv.git /usr/bin/.tfenv && \
    ln -s /usr/bin/.tfenv/bin/* /usr/bin && \
    chmod +x /usr/bin/tfenv

#Install terraform
RUN tfenv install $TERRAFORM_VERSION

#Install tflint
RUN curl https://raw.githubusercontent.com/terraform-linters/tflint/master/install_linux.sh | bash

ENTRYPOINT [""]
