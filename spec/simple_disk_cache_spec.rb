require 'spec_helper.rb'


describe SimpleDiskCache do
  describe '#new' do
    it "should init" do
      expect { @cache = SimpleDiskCache.new }.should_not raise_error
    end
    it "should init with 'store'" do
      expect { @cache = SimpleDiskCache.new('/tmp/rspec/cache') }.should_not raise_error
      @cache.store.should eq '/tmp/rspec/cache'
    end
    it "should init with 'store' and 'timeout'" do
      expect { @cache = SimpleDiskCache.new('/tmp/rspec/cache', 10) }.should_not raise_error
      @cache.timeout.should eq 10
    end
    it "should create cache dir if it doesn't exist" do
      File.directory?('/tmp/rspec/cache').should be_true
    end
  end

  describe "#cache" do
    before(:all) do
      @cache = SimpleDiskCache.new("/tmp/rspec/cache", 0.5)
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
      @cache = SimpleDiskCache.new("/tmp/rspec/cache", 0.1)
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
  
  describe "#expire!" do
    before(:all) do
      @cache = SimpleDiskCache.new("/tmp/rspec/cache")
      @cache.cache('test3') { "cache test3" }
    end
    it "should expire cache" do
      @cache.expired?('test3').should be_false
      expect { @cache.expire!('test3') }.should_not raise_error
      @cache.expired?('test3').should be_true
    end
    it "should remove cache file" do
      File.exists?("/tmp/rspec/cache/test3.cache").should be_false
    end
  end

  describe "#expire_all!" do
    before(:all) do
      @cache = SimpleDiskCache.new("/tmp/rspec/cache")
      @cache.cache('test4') { "cache test4" }
      @cache.cache('test5') { "cache test5" }
      @cache.cache('test6') { "cache test6" }
    end
    it "should expire all caches" do
      @cache.expired?('test4').should be_false
      @cache.expired?('test5').should be_false
      @cache.expired?('test6').should be_false
      expect { @cache.expire_all! }.should_not raise_error
      @cache.expired?('test4').should be_true
      @cache.expired?('test5').should be_true
      @cache.expired?('test6').should be_true
    end
    it "should remove all cache files" do
      Dir['/tmp/rspec/cache/*.cache'].should be_empty
    end
  end

  describe "#cache_file" do
    before(:all) do
      @cache = SimpleDiskCache.new("/tmp/rspec/cache")
    end
    it "should build cache path" do
      @cache.cache_file("test7").should eq "/tmp/rspec/cache/test7.cache"
    end
  end

  describe "garbage collection" do
    before(:all) do
      @cache = SimpleDiskCache.new("/tmp/rspec/cache", 0.5)
      @cache.cache('test8') { "cache test8" }
      @cache.cache('test9') { "cache test9" }
      @cache.cache('test10') { "cache test10" }
    end
    it "should clean up expired caches" do
      sleep 0.51
      expect { @cache.cache('test10') { "cache test10" } }.should_not raise_error
      File.exists?(@cache.cache_file('test8')).should be_false
      File.exists?(@cache.cache_file('test9')).should be_false
      File.exists?(@cache.cache_file('test10')).should be_true
    end
  end
end

describe SimpleDiskCache, "advanced test cases" do
  before(:all) do
    @cache = SimpleDiskCache.new('/tmp/rspec/cache')
    @testo = TestObject.new
  end

  it "should cache array" do
    @cache.cache('array') { @testo.array }
    @cache.cache('array').should be_a_kind_of Array
    @cache.cache('array').count.should eq 3
  end

  it "should cache string" do
    @cache.cache('string') { @testo.string }
    @cache.cache('string').should be_a_kind_of String
    @cache.cache('string').should eq "foo bar bah"
  end

  it "should cache number" do
    @cache.cache('num') { @testo.num }
    @cache.cache('num').should be_a_kind_of Integer
    @cache.cache('num').should eq 3
  end

  it "should cache hash" do
    @cache.cache('hash') { @testo.hash }
    @cache.cache('hash').should be_a_kind_of Hash
    @cache.cache('hash').should have_key :foo
  end

  it "should cache simple objects" do
    @cache.cache('object') { @testo.obj }
    @cache.cache('object').should be_a_kind_of TestSubObject
    @cache.cache('object').sub_foo.should eq "foo"
  end
  it "should cache modified objects" do
    @cache.expire!('object')
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
    @cache.expire!('object')
    @cache.cache('object') { TestObject.new }
    @cache.cache('object').array.should be_a_kind_of Array
    @cache.cache('object').string.should be_a_kind_of String
    @cache.cache('object').hash.should be_a_kind_of Hash
    @cache.cache('object').obj.should be_a_kind_of TestSubObject
  end

end
