require 'spec_helper.rb'


describe Diskcached do
  describe '#new' do
    it "should init" do
      expect { @cache = Diskcached.new }.should_not raise_error
    end
    it "should init with 'store'" do
      expect { @cache = Diskcached.new('/tmp/rspec/cache') }.should_not raise_error
      @cache.store.should eq '/tmp/rspec/cache'
    end
    it "should init with 'store' and 'timeout'" do
      expect { @cache = Diskcached.new('/tmp/rspec/cache', 10) }.should_not raise_error
      @cache.timeout.should eq 10
    end
    it "should init with 'store', 'timeout' and 'gc_auto'" do
      expect { @cache = Diskcached.new('/tmp/rspec/cache', 10, false) }.should_not raise_error
      @cache.gc_auto.should be_false
    end
    it "should set 'gc_time' to nil if 'timeout' is nil" do
      expect { @cache = Diskcached.new('/tmp/rspec/cache', nil) }.should_not raise_error
      @cache.gc_time.should be_nil
    end
    it "should set 'gc_last' to nil if 'timeout' is nil" do
      expect { @cache = Diskcached.new('/tmp/rspec/cache', nil) }.should_not raise_error
      @cache.gc_last.should be_nil
    end
    it "should set 'gc_auto' to false if 'timeout' is nil" do
      expect { @cache = Diskcached.new('/tmp/rspec/cache', nil) }.should_not raise_error
      @cache.gc_auto.should be_false
    end
    it "should create cache dir if it doesn't exist" do
      File.directory?('/tmp/rspec/cache').should be_true
    end
  end

  describe "#set", "(alias #add, #replace)" do
    before(:all) do
      @cache = Diskcached.new("/tmp/rspec/cache")
    end
    it "should create a new cache" do
      @cache.set('test1', "test string").should be_true
    end
    it "should create a file on disk" do
      File.exists?("/tmp/rspec/cache/test1.cache").should be_true
    end
  end

  describe "#get", "single" do
    before(:all) do
      @cache = Diskcached.new("/tmp/rspec/cache", 0.5)
    end
    it "should read cache before expiration" do
      @cache.get('test1').should eq "test string"
      @cache.get('test1').should be_a_kind_of String
    end
    it "should expire correctly" do
      sleep 0.51
      expect { @cache.get('test1') }.should raise_error /Diskcached::NotFound/
    end
  end

  describe "#get", "multiple" do
    before(:all) do
      @cache = Diskcached.new("/tmp/rspec/cache", 0.5)
      @cache.set('test1', "test string")
      @cache.set('test2', "test string")
    end
    it "should read multiple caches into a Hash" do
      @cache.get(['test1', 'test2']).should be_a_kind_of Hash
      @cache.get(['test1', 'test2']).keys.count.should eq 2
      @cache.get(['test1', 'test2'])['test1'].should eq "test string"
    end
    it "should expire correctly" do
      sleep 0.51
      expect { @cache.get(['test1', 'test2']) }.should raise_error /Diskcached::NotFound/
    end
  end

  describe "#cache" do
    before(:all) do
      @cache = Diskcached.new("/tmp/rspec/cache", 0.5)
    end
    it "should create a new cache" do
      @cache.cache('test1') do
        "test string"
      end.should eq "test string"
      File.exists?("/tmp/rspec/cache/test1.cache").should be_true
    end
    it "should create a file on disk" do
      File.exists?("/tmp/rspec/cache/test1.cache").should be_true
    end
    it "should read cache before expiration" do
      @cache.cache('test1').should eq "test string"
      @cache.cache('test1').should be_a_kind_of String
    end
    it "should expire correctly" do
      sleep 0.51
      @cache.cache('test1') do
        "new test string"
      end.should eq "new test string"
    end
    it "should return nil if no block is passed and cache is expired" do
      sleep 0.51 
      @cache.cache('test1').should be_nil
    end
  end

  describe "#expired?" do
    before(:all) do
      @cache = Diskcached.new("/tmp/rspec/cache", 0.1)
      @cache.cache('test2') { "cache test2" }
    end
    it "should be false" do
      @cache.expired?('test2').should be_false
    end
    it "should be true" do
      sleep 0.11
      @cache.expired?('test2').should be_true
    end
  end
  
  describe "#delete" do
    before(:all) do
      @cache = Diskcached.new("/tmp/rspec/cache")
      @cache.cache('test3') { "cache test3" }
    end
    it "should expire cache" do
      @cache.expired?('test3').should be_false
      expect { @cache.delete('test3') }.should_not raise_error
      @cache.expired?('test3').should be_true
    end
    it "should remove cache file" do
      File.exists?("/tmp/rspec/cache/test3.cache").should be_false
    end
  end

  describe "#flush" do
    before(:all) do
      @cache = Diskcached.new("/tmp/rspec/cache")
      @cache.cache('test4') { "cache test4" }
      @cache.cache('test5') { "cache test5" }
      @cache.cache('test6') { "cache test6" }
    end
    it "should expire all caches" do
      @cache.expired?('test4').should be_false
      @cache.expired?('test5').should be_false
      @cache.expired?('test6').should be_false
      expect { @cache.flush }.should_not raise_error
      @cache.expired?('test4').should be_true
      @cache.expired?('test5').should be_true
      @cache.expired?('test6').should be_true
    end
    it "should remove all cache files" do
      Dir['/tmp/rspec/cache/*.cache'].should be_empty
    end
  end

  describe "#flush_expired" do
    before(:all) do
      @cache = Diskcached.new("/tmp/rspec/cache", 0.5)
      @cache.cache('flush1') { "cache flush" }
    end
    it "should not flush caches that aren't expired" do
      @cache.expired?('flush1').should be_false
      expect { @cache.flush_expired }.should_not raise_error
      @cache.expired?('flush1').should be_false
    end
    it "should not flush caches if caches recently flushed" do
      sleep 0.5
      @cache.expired?('flush1').should be_true
      @cache.instance_variable_set(:@gc_last, Time.now)
      expect { @cache.flush_expired }.should_not raise_error
      File.exists?('/tmp/rspec/cache/flush1.cache').should be_true
    end
    it "should flush caches are are expired" do
      sleep 0.5
      expect { @cache.flush_expired }.should_not raise_error
      @cache.expired?('flush1').should be_true
      sleep 0.1
      File.exists?('/tmp/rspec/cache/flush1.cache').should be_false
    end
  end

  describe "#flush_expired!" do
    before(:all) do
      @cache = Diskcached.new("/tmp/rspec/cache", 0.5)
      @cache.cache('flush1') { "cache flush" }
    end
    it "should not flush caches that aren't expired" do
      @cache.expired?('flush1').should be_false
      expect { @cache.flush_expired! }.should_not raise_error
      @cache.expired?('flush1').should be_false
    end
    it "should flush caches even when recently flushed" do
      sleep 0.5
      @cache.expired?('flush1').should be_true
      @cache.instance_variable_set(:@gc_last, Time.now)
      expect { @cache.flush_expired! }.should_not raise_error
      sleep 0.1
      File.exists?('/tmp/rspec/cache/flush1.cache').should be_false
    end
  end

  describe "#cache_file" do
    before(:all) do
      @cache = Diskcached.new("/tmp/rspec/cache")
    end
    it "should build cache path" do
      @cache.cache_file("test7").should eq "/tmp/rspec/cache/test7.cache"
    end
  end

  describe "automatic garbage collection ON" do
    before(:all) do
      @cache = Diskcached.new("/tmp/rspec/cache", 0.5)
      @cache.cache('test8') { "cache test8" }
      @cache.cache('test9') { "cache test9" }
      @cache.cache('test10') { "cache test10" }
    end
    it "should clean up expired caches" do
      sleep 0.51
      expect { @cache.cache('test10') { "cache test10" } }.should_not raise_error
      sleep 0.1
      File.exists?(@cache.cache_file('test8')).should be_false
      File.exists?(@cache.cache_file('test9')).should be_false
      File.exists?(@cache.cache_file('test10')).should be_true
    end
  end

  describe "automatic garbage collection OFF" do
    before(:all) do
      @cache = Diskcached.new("/tmp/rspec/cache", 0.5, false)
      @cache.cache('test8') { "cache test8" }
      @cache.cache('test9') { "cache test9" }
      @cache.cache('test10') { "cache test10" }
    end
    it "should not clean up expired caches" do
      sleep 0.51
      expect { @cache.cache('test10') { "cache test10" } }.should_not raise_error
      sleep 0.1
      File.exists?(@cache.cache_file('test8')).should be_true
      File.exists?(@cache.cache_file('test9')).should be_true
      File.exists?(@cache.cache_file('test10')).should be_true
    end
  end

end

describe Diskcached, "advanced test cases" do
  before(:all) do
    @cache = Diskcached.new('/tmp/rspec/cache')
    @testo = TestObject.new
  end

  it "should cache array" do
    @cache.cache('array') { @testo.array }
    @cache.cache('array').should be_a_kind_of Array
    @cache.cache('array').count.should eq 3

    @cache.set('array1', @testo.array)
    @cache.get('array1').should be_a_kind_of Array
    @cache.get('array1').count.should eq 3
  end

  it "should cache string" do
    @cache.cache('string') { @testo.string }
    @cache.cache('string').should be_a_kind_of String
    @cache.cache('string').should eq "foo bar bah"

    @cache.set('string1', @testo.string)
    @cache.get('string1').should be_a_kind_of String
    @cache.get('string1').should eq "foo bar bah"
  end

  it "should cache number" do
    @cache.cache('num') { @testo.num }
    @cache.cache('num').should be_a_kind_of Integer
    @cache.cache('num').should eq 3

    @cache.set('num1', @testo.num)
    @cache.get('num1').should be_a_kind_of Integer
    @cache.get('num1').should eq 3
  end

  it "should cache hash" do
    @cache.cache('hash') { @testo.hash }
    @cache.cache('hash').should be_a_kind_of Hash
    @cache.cache('hash').should have_key :foo

    @cache.set('hash1', @testo.hash)
    @cache.get('hash1').should be_a_kind_of Hash
    @cache.get('hash1').should have_key :foo
  end

  it "should cache simple objects" do
    @cache.cache('object') { @testo.obj }
    @cache.cache('object').should be_a_kind_of TestSubObject
    @cache.cache('object').sub_foo.should eq "foo"

    @cache.set('object1', @testo.obj)
    @cache.get('object1').should be_a_kind_of TestSubObject
    @cache.get('object1').sub_foo.should eq "foo"
  end
  it "should cache modified objects" do
    @cache.delete('object')
    @cache.cache('object') do 
      o = @testo.obj
      o.sub_bar = 'bar'
      o
    end
    @cache.cache('object').should be_a_kind_of TestSubObject
    @cache.cache('object').sub_bar.should eq 'bar'
  end 
  it "should cache complex objects" do
    # might be redundant, but tests more complexity
    @cache.delete('object')
    @cache.cache('object') { TestObject.new }
    @cache.cache('object').array.should be_a_kind_of Array
    @cache.cache('object').string.should be_a_kind_of String
    @cache.cache('object').hash.should be_a_kind_of Hash
    @cache.cache('object').obj.should be_a_kind_of TestSubObject
  end

end
