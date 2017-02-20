require 'spec_helper.rb'

describe Diskcached do
  describe '#new' do
    it "should init" do
      expect { Diskcached.new }.to_not raise_error
    end
    it "should init with 'store'" do
      expect { @cache = Diskcached.new($cachedir) }.to_not raise_error
      expect(@cache.store).to eq($cachedir)
    end
    it "should init with 'store' and 'timeout'" do
      expect { @cache = Diskcached.new($cachedir, 10) }.to_not raise_error
      expect(@cache.timeout).to eq(10)
    end
    it "should init with 'store', 'timeout' and 'gc_auto'" do
      expect { @cache = Diskcached.new($cachedir, 10, false) }.to_not raise_error
      expect(@cache.gc_auto).to be_falsey
    end
    it "should set 'gc_time' to nil if 'timeout' is nil" do
      expect { @cache = Diskcached.new($cachedir, nil) }.to_not raise_error
      expect(@cache.gc_time).to be_nil
    end
    it "should set 'gc_last' to nil if 'timeout' is nil" do
      expect { @cache = Diskcached.new($cachedir, nil) }.to_not raise_error
      expect(@cache.gc_last).to be_nil
    end
    it "should create cache dir if it doesn't exist" do
      expect(File.directory?($cachedir)).to be_truthy
    end
  end

  describe "#set", "(alias #add, #replace)" do
    before(:all) do
      @cache = Diskcached.new($cachedir)
    end
    it "should create a new cache" do
      expect(@cache.set('test1', "test string")).to be_truthy
    end
    it "should create a file on disk" do
      expect(File.exists?(File.join($cachedir, "test1.cache"))).to be_truthy
    end
  end

  describe "#get", "single" do
    before(:all) do
      @cache = Diskcached.new($cachedir, 1)
    end
    it "should read cache before expiration" do
      expect(@cache.get('test1')).to eq "test string"
      expect(@cache.get('test1')).to be_a_kind_of String
    end
    it "should expire correctly" do
      sleep 2
      expect { @cache.get('test1') }.to raise_error /Diskcached::NotFound/
    end
  end

  describe "#get", "multiple" do
    before(:all) do
      @cache = Diskcached.new($cachedir, 1)
      @cache.set('test1', "test string")
      @cache.set('test2', "test string")
    end
    it "should read multiple caches into a Hash" do
      expect(@cache.get(['test1', 'test2'])).to be_a_kind_of Hash
      expect(@cache.get(['test1', 'test2']).keys.count).to eq 2
      expect(@cache.get(['test1', 'test2'])['test1']).to eq "test string"
    end
    it "should expire correctly" do
      sleep 2
      expect { @cache.get(['test1', 'test2']) }.to raise_error /Diskcached::NotFound/
    end
  end

  describe "#cache" do
    before(:all) do
      @cache = Diskcached.new($cachedir, 1)
    end
    it "should create a new cache" do
      expect(@cache.cache('test1') do
        "test string"
      end).to eq "test string"
      expect(File.exists?(File.join($cachedir, "test1.cache"))).to be_truthy
    end
    it "should create a file on disk" do
      expect(File.exists?(File.join($cachedir, "test1.cache"))).to be_truthy
    end
    it "should read cache before expiration" do
      expect(@cache.cache('test1')).to eq "test string"
      expect(@cache.cache('test1')).to be_a_kind_of String
    end
    it "should expire correctly" do
      sleep 2
      expect(
        @cache.cache('test1') do
          "new test string"
        end).to eq "new test string"
    end
    it "should return nil if no block is passed and cache is expired" do
      sleep 2
      expect(@cache.cache('test1')).to be_nil
    end
  end

  describe "#expired?" do
    before(:all) do
      @cache = Diskcached.new($cachedir, 1)
      @cache.cache('test2') { "cache test2" }
    end
    it "should be false" do
      expect(@cache.expired?('test2')).to be_falsey
    end
    it "should be true" do
      sleep 2
      expect(@cache.expired?('test2')).to be_truthy
    end
  end

  describe "#delete" do
    before(:all) do
      @cache = Diskcached.new($cachedir)
      @cache.cache('test3') { "cache test3" }
    end
    it "should expire cache" do
      expect(@cache.expired?('test3')).to be_falsey
      expect { @cache.delete('test3') }.to_not raise_error
      expect(@cache.expired?('test3')).to be_truthy
    end
    it "should remove cache file" do
      expect(File.exists?(File.join($cachedir, "test3.cache"))).to be_falsey
    end
  end

  describe "#flush" do
    before(:all) do
      @cache = Diskcached.new($cachedir)
      @cache.cache('test4') { "cache test4" }
      @cache.cache('test5') { "cache test5" }
      @cache.cache('test6') { "cache test6" }
    end
    it "should expire all caches" do
      expect(@cache.expired?('test4')).to be_falsey
      expect(@cache.expired?('test5')).to be_falsey
      expect(@cache.expired?('test6')).to be_falsey
      expect { @cache.flush }.to_not raise_error
      expect(@cache.expired?('test4')).to be_truthy
      expect(@cache.expired?('test5')).to be_truthy
      expect(@cache.expired?('test6')).to be_truthy
    end
    it "should remove all cache files" do
      expect(Dir[File.join($cachedir, '*.cache')]).to be_empty
    end
  end

  describe "#flush_expired" do
    before(:all) do
      @cache = Diskcached.new($cachedir, 1)
      @cache.cache('flush1') { "cache flush" }
    end
    it "should not flush caches that aren't expired" do
      expect(@cache.expired?('flush1')).to be_falsey
      expect { @cache.flush_expired }.to_not raise_error
      expect(@cache.expired?('flush1')).to be_falsey
    end
    it "should not flush caches if caches recently flushed" do
      sleep 2
      expect(@cache.expired?('flush1')).to be_truthy
      @cache.instance_variable_set(:@gc_last, Time.now)
      expect { @cache.flush_expired }.to_not raise_error
      expect(File.exists?(File.join($cachedir, "flush1.cache"))).to be_truthy
    end
    it "should flush caches are are expired" do
      sleep 2
      expect { @cache.flush_expired }.to_not raise_error
      expect(@cache.expired?('flush1')).to be_truthy
      expect(File.exists?(File.join($cachedir, "flush1.cache"))).not_to be_truthy
    end
  end

  describe "#flush_expired!" do
    before(:all) do
      @cache = Diskcached.new($cachedir, 1)
      @cache.cache('flush1') { "cache flush" }
    end
    it "should not flush caches that aren't expired" do
      expect(@cache.expired?('flush1')).to be_falsey
      expect { @cache.flush_expired! }.to_not raise_error
      expect(@cache.expired?('flush1')).to be_falsey
    end
    it "should flush caches even when recently flushed" do
      sleep 2
      expect(@cache.expired?('flush1')).to be_truthy
      @cache.instance_variable_set(:@gc_last, Time.now)
      expect { @cache.flush_expired! }.to_not raise_error
      expect(File.exists?(File.join($cachedir, "flush1.cache"))).to_not be_truthy
    end
  end

  describe "#cache_file" do
    before(:all) do
      @cache = Diskcached.new($cachedir)
    end
    it "should build cache path" do
      expect(@cache.cache_file("test7")).to eq File.join($cachedir, "test7.cache")
    end
  end

  describe "automatic garbage collection ON" do
    before(:all) do
      @cache = Diskcached.new($cachedir, 1)
      @cache.cache('test8') { "cache test8" }
      @cache.cache('test9') { "cache test9" }
      @cache.cache('test10') { "cache test10" }
    end
    it "should clean up expired caches" do
      sleep 2
      expect { @cache.cache('test10') { "cache test10" } }.to_not raise_error
      sleep 1
      expect(File.exists?(@cache.cache_file('test8'))).to be_falsey
      expect(File.exists?(@cache.cache_file('test9'))).to be_falsey
      expect(File.exists?(@cache.cache_file('test10'))).to be_truthy
    end
  end

  describe "automatic garbage collection OFF" do
    before(:all) do
      @cache = Diskcached.new($cachedir, 1, false)
      @cache.cache('test8') { "cache test8" }
      @cache.cache('test9') { "cache test9" }
      @cache.cache('test10') { "cache test10" }
    end
    it "should not clean up expired caches" do
      sleep 2
      expect { @cache.cache('test10') { "cache test10" } }.to_not raise_error
      sleep 1
      expect(File.exists?(@cache.cache_file('test8'))).to be_truthy
      expect(File.exists?(@cache.cache_file('test9'))).to be_truthy
      expect(File.exists?(@cache.cache_file('test10'))).to be_truthy
    end
  end

end

describe Diskcached, "advanced test cases" do
  before(:all) do
    @cache = Diskcached.new($cachedir)
    @testo = TestObject.new
  end

  it "should cache array" do
    @cache.cache('array') { @testo.array }
    expect(@cache.cache('array')).to be_a_kind_of Array
    expect(@cache.cache('array').count).to eq 3

    @cache.set('array1', @testo.array)
    expect(@cache.get('array1')).to be_a_kind_of Array
    expect(@cache.get('array1').count).to eq 3
  end

  it "should cache string" do
    @cache.cache('string') { @testo.string }
    expect(@cache.cache('string')).to be_a_kind_of String
    expect(@cache.cache('string')).to eq "foo bar bah"

    @cache.set('string1', @testo.string)
    expect(@cache.get('string1')).to be_a_kind_of String
    expect(@cache.get('string1')).to eq "foo bar bah"
  end

  it "should cache number" do
    @cache.cache('num') { @testo.num }
    expect(@cache.cache('num')).to be_a_kind_of Integer
    expect(@cache.cache('num')).to eq 3

    @cache.set('num1', @testo.num)
    expect(@cache.get('num1')).to be_a_kind_of Integer
    expect(@cache.get('num1')).to eq 3
  end

  it "should cache hash" do
    @cache.cache('hash') { @testo.hash }
    expect(@cache.cache('hash')).to be_a_kind_of Hash
    expect(@cache.cache('hash')).to have_key :foo

    @cache.set('hash1', @testo.hash)
    expect(@cache.get('hash1')).to be_a_kind_of Hash
    expect(@cache.get('hash1')).to have_key :foo
  end

  it "should cache simple objects" do
    @cache.cache('object') { @testo.obj }
    expect(@cache.cache('object')).to be_a_kind_of TestSubObject
    expect(@cache.cache('object').sub_foo).to eq "foo"

    @cache.set('object1', @testo.obj)
    expect(@cache.get('object1')).to be_a_kind_of TestSubObject
    expect(@cache.get('object1').sub_foo).to eq "foo"
  end
  it "should cache modified objects" do
    @cache.delete('object')
    @cache.cache('object') do
      o = @testo.obj
      o.sub_bar = 'bar'
      o
    end
    expect(@cache.cache('object')).to be_a_kind_of TestSubObject
    expect(@cache.cache('object').sub_bar).to eq 'bar'
  end
  it "should cache complex objects" do
    # might be redundant, but tests more complexity
    @cache.delete('object')
    @cache.cache('object') { TestObject.new }
    expect(@cache.cache('object').array).to be_a_kind_of Array
    expect(@cache.cache('object').string).to be_a_kind_of String
    expect(@cache.cache('object').hash).to be_a_kind_of Hash
    expect(@cache.cache('object').obj).to be_a_kind_of TestSubObject
  end

end
