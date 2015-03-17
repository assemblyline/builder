require 'spec_helper'
require 'application'
require 'builder/dockerfile'
require 'tmpdir'

describe Application do
  let(:data) do
    {
      'path' => '.',
      'build' => {
        'builder' => 'Dockerfile',
        'repo' => 'foo.com/foo/bar'
      },
    }
  end

  let(:dir) { Dir.mktmpdir }

  subject { described_class.new(data, dir) }

  before do
    `git --git-dir #{dir} init .`
    `touch foo`
    `git add .`
    `git commit -m 'test'`
  end

  describe '#build' do
    it 'passes the correct tag to the builder' do
      subject.build
    end
  end

end
