FROM alpine:3.4

WORKDIR /usr/src

ADD Gemfile ./
ADD Gemfile.lock ./

RUN apk add --no-cache \
  --virtual .builddeps \
    build-base \
    ruby-dev \
  && apk add --no-cache \
  --virtual .rundeps \
    ruby \
    ruby-bundler \
    git \
    openssh-client \
  && ssh-keyscan -H github.com > /etc/ssh/ssh_known_hosts \
  && git config --global user.email "assemblyline@reevoo.com" && git config --global user.name "Assemblyline Build Worker" \
  && bundle install -j4 -r3 \
  && apk del --no-cache .builddeps

ENV GIT_SSH=/usr/src/bin/git_ssh

ADD . ./
