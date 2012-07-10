### 1.1.0

* refactored garbage collection
  * fixed bug where auto gc happens every time once initial timeout duration has past
  * allow for turning auto gc on and off
  * cap auto gc timeout at 600 seconds
  * other optimizations
* removed 'expire!' for 'delete'
* removed 'expire_all!' for 'flush'
* removed 'set_or_get' and 'sog' aliases

