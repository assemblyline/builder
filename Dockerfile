FROM quay.io/assemblyline/ruby:2.1.8

RUN ssh-keyscan -H github.com > /etc/ssh/ssh_known_hosts
ENV GIT_SSH=/usr/src/bin/git_ssh
RUN git config --global user.email "assemblyline@reevoo.com" && git config --global user.name "Assemblyline Build Worker"

WORKDIR /usr/src
ADD Gemfile ./
ADD Gemfile.lock ./

RUN bundle install -j4 -r3

ADD . ./

