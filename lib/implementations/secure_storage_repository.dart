import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive/hive.dart';
import 'package:storage_repository/constants/_all.dart';
import 'package:storage_repository/implementations/storage_repository.dart';
import 'package:storage_repository/interfaces/i_storage_repository.dart';

///A secure implementation of IStorageRepository
///Use this implementation in case you want to persist some sensitive data like user tokens
class SecureStorageRepository extends StorageRepository
    implements IStorageRepository {
  final String key;
  final FlutterSecureStorage flutterSecureStorage = FlutterSecureStorage();

  SecureStorageRepository({
    this.key = AppKeys.defaultSecureBoxKey,
  });

  ///Method that should be called as soon as possible
  @override
  Future<IStorageRepository> init() async {
    final encryptionKeyStorageKey = json.encode(AppKeys.encryptionKey);

    var containsEncryptionKey = false;

    try {
      containsEncryptionKey =
          await flutterSecureStorage.read(key: encryptionKeyStorageKey) != null;
    } on PlatformException catch (_) {
      await flutterSecureStorage.deleteAll();
    }

    if (!containsEncryptionKey) {
      final secureEncryptionKey =
          json.encode(base64UrlEncode(Hive.generateSecureKey()));
      await flutterSecureStorage.write(
          key: encryptionKeyStorageKey, value: secureEncryptionKey);
    }

    final encryptionKeyValue = base64Url.decode(json.decode(
        await flutterSecureStorage.read(key: encryptionKeyStorageKey) ?? ''));

    storage = await Hive.openBox(key,
        encryptionCipher: HiveAesCipher(encryptionKeyValue));

    return this;
  }

  /// Generates strong 32 byte (256 bit) encryption key for secure storage
  static List<int> generateSecureKey() => Hive.generateSecureKey();

  @override
  Future<String> asString() async {
    final StringBuffer stringBuffer = StringBuffer();

    stringBuffer.write(
        '\n----------------------------------------------------------------------------------------');
    stringBuffer.write('\nSecure storage repository data:');
    stringBuffer.write(
        '\n----------------------------------------------------------------------------------------');
    (await getAll())
        .forEach((key, value) => stringBuffer.write('\n\n$key: $value'));
    stringBuffer.write(
        '\n----------------------------------------------------------------------------------------');

    return stringBuffer.toString();
  }
}
