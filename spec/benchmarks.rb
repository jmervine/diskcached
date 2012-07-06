#!/usr/bin/env ruby
require 'benchmark'
require 'memcached'
require File.join(File.dirname(__FILE__), '..', 'lib', 'diskcached')

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

  diskcache  = Diskcached.new('/tmp/benchmark')
  memcache = Memcached.new('localhost:11211')

  puts " "
  puts "#### small string * #{TIMES}"
  dataset = SMALL_STR

  diskcache.set('read', dataset)
  memcache.set 'read', dataset

  Benchmark.bm do |b|
    b.report('diskcached set') do
      (1..TIMES).each do
        diskcache.set('write', dataset)
      end
    end
    b.report('memcached  set') do
      (1..TIMES).each do
        memcache.set 'write', dataset
      end
    end
    b.report('diskcached get') do
      (1..TIMES).each do
        x = diskcache.get('read') 
      end
    end
    b.report('memcached  get') do
      (1..TIMES).each do
        memcache.get 'read'
      end
    end
  end

  diskcache.expire_all!
  diskcache.expire_all!

  puts " "
  puts " "
  puts "#### large hash * #{TIMES}"
  dataset = LARGE_HASH

  diskcache.cache('read') { dataset }
  memcache.set 'read', dataset
  Benchmark.bm do |b|
    b.report('diskcached set') do
      (1..TIMES).each do
        diskcache.set('write', dataset)
      end
    end
    b.report('memcached  set') do
      (1..TIMES).each do
        memcache.set 'write', dataset
      end
    end
    b.report('diskcached get') do
      (1..TIMES).each do
        x = diskcache.get('read') 
      end
    end
    b.report('memcached  get') do
      (1..TIMES).each do
        memcache.get 'read'
      end
    end
  end

