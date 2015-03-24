require 'spec_helper'
require 'assemblyfile/loader'
require 'patch/rubygems'

describe 'Building Ruby Apps' do
  before do
    # This messes up under boot2docker, inside our container everthing works properly
    Excon.defaults[:ssl_verify_peer] = false
  end

  context 'a simple app' do
    it 'can build a passing rspec app' do
      app = Assemblyfile.load('spec/fixtures/ruby_projects/rspec', 'thisisasha').first
      app.build
    end

    it 'exits from a failing rspec app' do
      app = Assemblyfile.load('spec/fixtures/ruby_projects/failing_rspec', 'thisisasha').first
      expect { app.build }.to raise_error(SystemExit)
    end
  end
end
