require 'serverspec'
require 'yaml'

describe 'Simple Component' do

  describe 'the os' do
    it 'is ubuntu' do
      expect(host_inventory['platform']).to eq 'ubuntu'
    end

    it 'is version 14.04 LTS' do
      expect(host_inventory['platform_version']).to eq '14.04'
    end
  end

  describe 'config.yml' do
    it 'contains the components name' do
      expect(YAML.load(file('/config.yml').content)['name']).to eq 'Test Component'
    end
  end

  describe 'ENV' do
    let(:env) { Hash[command('env').stdout.chomp.split("\n").map { |line| line.split('=') }] }

    context 'version 0.0.1', :'0.0.1' do
      it 'has a version env var' do
        expect(env['VERSION']).to eq 'OhhOhhOne'
      end

      it 'has a FOO' do
        expect(env['FOO']).to eq 'version one'
      end
    end

    it 'is awesome', :'0.0.2' do
      expect(env['AWESOME']).to eq 'very'
    end

    it 'is super awesome', :'0.0.3' do
      expect(env['AWESOME']).to eq 'super'
    end

    it 'has a FOO', :'0.0.2' do
      expect(env['FOO']).to eq 'version two'
    end

    it 'has a FOO', :'0.0.3' do
      expect(env['FOO']).to eq 'version three'
    end
  end
end
