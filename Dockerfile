FROM jenkins/jenkins:lts

USER root

RUN rm /bin/sh && ln -s /bin/bash /bin/sh

RUN apt-get update \
      && apt-get install -y sudo \
      && apt-get install -y curl \
      && apt-get -y autoclean


# 安装node 和 npm
ENV NVM_DIR /usr/local/nvm
ENV NODE_VERSION 11.9.0

# install nvm
# https://github.com/creationix/nvm#install-script
RUN curl --silent -o- https://raw.githubusercontent.com/creationix/nvm/v0.31.2/install.sh | bash

# install node and npm
RUN source $NVM_DIR/nvm.sh \
    && nvm install $NODE_VERSION \
    && nvm alias default $NODE_VERSION \
    && nvm use default

# add node and npm to path so the commands are available
ENV NODE_PATH $NVM_DIR/v$NODE_VERSION/lib/node_modules

RUN  ln -s  $NVM_DIR/versions/node/v$NODE_VERSION/bin/node  /usr/bin/node
RUN  ln -s  $NVM_DIR/versions/node/v$NODE_VERSION/bin/npm  /usr/bin/npm


#RUN rm -rf /var/lib/apt/lists/*
RUN echo "jenkins ALL=NOPASSWD: ALL" >> /etc/sudoers

USER jenkins
