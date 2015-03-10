require 'builder'

describe Builder do
  subject { described_class.new(url: "git@github.com:reevoo/fast_response.git") }

  specify do
    require 'pry'
    binding.pry
  end
end
