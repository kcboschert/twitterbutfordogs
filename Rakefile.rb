require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec)

task :default do
  Rake::Task['spec'].invoke
end
