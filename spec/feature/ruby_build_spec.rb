require 'spec_helper'
require 'builder'

describe 'Building Ruby Apps' do
  before do
    # This messes up under boot2docker, inside our container everthing works properly
    Excon.defaults[:ssl_verify_peer] = false
  end

  context 'a simple app' do
    it 'can build a passing rspec app' do
      Builder.local_build(dir: 'spec/fixtures/ruby_projects/rspec', sha: 'thisisasha')
    end

    it 'exits from a failing rspec app' do
      expect do
        Builder.local_build(dir: 'spec/fixtures/ruby_projects/failing_rspec', sha: 'thisisasha')
      end.to raise_error(SystemExit)
    end
  end

  context 'a rails app with postgres db' do
    it 'can build the app app' do
      Builder.local_build(dir: 'spec/fixtures/ruby_projects/rails_example', sha: 'thisisasha')
    end
  end
end
