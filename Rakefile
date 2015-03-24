require 'reevoocop/rake_task'
require 'rspec/core/rake_task'

ReevooCop::RakeTask.new(:reevoocop) do |task|
  task.patterns = ['lib/**/*.rb', 'spec/**/*.rb', 'Rakefile', 'Gemfile']
end

RSpec::Core::RakeTask.new(:spec)

RSpec::Core::RakeTask.new(:units) do |t|
  t.rspec_opts = '--exclude-pattern spec/feature/**/**,spec/fixtures/**/**,'
end

task travis: [:units, :reevoocop]

task default: [:spec, :reevoocop]
