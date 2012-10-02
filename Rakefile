# -*- ruby -*-

require 'rubygems'
require 'rspec/core/rake_task'
require './lib/diskcached'
RSpec::Core::RakeTask.new(:spec)
task :default => :spec

desc "generate and update gh-pages"
task :pages do
  system(" set -x; bundle exec rspec ") or abort
  system(" set -x; bundle exec yardoc --protected ./lib/**/*.rb ") or abort
  system(" set -x; rm -rf /tmp/doc /tmp/coverage ") or abort
  system(" set -x; mv -v ./doc /tmp ") or abort
  system(" set -x; mv -v ./coverage /tmp ") or abort
  system(" set -x; git checkout gh-pages ") or abort
  system(" set -x; rm -rf ./doc ./coverage ") or abort
  system(" set -x; mv -v /tmp/doc . ") or abort
  system(" set -x; mv -v /tmp/coverage . ") or abort
  system(" set -x; git add . ") or abort 
  system(" set -x; git commit --all -m 'updating doc and coverage' ") or abort
  system(" set -x; git checkout master ") or abort
  puts "don't forget to run: git push origin gh-pages"
end


task :benchmark do
  load './spec/benchmarks.rb'
end

task :package do
  puts %x{ gem build diskcached.gemspec && (mkdir ./pkg; mv *.gem ./pkg/ ) }
end

# vim: syntax=ruby
