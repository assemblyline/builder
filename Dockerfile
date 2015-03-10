FROM quay.io/assemblyline/ruby:2.1.5

WORKDIR /usr/src
ADD Gemfile ./
ADD Gemfile.lock ./

RUN bundle install -j4 -r3

ADD . ./
