require 'git_cache'

describe GitCache do
  let(:git_url) { double(cache_path: 'foo', url: 'foo-url') }
  subject { described_class.new git_url }

  it 'creates the cache if it does not exist' do
    allow(Dir).to receive(:exist?).with('foo')
    expect(FileUtils).to receive(:mkdir_p).with('foo')
    expect(subject).to receive(:system).with('git clone foo-url foo')
    subject.refresh
  end

  it 'fetches the cache if it does exist' do
    allow(Dir).to receive(:exist?).with('foo').and_return(true)
    expect(Dir).to receive(:chdir).with('foo')
    expect(subject).to receive(:system).with('git fetch')
    subject.refresh
  end
end
