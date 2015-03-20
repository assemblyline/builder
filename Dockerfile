FROM quay.io/assemblyline/ruby:2.1.5

RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 36A1D7869245C8950F966E92D8576A8BA88D21E9\
      && echo deb https://get.docker.com/ubuntu docker main > /etc/apt/sources.list.d/docker.list \
      && apt-get update -q \
      && apt-get install -qy lxc-docker \
      && apt-get clean \
      && rm -rf /var/lib/apt/lists/* \
      && truncate -s 0 /var/log/*log
RUN ssh-keyscan -H github.com > /etc/ssh/ssh_known_hosts
ENV GIT_SSH=/usr/src/bin/git_ssh
RUN git config --global user.email "assemblyline@reevoo.com" && git config --global user.name "Assemblyline Build Worker"

WORKDIR /usr/src
ADD Gemfile ./
ADD Gemfile.lock ./

RUN bundle install -j4 -r3

ADD . ./

