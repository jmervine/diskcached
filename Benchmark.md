# Benchmarks

## Ruby 1.8.7
 
**Warning:** Tests do not pass and therefore this isn't expected 
to actaully work on ruby 1.8.7 at this point. I'm including the
benchmarks for it as an academic excercise.

#### small string * 100000

<pre>
                 user     system      total        real
  diskcached set  2.700000   2.450000   5.150000 (  5.198298)
  memcached  set  1.470000   1.300000   2.770000 (  4.112875)
  diskcached get  1.370000   0.060000   1.430000 (  1.437898)
  memcached  get  1.260000   1.360000   2.620000 (  3.651778)
</pre>
 
 
#### large hash * 100000

<pre>
                user     system      total        real
  diskcached set 13.100000   4.120000  17.220000 ( 17.321050)
  memcached  set 12.770000   2.420000  15.190000 ( 18.106920)
  diskcached get  1.330000   0.080000   1.410000 (  1.415962)
  memcached  get  8.660000   1.610000  10.270000 ( 11.194536)
</pre>


## Ruby 1.9.2p318
 
#### small string * 100000

<pre>
                 user     system      total        real
  diskcached set  2.630000   2.150000   4.780000 (  4.809938)
  memcached  set  1.670000   1.640000   3.310000 (  5.108809)
  diskcached get  1.310000   0.060000   1.370000 (  1.374200)
  memcached  get  1.690000   1.890000   3.580000 (  5.216778)
</pre>

 
#### large hash * 100000

<pre>
                user     system      total        real
  diskcached set 16.850000   3.810000  20.660000 ( 20.753545)
  memcached  set 16.370000   1.900000  18.270000 ( 20.650906)
  diskcached get  1.310000   0.070000   1.380000 (  1.378545)
  memcached  get 11.510000   1.610000  13.120000 ( 14.036453)
</pre>


## Ruby 1.9.3p194
 
#### small string * 100000

<pre>
                 user     system      total        real
  diskcached set  2.820000   2.190000   5.010000 (  5.042452)
  memcached  set  1.380000   1.410000   2.790000 (  4.122374)
  diskcached get  1.380000   0.040000   1.420000 (  1.414243)
  memcached  get  1.350000   1.320000   2.670000 (  3.696904)
</pre>
 
 
#### large hash * 100000

<pre>
                user     system      total        real
  diskcached set 16.410000   3.410000  19.820000 ( 19.936363)
  memcached  set 17.570000   2.160000  19.730000 ( 22.692966)
  diskcached get  1.330000   0.050000   1.380000 (  1.396471)
  memcached  get 13.410000   1.950000  15.360000 ( 16.601655)
</pre>


