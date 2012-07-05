class SimpleDiskCache
  VERSION = '1.0.0'

  attr_reader :store, :timeout, :last_gc
  def initialize store="/tmp/cache", timeout=600
    @store   = store
    @timeout = timeout
    @last_gc = Time.now
    ensure_store_directory
  end

  def expired? key
    mtime = read_cache_mtime(key)
    return (mtime.nil? || mtime+timeout <= Time.now)
  end

  def expire! key
    File.delete( cache_file(key) ) if File.exists?( cache_file(key) )
  end

  def expire_all! 
    Dir[ File.join( store, '*.cache' ) ].each do |file|
      File.delete(file) 
    end
  end

  def cache key
    garbage_collect_expired_caches
    begin
      if expired?(key)
        content = Proc.new { yield }.call
        write_cache_file( key, Marshal::dump(content) )  
      end
      content ||= Marshal::load(read_cache_file(key))
      return content
    rescue LocalJumpError
      return nil
    end
  end

  def cache_file key
    File.join( store, key+".cache" )
  end


  private
  def garbage_collect_expired_caches
    if last_gc+timeout <= Time.now
      Dir[ File.join( store, "*.cache" ) ].each do |f| 
        if (File.mtime(f)+timeout) <= Time.now
          File.delete(f) 
        end
      end
    end
  end

  def write_cache_file key, content
    f = File.open( cache_file(key), "w+" )
    f.flock(File::LOCK_EX)
    f.write( content )
    f.close
    return content
  end

  def read_cache_file key
    f = File.open( cache_file(key), "r" )
    f.flock(File::LOCK_SH)
    out = f.read 
    f.close
    return out
  end

  def read_cache_mtime key
    return nil unless File.exists?(cache_file(key))
    File.mtime( cache_file(key) )
  end

  def ensure_store_directory
    Dir.mkdir( store ) unless File.directory?( store )
  end

end
