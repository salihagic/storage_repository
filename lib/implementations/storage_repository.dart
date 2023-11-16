import 'dart:convert';
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:storage_repository/constants/storage_repository_keys.dart';
import 'package:storage_repository/interfaces/i_storage_repository.dart';

///A basic implementation of IStorageRepository
///Don't use in case you want to persist some sensitive data like user tokens
class StorageRepository implements IStorageRepository {
  late Box storage;
  late final String key;
  final String logPrefix;

  StorageRepository({
    this.key = StorageRepositoryKeys.defaultBoxKey,
    this.logPrefix = StorageRepositoryKeys.defaultStorageRepositoryLogPrefix,
  });

  static Future<void> initFlutter() async {
    await Hive.initFlutter();
  }

  ///Method that should be called right after the
  ///initialization of an instance of this class
  @override
  Future<IStorageRepository> init() async {
    try {
      storage = await Hive.openBox(key);
    } catch (e) {
      print(e);
      Hive.deleteBoxFromDisk(key);

      try {
        storage = await Hive.openBox(key);
      } catch (e) {
        print(e);
      }
    }

    return this;
  }

  ///Method that is used to save data to device's storage
  @override
  Future<bool> set(dynamic key, dynamic value) async {
    try {
      final encodedValue = json.encode(value);

      await storage.put(key, encodedValue);

      return true;
    } catch (e) {
      debugPrint('$logPrefix exception: $e');

      return false;
    }
  }

  ///Method used to get the value saved under a given key
  @override
  dynamic get(dynamic key) {
    try {
      if (key == null) {
        return null;
      }

      final encodedValue = storage.get(key);

      if (encodedValue == null || encodedValue is! String) {
        return encodedValue;
      }

      final value = json.decode(encodedValue);

      return value;
    } catch (e) {
      debugPrint(e.toString());

      return null;
    }
  }

  ///Method used to get all key-value pairs
  @override
  Future<Map<String, dynamic>> getAll() async {
    final entries = storage.keys.map(
      (key) {
        final encodedValue = storage.get(key);

        return MapEntry<String, dynamic>(
          key,
          (encodedValue == null || encodedValue is! String)
              ? encodedValue
              : json.decode(encodedValue),
        );
      },
    );

    return Map.fromEntries(entries);
  }

  ///Method that checks exsistance of data under a given key
  @override
  Future<bool> contains(dynamic key) async {
    return key != null && storage.containsKey(key);
  }

  ///Method that removes an item under a given key
  @override
  Future<bool> delete(dynamic key) async {
    try {
      await storage.delete(key);

      return true;
    } catch (e) {
      debugPrint('$logPrefix exception: $e');

      return false;
    }
  }

  ///Use carefully
  ///Method that resets the storage, removes all the saved data
  @override
  Future<bool> clear() async {
    try {
      await storage.clear();

      return true;
    } catch (e) {
      debugPrint('$logPrefix exception: $e');

      return false;
    }
  }

  ///Info method used for logging all the data to a console
  @override
  Future log() async {
    developer.log(await asString());
  }

  @override
  Future<String> asString() async {
    final StringBuffer stringBuffer = StringBuffer();

    stringBuffer.write(
        '\n----------------------------------------------------------------------------------------');
    stringBuffer.write('\n$logPrefix data:');
    stringBuffer.write(
        '\n----------------------------------------------------------------------------------------');
    (await getAll())
        .forEach((key, value) => stringBuffer.write('\n\n$key: $value'));
    stringBuffer.write(
        '\n----------------------------------------------------------------------------------------');

    return stringBuffer.toString();
  }
}
