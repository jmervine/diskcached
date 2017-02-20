# @author Joshua P. Mervine <joshua@mervine.net>
class Diskcached
  # version for gem
  VERSION = '1.1.2'

  # disk location for cache store
  attr_reader :store

  # cache timeout
  attr_reader :timeout

  # time of last #garbage_collect
  attr_reader :gc_last

  # should auto_garbage_collect
  attr_reader :gc_auto

  # how often to auto_garbage_collect
  attr_reader :gc_time

  # initialize object
  # - set #store to passed or default ('/tmp/cache')
  # - set #timeout to passed or default ('600')
  # - set #autogc to passed or default ('false')
  # - run #ensure_store_directory
  def initialize store="/tmp/cache", timeout=600, autogc=true
    @store   = store
    @timeout = timeout

    @gc_last, @gc_time = nil

    # true or false, this will be ignored if @gc_last and @gc_time
    # are nil
    @gc_auto = autogc

    unless timeout.nil?
      send(:timeout=, timeout)
    end

    ensure_store_directory
  end

  def timeout=(t)
    @gc_last = Time.now
    @gc_time = t
  end

  # return true if cache with 'key' is expired
  def expired? key
    return false if timeout.nil?
    mtime = read_cache_mtime(key)
    return (mtime.nil? || mtime+timeout <= Time.now)
  end

  # expire cache with 'key'
  def delete key
    File.delete( cache_file(key) ) if File.exists?( cache_file(key) )
  end

  # expire (delete) all caches in #store directory
  def flush
    Dir[ File.join( store, '*.cache' ) ].each do |file|
      File.delete(file)
    end
  end

  # flush expired caches if garbage collection
  # hasn't been run recently
  def flush_expired
    if gc_last && gc_time && gc_last+gc_time <= Time.now
      flush_expired!
    end
  end

  # flash expired caches, ingoring when garbage
  # collection was last run
  def flush_expired!
    Dir[ File.join( store, "*.cache" ) ].each do |f|
      if (File.mtime(f)+timeout) <= Time.now
        File.delete(f)
      end
    end
    @gc_last = Time.now
  end

  # create and read cache with 'key'
  # - creates cache if it doesn't exist
  # - reads cache if it exists
  def cache key
    begin
      if expired?(key)
        content = Proc.new { yield }.call
        set( key, content )
      end
      content ||= get( key )
      return content
    rescue LocalJumpError
      return nil
    end
  end

  # set cache with 'key'
  # - run #auto_garbage_collect
  # - creates cache if it doesn't exist
  def set key, value
    begin
      write_cache_file( key, Marshal::dump(value) )
      flush_expired if gc_auto
      return true
    rescue
      flush_expired if gc_auto
      return false
    end
  end
  alias :add :set        # for memcached compatability
  alias :replace :set    # for memcached compatability

  # get cache with 'key'
  # - reads cache if it exists and isn't expired
  #   or raises Diskcache::NotFound
  # - if 'key' is an Array returns only keys
  #   which exist and aren't expired, it raises
  #   Diskcache::NotFound if none are available
  def get key
    if key.is_a? Array
      ret = {}
      key.each do |k|
        ret[k] = Marshal::load(read_cache_file(k)) unless expired?(k)
      end

      raise if ret.empty?
      return ret
    end

    raise if expired?(key)

    return Marshal::load(read_cache_file(key))
  rescue
    raise Diskcached::NotFound
  ensure
    flush_expired if gc_auto
  end

  # returns path to cache file with 'key'
  def cache_file key
    File.join( store, key+".cache" )
  end

  private
  # creates the actual cache file
  def write_cache_file key, content
    f = File.open( cache_file(key), "w+" )
    f.flock(File::LOCK_EX)
    f.write( content )
    f.close
    return content
  end

  # reads the actual cache file
  def read_cache_file key
    f = File.open( cache_file(key), "r" )
    f.flock(File::LOCK_SH)
    out = f.read
    f.close
    return out
  end

  # returns mtime of cache file or nil if
  # file doesn't exist
  def read_cache_mtime key
    return nil unless File.exists?(cache_file(key))
    File.mtime( cache_file(key) )
  end

  # creates #store directory if it doesn't exist
  def ensure_store_directory
    FileUtils.mkpath( store ) unless File.directory?( store )
  end

  class NotFound < Exception
  end

end
