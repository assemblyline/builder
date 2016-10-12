require "reevoocop/rake_task"
require "rspec/core/rake_task"

ReevooCop::RakeTask.new(:reevoocop) do |task|
  task.patterns = ["lib/**/*.rb", "spec/*.rb", "spec/unit/*.rb", "spec/feature/*.rb", "Rakefile", "Gemfile"]
end
task default: :reevoocop

RSpec::Core::RakeTask.new(:spec)
task default: :spec
