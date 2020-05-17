import 'dart:io';

import 'package:stash_hive/stash_hive.dart';

void main() async {
  // Temporary path
  final path = Directory.systemTemp.path;

  // Creates a Hive based cache named 'example1'
  final cache1 = newHiveCache(path, cacheName: 'example1');

  // Adds a 'value1' under 'key1' to the cache
  await cache1.put('key1', 'value1');
  // Retrieves the value from the cache
  final value = await cache1.get('key1');

  print(value);
}
