= DiskCache

== Installation

gem instal disk_cache

== Tests

DiskCache
  #new
    should init
    should init with 'store'
    should init with 'store' and 'timeout'
    should create cache dir if it doesn't exist
  #cache
    should create a new cache
    should create a file on disk
    should read cache before expiration
    should expire correctly
    should return nil if no block is passed and cache is expired
  #expired?
    should be false
    should be true
  #expire!
    should expire cache
    should remove cache file
  #expire_all!
    should expire all caches
    should remove all cache files
  #cache_file
    should build cache path
  garbage collection
    should clean up expired caches

DiskCache advanced test cases
  should cache array
  should cache string
  should cache number
  should cache hash
  should cache simple objects
  should cache modified objects
  should cache complex objects

Finished in 1.66 seconds
24 examples, 0 failures

