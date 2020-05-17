import 'package:hive/hive.dart';
import 'package:stash/stash_api.dart';
import 'package:stash_hive/src/hive/hive_extensions.dart';

class HiveStore extends CacheStore {
  final dynamic Function(Map<String, dynamic>) _fromEncodable;

  final String path;
  final Map<String, LazyBox<Map>> _cacheStoreMap = {};

  HiveStore(this.path, {dynamic Function(Map<String, dynamic>) fromEncodable})
      : _fromEncodable = fromEncodable;

  Future<LazyBox<Map>> _cacheStore(String name) {
    if (_cacheStoreMap.containsKey(name)) {
      return Future.value(_cacheStoreMap[name]);
    }

    return Hive.openLazyBox<Map>(name, path: path).then((store) {
      _cacheStoreMap[name] = store;

      return store;
    });
  }

  @override
  Future<int> size(String name) =>
      _cacheStore(name).then((store) => store.length);

  Future<Iterable<String>> _getKeys(String name) {
    return _cacheStore(name).then((store) => store.keys.cast<String>());
  }

  @override
  Future<Iterable<String>> keys(String name) => _getKeys(name);

  Future<CacheEntry> _getEntryFromStore(LazyBox<Map> store, String key) =>
      store.get(key).then((value) => value != null
          ? HiveExtensions.fromJson(value.cast<String, dynamic>(),
              fromJson: _fromEncodable)
          : null);

  Future<CacheEntry> _getEntry(String name, String key) {
    return _cacheStore(name).then((store) => _getEntryFromStore(store, key));
  }

  Future<CacheStat> _getStat(String name, String key) {
    return _getEntry(name, key).then((entry) => entry.stat);
  }

  Future<Iterable<CacheStat>> _getStats(String name, Iterable<String> keys) {
    return Stream.fromIterable(keys)
        .asyncMap((key) => _getStat(name, key))
        .toList();
  }

  @override
  Future<Iterable<CacheStat>> stats(String name) =>
      _getKeys(name).then((keys) => _getStats(name, keys));

  Future<Iterable<CacheEntry>> _getValues(String name) {
    return _getKeys(name).then((keys) => Stream.fromIterable(keys)
        .asyncMap((key) => _getEntry(name, key))
        .toList());
  }

  @override
  Future<Iterable<CacheEntry>> values(String name) => _getValues(name);

  @override
  Future<bool> containsKey(String name, String key) =>
      _cacheStore(name).then((store) => store.containsKey(key));

  @override
  Future<CacheStat> getStat(String name, String key) {
    return _getStat(name, key);
  }

  @override
  Future<Iterable<CacheStat>> getStats(String name, Iterable<String> keys) {
    return _getStats(name, keys);
  }

  @override
  Future<void> setStat(String name, String key, CacheStat stat) {
    return _cacheStore(name).then((store) {
      return _getEntryFromStore(store, key)
          .then((entry) => store.put(key, (entry..stat = stat).toHiveJson()));
    });
  }

  @override
  Future<CacheEntry> getEntry(String name, String key) {
    return _getEntry(name, key);
  }

  @override
  Future<void> putEntry(String name, String key, CacheEntry entry) {
    return _cacheStore(name)
        .then((store) => store.put(key, entry.toHiveJson()));
  }

  @override
  Future<void> remove(String name, String key) {
    return _cacheStore(name).then((store) => store.delete(key));
  }

  @override
  Future<void> clear(String name) {
    return _cacheStore(name).then((store) => store.clear());
  }

  @override
  Future<void> delete(String name) {
    if (_cacheStoreMap.containsKey(name)) {
      _cacheStoreMap.remove(name);
      return Hive.deleteBoxFromDisk(name);
    }

    return Future.value();
  }

  @override
  Future<void> deleteAll() {
    return Future.wait(_cacheStoreMap.keys.map((name) {
      return Hive.deleteBoxFromDisk(name)
          .then((_) => _cacheStoreMap.remove(name));
    }));
  }
}
