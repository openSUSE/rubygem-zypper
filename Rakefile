require 'rake'
require 'rake/testtask'

desc 'Run all tests'
task :test do
  puts 'Running tests...'
  Rake::TestTask.new do |t|
    t.test_files = FileList['test/unit/test*.rb']
    t.verbose = true
  end
end

task :gem do
  puts "Creating gem..."
  puts `gem build zypper.gemspec`
end

task :default => :test
