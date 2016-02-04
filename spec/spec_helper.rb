require "simplecov"
require "codeclimate-test-reporter"
require "pry"
require "log"
require "excon"
Excon.defaults[:ssl_verify_peer] = false

SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter[
  SimpleCov::Formatter::HTMLFormatter,
  CodeClimate::TestReporter::Formatter
]

SimpleCov.start do
  add_filter "/vendor/"
end


RSpec.configure do |config|
  config.before(:all) do
    `git config --global push.default simple`
  end

  config.before(:each) do
    Log.reset!
  end
end

# Test implimentation of log
module Log
  extend self

  def out
    print "."
    @out
  end

  def err
    print "."
    @err
  end

  def reset!
    puts ""
    @out = StringIO.new
    @err = StringIO.new
  end
end

def with_env(env)
  old_env = {}
  env.each do |var, val|
    old_env[var] = ENV[var]
    ENV[var] = val
  end

  yield

  old_env.each do |var, val|
    ENV[var] = val
  end
end
