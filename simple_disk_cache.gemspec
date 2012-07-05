# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)
 
require 'simple_disk_cache'
 
Gem::Specification.new do |s|
  s.name        = "simple_disk_cache"
  s.version     = SimpleDiskCache::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Joshua Mervine"]
  s.email       = ["joshua@mervine.net"]
  s.homepage    = "http://github.com/jmervine/simple_disk_cache"
  s.summary     = "Simple disk cache"
  s.description = "Simple disk cache for things like Sinatra"
 
  s.required_rubygems_version = ">= 1.3.6"
  #s.rubyforge_project         = ""
 
  s.add_development_dependency "rspec"
  s.add_development_dependency "simplecov"
  s.add_development_dependency "rdoc"
 
  s.files        = Dir.glob("lib/**/*") + %w(README.txt)
  s.require_path = 'lib'
end

