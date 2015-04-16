require 'simplecov'
SimpleCov.start do
    add_filter "/vendor/"
end

require 'tmpdir'
require 'rspec'
require 'fileutils'
require './lib/diskcached'

$cachedir = File.join(Dir.tmpdir, 'rspec')

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
if File.directory?($cachedir)
  FileUtils.rm_rf($cachedir)
end

# create new rspec test directory
Dir.mkdir($cachedir)
