FROM quay.io/assemblyline/ruby:2.1.5

WORKDIR /usr/src

COPY Gemfile ./
COPY Gemfile.lock ./

RUN bundle install -j4 -r3

COPY . .
