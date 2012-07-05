require 'rspec'
require 'fileutils'
require './lib/simple_disk_cache.rb'

# create things to cache and test
class TestObject
  @value = nil
  def array
    %w{ foo bar bah }
  end
  def string
    "foo bar bah"
  end
  def num
    3
  end
  def hash
    { :foo => "foo",
      :bar => "bar",
      :bah => "bah"
    }
  end
  def obj
    TestSubObject.new 
  end
end
class TestSubObject
  attr_accessor :sub_foo, :sub_bar
  def initialize
    @sub_foo = "foo"
    @sub_bar = nil
  end
end

# delete old rspec test directories
if File.directory?('/tmp/rspec')
  FileUtils.rm_rf('/tmp/rspec') 
end

# create new rspec test directory
Dir.mkdir('/tmp/rspec')

