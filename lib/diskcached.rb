# @author Joshua P. Mervine <joshua@mervine.net>
# 
class Diskcached
  # version for gem
  VERSION = '1.0.1'

  # disk location for cache store
  attr_reader :store
  
  # cache timeout
  attr_reader :timeout
 
  # time of last #garbage_collect_expired_caches
  attr_reader :last_gc

  # initialize object
  # - set #store to passed or default ('/tmp/cache')
  # - set #timeout to passed or default ('600')
  # - set #last_gc to current time
  # - run #ensure_store_directory
  def initialize store="/tmp/cache", timeout=600
    @store   = store
    @timeout = timeout
    @last_gc = Time.now
    ensure_store_directory
  end

  # return true if cache with 'key' is expired
  def expired? key
    mtime = read_cache_mtime(key)
    return (mtime.nil? || mtime+timeout <= Time.now)
  end

  # expire cache with 'key'
  def expire! key
    File.delete( cache_file(key) ) if File.exists?( cache_file(key) )
  end
  alias :delete :expire!

  # expire (delete) all caches in #store directory
  def expire_all! 
    Dir[ File.join( store, '*.cache' ) ].each do |file|
      File.delete(file) 
    end
  end
  alias :flush :expire_all!

  # create and read cache with 'key'
  # - run #garbage_collect_expired_caches 
  # - creates cache if it doesn't exist
  # - reads cache if it exists
  def cache key
    garbage_collect_expired_caches
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
  alias :set_or_get :cache
  alias :sog :cache

  # set cache with 'key'
  # - run #garbage_collect_expired_caches 
  # - creates cache if it doesn't exist
  def set key, value
    garbage_collect_expired_caches
    begin
      write_cache_file( key, Marshal::dump(value) )
      return true
    rescue
      return false
    end
  end
  alias :add :set
  alias :replace :set

  # get cache with 'key'
  # - reads cache if it exists and isn't expired 
  #   or raises Diskcache::NotFound
  # - if 'key' is an Array returns only keys 
  #   which exist and aren't expired, it raises
  #   Diskcache::NotFound if none are available
  def get key
    garbage_collect_expired_caches
    begin
      if key.is_a? Array
        hash = {}
        key.each do |k|
          hash[k] = Marshal::load(read_cache_file(k)) unless expired?(k)
        end
        return hash unless hash.empty?
      else
        return Marshal::load(read_cache_file(key)) unless expired?(key)
      end
      raise Diskcached::NotFound
    rescue
      raise Diskcached::NotFound
    end
  end

  # returns path to cache file with 'key'
  def cache_file key
    File.join( store, key+".cache" )
  end


  private
  # delete all expired caches every #timeout seconds
  # on being called
  def garbage_collect_expired_caches
    if last_gc+timeout <= Time.now
      Dir[ File.join( store, "*.cache" ) ].each do |f| 
        if (File.mtime(f)+timeout) <= Time.now
          File.delete(f) 
        end
      end
    end
  end

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
    Dir.mkdir( store ) unless File.directory?( store )
  end

  class NotFound < Exception
  end

end
