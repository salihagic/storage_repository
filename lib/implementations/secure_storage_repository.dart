import 'dart:convert';
import 'dart:developer' as developer;
import 'package:storage_repository/interfaces/i_storage_repository.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

///A secure implementation of IStorageRepository
///Use this implementation in case you want to persist some sensitive data like user tokens
class SecureStorageRepository implements IStorageRepository {
  late FlutterSecureStorage _storage;

  ///Method that should be called right after the
  ///initialization of an instance of this class
  @override
  Future<IStorageRepository> init() async {
    _storage = const FlutterSecureStorage();
    return this;
  }

  ///Method that is used to save data to device's storage (securely)
  @override
  Future<bool> set<T>(dynamic key, T value) async {
    if (key != null) {
      await _storage.write(key: json.encode(key), value: json.encode(value ?? ''));
    }

    return true;
  }

  ///Method used to get the value saved under a given key
  @override
  Future<T?> get<T>(dynamic key) async {
    final value = await _storage.read(key: json.encode(key));
    return value != null ? json.decode(value) : null;
  }

  ///Method that checks exsistance of data under a given key
  @override
  Future<bool> contains(dynamic key) async {
    return key != null && await _storage.containsKey(key: json.encode(key));
  }

  ///Method that removes an item under a given key
  @override
  Future<bool> delete(dynamic key) async {
    if (key != null) {
      await _storage.delete(key: json.encode(key));
    }

    return true;
  }

  ///Use carefully
  ///Method that resets the storage, removes all the saved data
  @override
  Future<bool> clear() async {
    await _storage.deleteAll();
    return true;
  }

  ///Info method used for logging all the data to a console
  @override
  Future log() async {
    developer.log(await asString());
  }

  @override
  Future<String> asString() async {
    final StringBuffer stringBuffer = StringBuffer();

    stringBuffer.write('\n----------------------------------------------------------------------------------------');
    stringBuffer.write('\nSecure storage repository data:');
    stringBuffer.write('\n----------------------------------------------------------------------------------------');
    (await _storage.readAll()).forEach((key, value) {
      stringBuffer.write('\n\n$key: $value');
    });
    stringBuffer.write('\n----------------------------------------------------------------------------------------');

    return stringBuffer.toString();
  }
}
