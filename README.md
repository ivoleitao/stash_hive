# stash_hive
A [stash](https://github.com/ivoleitao/stash) storage extension for [hive](https://pub.dev/packages/hive)

[![Pub Package](https://img.shields.io/pub/v/stash_hive.svg?style=flat-square)](https://pub.dartlang.org/packages/stash_hive)
[![Build Status](https://github.com/ivoleitao/shadertoy_api/workflows/build/badge.svg)](https://github.com/ivoleitao/stash_hive/actions)
[![Coverage Status](https://codecov.io/gh/ivoleitao/stash_hive/graph/badge.svg)](https://codecov.io/gh/ivoleitao/stash_hive)
[![Package Documentation](https://img.shields.io/badge/doc-stash_hive-blue.svg)](https://www.dartdocs.org/documentation/stash_hive/latest)
[![GitHub License](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

## Introduction

This storage extension for [stash](https://pub.dartlang.org/packages/stash) provides a 
[hive](https://pub.dev/packages/hive) based storage that relies on a highly performing binary serialization of the cache items through the use of [msgpack](https://msgpack.org) serialization format.

## Getting Started

Add this to your `pubspec.yaml` (or create it):

```dart
dependencies:
    stash_hive: ^1.0.0-dev.1
```

Run the following command to install dependencies:

```dart
pub install
```

Optionally use the following command to run the tests:

```dart
pub run test
```

Finally, to start developing import the library:

```dart
import 'package:stash_hive/stash_hive.dart';
```

## Usage

The example bellow creates a cache with a Hive storage backend that supports a maximum of 10 `Task` objects. In the rather simple example bellow the serialization and deserialization of the object is coded by hand but normally it relies on the usage of libraries like [json_serializable](https://pub.dev/packages/json_serializable). Please take a look at the documentation of [stash](https://pub.dartlang.org/packages/stash) to gather additional information and to explore the full range of capabilities of the `Stash` library

```dart
import 'dart:io';

import 'package:stash_hive/stash_hive.dart';

class Task {
  final int id;
  final String title;
  final bool completed;

  Task({this.id, this.title, this.completed = false});

  /// Creates a [Task] from json map
  factory Task.fromJson(Map<String, dynamic> json) => Task(
      id: json['id'] as int,
      title: json['title'] as String,
      completed: json['completed'] as bool);

  /// Creates a json map from a [Task]
  Map<String, dynamic> toJson() =>
      <String, dynamic>{'id': id, 'title': title, 'completed': completed};

  @override
  String toString() {
    return 'Task ${id}: "${title}" is ${completed ? "completed" : "not completed"}';
  }
}

void main() async {
  // Temporary path
  final path = Directory.systemTemp.path;

  // Creates cache with a hive based storage backend with the capacity of 10 entries
  final cache = newHiveCache(path,
      maxEntries: 10, fromEncodable: (json) => Task.fromJson(json));

  // Adds a task with key 'task1' to the cache
  await cache.put(
      'task1', Task(id: 1, title: 'Run stash_hive example', completed: true));
  // Retrieves the value from the cache
  final value = await cache.get('task1');

  print(value);
}
```

## Contributing

This library is developed by best effort, in the motto of "Scratch your own itch!", meaning APIs that are meaningful for the author use cases.

If you would like to contribute with other parts of the API, feel free to make a [Github pull request](https://github.com/ivoleitao/stash_hive/pulls) as I'm always looking for contributions for:
* Tests
* Documentation
* New APIs

## Features and Bugs

Please file feature requests and bugs at the [issue tracker][tracker].

[tracker]: http://github.com/ivoleitao/stash_hive/issues/new

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details