# -*- ruby -*-

require 'rubygems'
require 'rspec/core/rake_task'
require './lib/diskcached'
RSpec::Core::RakeTask.new(:spec)
task :default => :spec

task :rdoc do
  puts %x{ rdoc -f rubydoc -t "Diskcached #{Diskcached::VERSION} ./lib/**/*" }
end

task :benchmark do
  load './spec/benchmarks.rb'
end

task :package do
  puts %x{ gem build diskcached.gemspec && (mkdir ./pkg; mv *.gem ./pkg/ ) }
end

# vim: syntax=ruby
