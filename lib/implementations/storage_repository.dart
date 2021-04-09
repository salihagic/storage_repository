import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:storage_repository/interfaces/i_storage_repository.dart';

///A basic implementation of IStorageRepository
///Don't use in case you want to persist some sensitive data like user tokens
class StorageRepository implements IStorageRepository {
  late Box _storage;
  static const key = 'DEFAULT_BOX';

  ///Method that should be called right after the
  ///initialization of an instance of this class
  @override
  Future<IStorageRepository> init() async {
    await Hive.initFlutter();
    _storage = await Hive.openBox('DEFAULT_BOX');
    return this;
  }

  ///Method that is used to save data to device's storage
  @override
  Future<bool> set<T>(dynamic key, T value) async {
    try {
      await _storage.put(json.encode(key), json.encode(value ?? ''));

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
    final value = _storage.get(json.encode(key));
    return value != null ? json.decode(value) : null;
  }

  ///Method that checks exsistance of data under a given key
  @override
  Future<bool> contains(dynamic key) async {
    return key != null && _storage.containsKey(json.encode(key));
  }

  ///Method that removes an item under a given key
  @override
  Future<bool> delete(dynamic key) async {
    try {
      await _storage.delete(json.encode(key));

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
      await _storage.clear();
      return true;
    } catch (e) {
      debugPrint('StorageRepository Exception: $e');
    }
    return false;
  }

  ///Info method used for logging all the data to a console
  @override
  Future print() async {
    debugPrint(
        '\n----------------------------------------------------------------------------------------');
    debugPrint('Storage repository data:');
    debugPrint(
        '----------------------------------------------------------------------------------------');
    _storage.keys.forEach((key) {
      debugPrint('\n\n${key.toString()}: ${_storage.get(key)}');
    });
    debugPrint(
        '\n----------------------------------------------------------------------------------------\n');
  }
}
