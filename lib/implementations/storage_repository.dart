import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:storage_repository/interfaces/i_storage_repository.dart';

///A basic implementation of IStorageRepository
///Don't use in case you want to persist some sensitive data like user tokens
class StorageRepository implements IStorageRepository {
  late SharedPreferences _storage;

  ///Method that should be called right after the
  ///initialization of an instance of this class
  @override
  Future<IStorageRepository> init() async {
    _storage = await SharedPreferences.getInstance();
    return this;
  }

  ///Method that is used to save data to device's storage
  @override
  Future<bool> set<T>(dynamic key, T value) async {
    return key != null &&
        await _storage.setString(json.encode(key), json.encode(value ?? ''));
  }

  ///Method used to get the value saved under a given key
  @override
  Future<E?> get<E>(dynamic key) async {
    if (key == null) return null;
    final value = _storage.getString(json.encode(key));
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
    return key != null && await _storage.remove(json.encode(key));
  }

  ///Use carefully
  ///Method that resets the storage, removes all the saved data
  @override
  Future<bool> clear() async {
    return await _storage.clear();
  }

  ///Info method used for logging all the data to a console
  @override
  Future print() async {
    debugPrint(
        '\n----------------------------------------------------------------------------------------');
    debugPrint('Storage repository data:');
    debugPrint(
        '----------------------------------------------------------------------------------------');
    _storage.getKeys().forEach((key) {
      debugPrint('\n\n$key: ${_storage.getString(key)}');
    });
    debugPrint(
        '\n----------------------------------------------------------------------------------------\n');
  }
}
