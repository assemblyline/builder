require "reevoocop/rake_task"
require "rspec/core/rake_task"

ReevooCop::RakeTask.new(:reevoocop) do |task|
  task.patterns = ["lib/**/*.rb", "spec/*.rb", "spec/unit/*.rb", "spec/feature/*.rb", "Rakefile", "Gemfile"]
end

namespace :spec do
  RSpec::Core::RakeTask.new(:unit) do |t|
    t.pattern = "spec/unit/**/**_spec.rb"
  end

  RSpec::Core::RakeTask.new(:feature) do |t|
    t.pattern = "spec/feature/**/**_spec.rb"
  end

  task all: [:unit, :feature]
end

task spec: "spec:all"

task default: [:spec, :reevoocop]
