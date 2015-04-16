# Diskcached

> Simple disk cache for things like Sinatra which is implemented much like Memcached in hopes that in some cases they're interchangeable.

### [Documentation](http://jmervine.github.com/diskcached/doc/Diskcached.html) | [Coverage](http://jmervine.github.com/diskcached/coverage/index.html#_AllFiles) | [Benchmarks](https://github.com/jmervine/diskcached/wiki/Benchmark-Output)

## Introduction

I created Diskcached as a simple cacheing layer for things like html fragments and database calls. I thought about using [memcached](http://memcached.org/), but as the app I was working on was running on a single server, it seemed overkill. Additionally, I looked at using [rack-cache](http://rtomayko.github.com/rack-cache/), but I felt it was a bit more complex then I was looking for. So Diskcached was born (although it was origiionally released as "simple\_disk\_cache" -- for about 12 hours).

* To the comment: "I'm not clear how memcached on a single server is overkill."
>  1. In some cases -- e.g. Dreamhost shared hosting and Heroku (I believe) -- it is difficult, if not impossible to install memcached. This is for those situations.
>  1. In all cases, disk space is cheaper than memory. For example, when I used [myhosting.com](http://myhosting.com), which charges $1 per 20G of disk storage and $1 per 512MB of memory. So in my case, I use Diskcached instead of memcached and my memory foot print is ~300MB. While at the moment, I could very easily handle running memcached without running out of memory, using disk based cacheing allows me to scale much further before having to upgrade my hosting package. Additionally, if you [check out my blogs performance metrics](https://github.com/jmervine/ditty/wiki/Performance), you'll see that Diskcached brought me from ~140ms render times, to ~1ms render times, allowing me to scale even further.

* To the comment: "If you need memcache...then use it."
>  * I totally agree!

## Installation

    :::shell
    gem install diskcached

Or with [Bundler](http://mervine.net/tag/bundler):

    :::ruby
    source :rubygems
    gem 'diskcached'

## Basic Usage

### Block Style

    :::ruby
    require 'diskcached'
    @diskcache = Diskcached.new

    result = @diskcache.cache('expensive_code') do
      # some expensive code
    end

    puts result

The above will create the cache if it doesn't exist and cache the result of block and return it. If the cache exists and isn't expired, it will read from the cache and returnwhat's stored. This allows you to passively wrap code in a cache block and not worry about checking to see if it's valid or expired.

Also worth noting, it will return `nil` if something goes wrong.

### Memcached Style

Using Diskcached like this should allow for a "drag and drop" replacement of Memcached, should you so decide.

    :::ruby
    require 'diskcached'
    @diskcache = Diskcached.new

    begin
      result = @diskcache.get('expensive_code')
    rescue # Diskcached::NotFound # prevents easy replacement, but is safer.
      result = run_expensive_code
      @diskcache.set('expensive_code', result)
    end

    puts result

It's important to note that Diskcached is quite a bit simpler then Memcached and in some ways more forgiving. If Memcached compatability is really important, refer to Memcached docs as well as Diskcached docs when implementing your code.

## Benchmarks

### Comments

Diskcached wasn't designed to be a faster solution, just a simpler
one when compaired to Memcached. However, from these benchmarks,
it holds up will and even should provide slightly faster reads.

##### [Moved to 'Benchmark Output'](https://github.com/jmervine/diskcached/wiki/Benchmark-Output)

## Sinatra Application 'httperf' results.

On a development machine (Unicorn w/ 1 worker) I ran a series of [httperf](http://www.hpl.hp.com/research/linux/httperf/) tests to see how Diskcached ran in real world situations. You can [checkout the full output from multiple examples here](https://gist.github.com/3062334), but there's a taste...

Using the endpoint [http://mervine.net/](http://mervine.net/) on my dev server and hitting it 100,000 times --

### Code Example from Test

    :::ruby
     15   configure do
            ...
     44     $diskcache = Diskcached.new(File.join(settings.root, 'cache'))
     45     $diskcache.flush # ensure caches are empty on startup
     46   end
          ...
     58   before do
            ...
     61     @cache_key = cache_sha(request.path_info)
     62   end
          ...
    231   get "/" do
    232     begin
    233       raise Diskcached::NotFound if authorized?
    234       content = $diskcache.get(@cache_key)
    235       logger.debug("reading index from cache") unless authorized?
    236     rescue Diskcached::NotFound
    237       logger.debug("storing index to cache") unless authorized?
    238       content = haml(:index, :layout => choose_layout)
    239       $diskcache.set(@cache_key, content) unless authorized?
    240     end
    241     content
    242   end

### Test Results

    :::shell
    httperf --client=0/1 --server=localhost --port=9001 --uri=/ --send-buffer=4096 --recv-buffer=16384 --num-conns=100000 --num-calls=1
    httperf: warning: open file limit > FD_SETSIZE; limiting max. # of open files to FD_SETS

    Maximum connect burst length: 1

    Total: connections 100000 requests 100000 replies 100000 test-duration 744.646 s

    Connection rate: 134.3 conn/s (7.4 ms/conn, <=1 concurrent connections)
    Connection time [ms]: min 1.9 avg 7.4 max 398.8 median 4.5 stddev 10.5
    Connection time [ms]: connect 0.1
    Connection length [replies/conn]: 1.000

    Request rate: 134.3 req/s (7.4 ms/req)
    Request size [B]: 62.0

    Reply rate [replies/s]: min 116.6 avg 134.3 max 147.2 stddev 6.1 (148 samples)
    Reply time [ms]: response 6.9 transfer 0.5
    Reply size [B]: header 216.0 content 105088.0 footer 0.0 (total 105304.0)
    Reply status: 1xx=0 2xx=100000 3xx=0 4xx=0 5xx=0

    CPU time [s]: user 287.88 system 115.60 (user 38.7% system 15.5% total 54.2%)
    Net I/O: 13818.2 KB/s (113.2*10^6 bps)

    Errors: total 0 client-timo 0 socket-timo 0 connrefused 0 connreset 0
    Errors: fd-unavail 0 addrunavail 0 ftab-full 0 other 0

