require 'simplecov'
require 'codeclimate-test-reporter'
require 'pry'
require 'log'
require 'excon'
Excon.defaults[:ssl_verify_peer] = false

SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter[
  SimpleCov::Formatter::HTMLFormatter,
  CodeClimate::TestReporter::Formatter
]

SimpleCov.start do
  add_filter '/vendor/'
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

  attr_reader :out, :err

  def reset!
    @out = StringIO.new
    @err = StringIO.new
  end
end
