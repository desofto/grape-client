require 'bundler/gem_tasks'
# require 'rspec/core/rake_task'

# RSpec::Core::RakeTask.new(:spec)

# task default: :spec

require 'rake/testtask'

Rake::TestTask.new do |t|
  t.libs.push 'lib', 'minitest'
  t.test_files = FileList['minitest/*_spec.rb']
  t.verbose = true
  t.warning = false
end
