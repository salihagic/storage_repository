import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

///Abstract class for Storage repository to serve as
///an interface when using DI pattern
abstract class IStorageRepository {
  ///Method declaration for initializing the storage
  Future<IStorageRepository> init();

  ///Method declaration for saving the data under a given key
  Future<bool> set<T>(dynamic key, T value);

  ///Method declaration to get the data by a given key
  T? get<T>(dynamic key);

  ///Method declaration for checking the existance of saved
  ///data under a given key
  bool contains(dynamic key);

  ///Method declaration for deleting the data saved under a given key
  Future<bool> delete(dynamic key);

  ///Method declaration for a method the should log all the data to the console
  void print();
  Future clear();
}

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

  ///Method used to get the value save under a given key
  @override
  E? get<E>(dynamic key) {
    final value = _storage.getString(json.encode(key));
    return value != null ? json.decode(value) : null;
  }

  ///Method that checks exsistance of data under a given key
  @override
  bool contains(dynamic key) {
    return key != null && _storage.containsKey(json.encode(key));
  }

  ///Method that removes an item under a given key
  @override
  Future<bool> delete(dynamic key) async {
    return key != null && await _storage.remove(json.encode(key));
  }

  ///Use carefully
  ///Method that resets the storage, removes all the saved data
  Future<bool> clear() async {
    return await _storage.clear();
  }

  ///Info method used for logging all the data to a console
  void print() {
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
