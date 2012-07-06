# Benchmarks

## Comments

Diskcached wasn't designed to be a faster solution, just a simpler
one when compaired to Memcached. However, from these benchmarks,
it holds up will and even should provide slightly faster reads.


## Ruby 1.8.7
 
**Warning:** Tests do not pass and therefore this isn't expected 
to actaully work on ruby 1.8.7 at this point. I'm including the
benchmarks for it as an academic excercise.
 
#### small string * 100000

<pre>
                  user     system      total        real
  diskcached set  3.260000   5.630000   8.890000 ( 21.660488)
  memcached  set  1.460000   1.280000   2.740000 (  4.070615)
  diskcached get  1.800000   0.720000   2.520000 (  2.541142)
  memcached  get  1.160000   1.410000   2.570000 (  3.609896)
</pre> 
 
#### large hash * 100000

<pre>
                 user     system      total        real
  diskcached set 17.740000   8.140000  25.880000 ( 59.677151)
  memcached  set 13.840000   1.960000  15.800000 ( 18.235553)
  diskcached get 11.860000   1.100000  12.960000 ( 13.003900)
  memcached  get  9.270000   1.880000  11.150000 ( 12.346795)
</pre>

## Ruby 1.9.2p318
 
#### small string * 100000

<pre>
                  user     system      total        real
  diskcached set  3.370000   4.980000   8.350000 ( 20.467971)
  memcached  set  1.340000   1.300000   2.640000 (  3.962354)
  diskcached get  1.570000   0.350000   1.920000 (  1.939561)
  memcached  get  1.330000   1.250000   2.580000 (  3.604914)
</pre>
 
#### large hash * 100000

<pre>
                 user     system      total        real
  diskcached set 21.460000   6.950000  28.410000 ( 58.982826)
  memcached  set 16.510000   1.920000  18.430000 ( 20.862692)
  diskcached get 16.570000   0.690000  17.260000 ( 17.306181)
  memcached  get 12.120000   1.630000  13.750000 ( 14.967464)
</pre>


## Ruby 1.9.3p194
 
#### small string * 100000

<pre>
                  user     system      total        real
  diskcached set  3.520000   5.220000   8.740000 ( 21.928190)
  memcached  set  1.350000   1.480000   2.830000 (  4.178223)
  diskcached get  1.830000   0.370000   2.200000 (  2.215781)
  memcached  get  1.570000   1.710000   3.280000 (  4.662109)
</pre> 
 
#### large hash * 100000

<pre>
                 user     system      total        real
  diskcached set 20.670000   7.170000  27.840000 ( 59.877671)
  memcached  set 15.310000   2.790000  18.100000 ( 21.132083)
  diskcached get 14.950000   0.700000  15.650000 ( 15.720669)
  memcached  get 14.850000   1.840000  16.690000 ( 17.971276)
</pre>
