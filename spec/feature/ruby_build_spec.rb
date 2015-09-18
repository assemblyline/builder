require 'spec_helper'
require 'builder'

describe 'Building Ruby Apps' do
  context 'a simple app' do
    it 'can build a passing rspec app' do
      Builder.local_build(dir: 'spec/fixtures/ruby_projects/rspec', sha: 'thisisasha')
      expect(Log.out.string).to include 'sucessfully assembled quay.io/assemblyline/ruby_sample:thisisasha'
    end

    it 'exits from a failing rspec app' do
      expect do
        Builder.local_build(dir: 'spec/fixtures/ruby_projects/failing_rspec', sha: 'thisisasha')
      end.to raise_error(SystemExit)
    end
  end

  context 'a rails app with postgres db' do
    it 'can build the app' do
      pending('Currently not working on travis CI') if ENV['TRAVIS']
      Builder.local_build(dir: 'spec/fixtures/ruby_projects/rails_example', sha: 'thisisasha')
      expect(Log.out.string).to include 'creating example_rails_app_test postgres database'
      expect(Log.out.string).to include 'sucessfully assembled example_rails_app:thisisasha'
    end
  end

  context 'with a custom dockerfile' do
    it 'uses a custom dockerfile if present' do
      Builder.local_build(dir: 'spec/fixtures/ruby_projects/custom_dockerfile', sha: 'thisisasha')
      expect(Log.out.string).to include 'true'
    end
  end
end
