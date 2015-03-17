require 'spec_helper'
require 'application'
require 'builder/dockerfile'
require 'tmpdir'
require 'fileutils'

describe Application do
  let(:data) do
    {
      'path' => '.',
      'repo' => 'foo.com/foo/bar',
      'build' => { 'builder' => 'Dockerfile' },
    }
  end

  let(:dir) { Dir.mktmpdir }

  after do
    FileUtils.rm_rf dir
  end

  subject { described_class.new(data, dir) }


  describe '#tag' do
    let!(:git_sha) do
      MiniGit.init dir
      FileUtils.touch("#{dir}/file.txt")
      git = MiniGit.new(dir)
      git.add '.'
      git.commit m: 'test commit'
      git.capturing.rev_parse({short: true}, :HEAD).chomp
    end

    it 'constructs the correct tag' do
      allow(Time).to receive(:now).and_return(Time.at(1426533532))
      expect(subject.tag).to eq("foo.com/foo/bar:#{git_sha}_20150316191852")
    end

    it 'the tag remains the same even if time is ticking' do
      allow(Time).to receive(:now).and_return(Time.at(1426533532))
      expect(subject.tag).to eq("foo.com/foo/bar:#{git_sha}_20150316191852")
      # Time will move forward while we build the image
      allow(Time).to receive(:now).and_return(Time.at(1526533532))
      #but the timestamp should be the same here
      expect(subject.tag).to eq("foo.com/foo/bar:#{git_sha}_20150316191852")
    end
  end

  describe '#build' do
    it 'calls the builder' do
      expect(subject.builder).to receive(:build)
      subject.build
    end
  end

  describe '#push' do
    let(:image) { double }

    it 'pushes the tagged image to the repo' do
      expect(Docker).to receive(:authenticate!)
      allow(subject).to receive(:tag).and_return('awesome_tag')
      allow(Docker::Image).to receive(:get).with('awesome_tag').and_return(image)
      expect(image).to receive(:push)
      subject.push
    end
  end

end
