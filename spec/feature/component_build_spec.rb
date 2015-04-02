require 'spec_helper'
require 'builder'

describe 'Building Assemblyline Components' do
  context 'a simple component' do
    it 'works as expected' do
      Builder.local_build(dir: 'spec/fixtures/components/simple_component', sha: 'thisisasha')

      expect(output(1).first).to eq " version:0.0.1\e[0m"
      expect(output(1)).to include '5 examples, 0 failures'
      expect(output(1).last).to eq "\e[1;32;49msucessfully assembled quay.io/assemblyline/test_component:0.0.1\e[0m"

      expect(output(2).first).to eq " version:0.0.2\e[0m"
      expect(output(2)).to include '5 examples, 0 failures'
      expect(output(2).last).to eq "\e[1;32;49msucessfully assembled quay.io/assemblyline/test_component:0.0.2\e[0m"

      expect(output(3).first).to eq " version:0.0.3\e[0m"
      expect(output(3)).to include '5 examples, 0 failures'
      expect(output(3).last).to eq "\e[1;32;49msucessfully assembled quay.io/assemblyline/test_component:0.0.3\e[0m"
    end

    def output(version)
      @_out ||= Log.out.string.split("\e[1;32;49massembling Test Component").map { |t| t.split("\n") }
      @_out[version]
    end

  end
end
