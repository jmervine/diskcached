#!/usr/bin/env ruby
require 'benchmark'
require File.join(File.dirname(__FILE__), '..', 'lib', 'simple_disk_cache')

write_cache = SimpleDiskCache.new('/tmp/benchmark',0)
read_cache = SimpleDiskCache.new('/tmp/benchmark')

read_cache.cache('read') { "foo" }

times = 100000
puts "-"*60
puts " benchmarking 'foo' #{times} times using"
puts "   #{`ruby --version`.chomp}"
puts "-"*60
Benchmark.bm do |b|
  b.report('write') do
    (1..times).each do
      write_cache.cache('write') { "foo" }
    end
  end
  b.report(' read') do
    (1..times).each do
      x = read_cache.cache('read') 
    end
  end
end
puts " "
puts "-"*60
puts " benchmarking large hash #{times} times using"
puts "   #{`ruby --version`.chomp}"
puts "-"*60

large_hash = {}
(1..100).each do |i|
  large_hash["key#{i}"] = "foo"*100
end

write_cache.expire_all!
read_cache.expire_all!
read_cache.cache('read') { large_hash }

Benchmark.bm do |b|
  b.report('write') do
    (1..times).each do
      write_cache.cache('write') { large_hash }
    end
  end
  b.report(' read') do
    (1..times).each do
      x = read_cache.cache('read') 
    end
  end
end
puts "-"*60
