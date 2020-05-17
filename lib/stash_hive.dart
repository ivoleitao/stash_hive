/// Provides a Hive implementation of the Stash caching API for Dart
library stash_hive;

import 'package:stash/stash_api.dart';
import 'package:stash_hive/src/hive/hive_store.dart';

export 'src/hive/hive_store.dart';

Cache newHiveCache(String path,
    {String cacheName,
    KeySampler sampler,
    EvictionPolicy evictionPolicy,
    int maxEntries,
    ExpiryPolicy expiryPolicy,
    CacheLoader cacheLoader,
    dynamic Function(dynamic) fromEncodable}) {
  return Cache.newCache(HiveStore(path, fromEncodable: fromEncodable),
      name: cacheName,
      expiryPolicy: expiryPolicy,
      sampler: sampler,
      evictionPolicy: evictionPolicy,
      maxEntries: maxEntries,
      cacheLoader: cacheLoader);
}
