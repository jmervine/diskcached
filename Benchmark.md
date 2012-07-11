# Benchmarks

## Comments

Diskcached wasn't designed to be a faster solution, just a simpler
one when compaired to Memcached. However, from these benchmarks,
it holds up will and even should provide slightly faster reads.

## Ruby 1.9.3p194
 
#### small string * 100000
<pre>
                user     system      total        real
diskcached set  3.110000   5.160000   8.270000 ( 20.986365)
memcached  set  1.410000   1.390000   2.800000 (  4.203253)
diskcached get  1.290000   0.440000   1.730000 (  1.743141)
memcached  get  1.230000   1.360000   2.590000 (  3.618572)
</pre> 
 
#### large hash * 100000
<pre>
               user     system      total        real
diskcached set 19.630000   6.980000  26.610000 ( 60.177955)
memcached  set 17.050000   2.390000  19.440000 ( 22.410836)
diskcached get 13.300000   0.610000  13.910000 ( 13.978462)
memcached  get 12.570000   1.520000  14.090000 ( 14.822417)
</pre>

## Ruby 1.9.2p318
 
### small string * 100000
<pre>
                user     system      total        real
diskcached set  3.130000   5.000000   8.130000 ( 20.267969)
memcached  set  1.290000   1.360000   2.650000 (  3.987257)
diskcached get  1.300000   0.430000   1.730000 (  1.734428)
memcached  get  1.200000   1.370000   2.570000 (  3.609192)
</pre> 
 
### large hash * 100000
<pre>
               user     system      total        real
diskcached set 20.140000   6.610000  26.750000 ( 59.838819)
memcached  set 15.480000   2.790000  18.270000 ( 20.464405)
diskcached get 13.490000   0.750000  14.240000 ( 14.271641)
memcached  get 13.080000   1.430000  14.510000 ( 15.253489)
</pre>


