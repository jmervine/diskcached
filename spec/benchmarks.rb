#!/usr/bin/env ruby
require 'benchmark'
require 'memcached'
require File.join(File.dirname(__FILE__), '..', 'lib', 'simple_disk_cache')

# benchmarks helpers

def large_hash
  hash = {}
  (1..100).each do |i|
    hash["key#{i}"] = "foo"*100
  end
  return hash
end
# Set up data sets #
LARGE_HASH = large_hash
SMALL_STR  = "foo"
TIMES      = 100000

# print ruby version as header
puts "## Ruby #{`ruby -v | awk '{print $2}'`.chomp}"

  write_cache = SimpleDiskCache.new('/tmp/benchmark',0)
  read_cache  = SimpleDiskCache.new('/tmp/benchmark')
  memcache = Memcached.new('localhost:11211')

  puts " "
  puts "#### small string * #{TIMES}"
  dataset = SMALL_STR

  read_cache.cache('read') { dataset }
  memcache.set 'read', dataset

  Benchmark.bm do |b|
    b.report('s_d_cache set') do
      (1..TIMES).each do
        write_cache.cache('write') { dataset }
      end
    end
    b.report('memcached set') do
      (1..TIMES).each do
        memcache.set 'write', dataset
      end
    end
    b.report('s_d_cache get') do
      (1..TIMES).each do
        x = read_cache.cache('read') 
      end
    end
    b.report('memcached get') do
      (1..TIMES).each do
        memcache.get 'read'
      end
    end
  end

  write_cache.expire_all!
  read_cache.expire_all!

  puts " "
  puts " "
  puts "#### large hash * #{TIMES}"
  dataset = LARGE_HASH

  read_cache.cache('read') { dataset }
  memcache.set 'read', dataset
  Benchmark.bm do |b|
    b.report('s_d_cache set') do
      (1..TIMES).each do
        write_cache.cache('write') { dataset }
      end
    end
    b.report('memcached set') do
      (1..TIMES).each do
        memcache.set 'write', dataset
      end
    end
    b.report('s_d_cache get') do
      (1..TIMES).each do
        x = read_cache.cache('read') 
      end
    end
    b.report('memcached get') do
      (1..TIMES).each do
        memcache.get 'read'
      end
    end
  end

