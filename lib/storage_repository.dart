import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class IStorageRepository {
  Future<IStorageRepository> init();
  Future<bool> set<T>(dynamic key, T value);
  T? get<T>(dynamic key);
  bool contains(dynamic key);
  Future<bool> delete(dynamic key);
  void print();
  Future clear();
}

class StorageRepository implements IStorageRepository {
  late SharedPreferences storage;

  Future<IStorageRepository> init() async {
    storage = await SharedPreferences.getInstance();
    return this;
  }

  @override
  Future<bool> set<T>(dynamic key, T value) async {
    return key != null && await storage.setString(json.encode(key), json.encode(value ?? ''));
  }

  @override
  E? get<E>(dynamic key) {
    final value = storage.getString(json.encode(key));
    return value != null ? json.decode(value) : null;
  }

  @override
  bool contains(dynamic key) {
    return key != null && storage.containsKey(json.encode(key));
  }

  @override
  Future<bool> delete(dynamic key) async {
    return key != null && await storage.remove(json.encode(key));
  }

  Future<bool> clear() async {
    return await storage.clear();
  }

  void print() {
    debugPrint('\n----------------------------------------------------------------------------------------');
    debugPrint('Storage repository data:');
    debugPrint('----------------------------------------------------------------------------------------');
    storage.getKeys().forEach((key) {
      debugPrint('\n\n$key: ${storage.getString(key)}');
    });
    debugPrint('\n----------------------------------------------------------------------------------------\n');
  }
}
