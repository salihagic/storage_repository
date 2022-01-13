import 'dart:developer' as developer;
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:storage_repository/interfaces/i_storage_repository.dart';

///A basic implementation of IStorageRepository
///Don't use in case you want to persist some sensitive data like user tokens
class StorageRepository implements IStorageRepository {
  late Box storage;
  late final String key;

  StorageRepository({this.key = 'DEFAULT_BOX'});

  static Future<void> initFlutter() async {
    await Hive.initFlutter();
  }

  ///Method that should be called right after the
  ///initialization of an instance of this class
  @override
  Future<IStorageRepository> init() async {
    storage = await Hive.openBox(key);
    return this;
  }

  ///Method that is used to save data to device's storage
  @override
  Future<bool> set<T>(dynamic key, T value) async {
    try {
      await storage.put(json.encode(key), json.encode(value ?? ''));

      return true;
    } catch (e) {
      debugPrint('StorageRepository Exception: $e');
    }

    return false;
  }

  ///Method used to get the value saved under a given key
  @override
  Future<E?> get<E>(dynamic key) async {
    if (key == null) return null;
    final value = storage.get(json.encode(key));
    return value != null ? json.decode(value) : null;
  }

  ///Method used to get all key-value pairs
  @override
  Future<Map<dynamic, E?>> getAll<E>() async {
    final entries = storage.keys.map(
      (key) {
        final decodedKey = json.decode(key);
        final value = decodedKey != null ? storage.get(decodedKey) : null;
        final decodedValue = value != null ? json.decode(value) : null;

        print('decodedKey: $decodedKey');
        print('value: $value');
        print('decodedValue: $decodedValue\n\n');

        return MapEntry<dynamic, E?>(decodedKey, decodedValue);
      },
    );

    return Map.fromEntries(entries);
  }

  ///Method that checks exsistance of data under a given key
  @override
  Future<bool> contains(dynamic key) async {
    return key != null && storage.containsKey(json.encode(key));
  }

  ///Method that removes an item under a given key
  @override
  Future<bool> delete(dynamic key) async {
    try {
      await storage.delete(json.encode(key));

      return true;
    } catch (e) {
      debugPrint('StorageRepository Exception: $e');
    }
    return false;
  }

  ///Use carefully
  ///Method that resets the storage, removes all the saved data
  @override
  Future<bool> clear() async {
    try {
      await storage.clear();
      return true;
    } catch (e) {
      debugPrint('StorageRepository Exception: $e');
    }
    return false;
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
    stringBuffer.write('\nStorage repository data:');
    stringBuffer.write(
        '\n----------------------------------------------------------------------------------------');
    (await getAll())
        .forEach((key, value) => stringBuffer.write('\n\n$key: $value'));
    stringBuffer.write(
        '\n----------------------------------------------------------------------------------------');

    return stringBuffer.toString();
  }
}
