import 'dart:convert';
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:storage_repository/constants/storage_repository_keys.dart';
import 'package:storage_repository/interfaces/storage_repository.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive/hive.dart';
import 'package:storage_repository/constants/_all.dart';

/// A secure implementation of [StorageRepository].
///
/// This implementation is designed to securely persist sensitive data,
/// such as user authentication tokens, using FlutterSecureStorage.
class SecureStorageRepositoryImpl implements StorageRepository {
  /// Instance of `FlutterSecureStorage` used to securely store encryption keys.
  late FlutterSecureStorage storage;

  /// Key used to identify the storage box.
  late final String keyPrefix;

  /// Prefix used in log messages to identify storage-related logs.
  final String logPrefix;

  /// Constructor for `SecureStorageRepositoryImpl`.
  ///
  /// - [keyPrefix]: The prefix used to namespace storage keys for this repository instance.
  /// - [logPrefix]: Prefix for log messages.
  SecureStorageRepositoryImpl({
    this.keyPrefix = StorageRepositoryKeys.defaultKeyPrefix,
    this.logPrefix = StorageRepositoryKeys.defaultStorageRepositoryLogPrefix,
  });

  String _generateKey(String key) => '$keyPrefix-$key';
  String _sanitizeKey(String key) =>
      keyPrefix.isNotEmpty ? key.substring(keyPrefix.length + 1) : key;

  AndroidOptions _getAndroidOptions() =>
      const AndroidOptions(encryptedSharedPreferences: true);

  /// Initializes the storage repository.
  ///
  /// This method should be called immediately after creating an instance of this class.
  /// It performs one-time migration from Hive storage if [migrateFromHive] is true.
  ///
  /// Returns an instance of [StorageRepository] once initialized.
  @override
  Future<StorageRepository> init([bool migrateFromHive = true]) async {
    storage = FlutterSecureStorage(aOptions: _getAndroidOptions());

    if (migrateFromHive) {
      await _migrateFromHive();
    }

    return this;
  }

  Future<void> _migrateFromHive() async {
    // final migrationAlreadyDone = await get(StorageRepositoryKeys.migrationCheckKey);

    // if (migrationAlreadyDone == true) {
    //   return;
    // }

    const encryptionKeyStorageKey = StorageRepositoryKeys.encryptionKey;

    var containsEncryptionKey = false;

    try {
      // Check if an encryption key already exists in secure storage.
      containsEncryptionKey =
          await storage.read(key: encryptionKeyStorageKey) != null;
    } on PlatformException catch (_) {
      // If there's an error accessing secure storage, clear all stored data.
      await storage.deleteAll();
    }

    // If no encryption key exists, generate a new one and store it securely.
    if (!containsEncryptionKey) {
      final secureEncryptionKey = base64UrlEncode(Hive.generateSecureKey());
      await storage.write(
        key: encryptionKeyStorageKey,
        value: secureEncryptionKey,
      );
    }

    // Retrieve and decode the encryption key for Hive storage.
    final encryptionKeyValue = base64Url.decode(
      await storage.read(key: encryptionKeyStorageKey) ?? '',
    );

    // Open a Hive box with AES encryption.
    final hiveStorageBox = await Hive.openBox(
      keyPrefix,
      encryptionCipher: HiveAesCipher(encryptionKeyValue),
    );

    for (final key in hiveStorageBox.keys) {
      final encodedValue = hiveStorageBox.get(key);
      final hiveValue = (encodedValue == null || encodedValue is! String)
          ? encodedValue
          : json.decode(encodedValue);

      debugPrint('FOUND STORAGE ITEM WITH KEY: $key AND VALUE: $hiveValue');

      if (hiveValue != null) {
        if (!await contains(key)) {
          await set(key, hiveValue);

          debugPrint(
            'MIGRATED STORAGE ITEM WITH KEY: $key AND VALUE: $hiveValue',
          );
        }
      }
    }

    await set(StorageRepositoryKeys.migrationCheckKey, true);
  }

  /// Saves a key-value pair to the device's storage.
  ///
  /// - [key]: The key to store the data under.
  /// - [value]: The data to be stored.
  ///
  /// Returns `true` if the operation was successful, otherwise `false`.
  @override
  Future<bool> set(String key, dynamic value) async {
    try {
      // Convert value to JSON format before storing.
      final encodedValue = json.encode(value);
      await storage.write(key: _generateKey(key), value: encodedValue);
      return true;
    } catch (e) {
      debugPrint('$logPrefix exception: $e');
      return false;
    }
  }

  /// Retrieves the value stored under the given key.
  ///
  /// - [key]: The key for the stored data.
  ///
  /// Returns the decoded value if found, otherwise `null`.
  @override
  Future<dynamic> get(String key) async {
    try {
      // Retrieve the encoded value from storage.
      final encodedValue = await storage.read(key: _generateKey(key));

      // If value is not found return it as is.
      if (encodedValue == null) {
        return null;
      }

      // Decode the JSON-encoded value before returning.
      final value = json.decode(encodedValue);
      return value;
    } catch (e) {
      debugPrint(e.toString());
      return null;
    }
  }

  /// Retrieves all stored key-value pairs.
  ///
  /// Returns a `Map<String, dynamic>` containing all stored data.
  @override
  Future<Map<String, dynamic>> getAll() async {
    final entries = (await storage.readAll()).entries
        .where((x) => x.key.startsWith(keyPrefix))
        .toList()
        .map((x) {
          return MapEntry<String, dynamic>(
            _sanitizeKey(x.key),
            json.decode(x.value),
          );
        });

    return Map.fromEntries(entries);
  }

  /// Checks if a given key exists in the storage.
  ///
  /// - [key]: The key to check.
  ///
  /// Returns `true` if the key exists, otherwise `false`.
  @override
  Future<bool> contains(String key) async {
    return await storage.containsKey(key: _generateKey(key));
  }

  /// Deletes an item from storage using the given key.
  ///
  /// - [key]: The key of the item to delete.
  ///
  /// Returns `true` if deletion was successful, otherwise `false`.
  @override
  Future<bool> delete(String key) async {
    try {
      await storage.delete(key: _generateKey(key));
      return true;
    } catch (e) {
      debugPrint('$logPrefix exception: $e');
      return false;
    }
  }

  /// **Use with caution**
  ///
  /// Clears all data stored in the repository.
  ///
  /// Returns `true` if successful, otherwise `false`.
  @override
  Future<bool> clear() async {
    try {
      final allKeys = (await storage.readAll()).keys.where(
        (key) => key.startsWith(keyPrefix),
      );

      for (final key in allKeys) {
        await storage.delete(key: key);
      }

      return true;
    } catch (e) {
      debugPrint('$logPrefix exception: $e');
      return false;
    }
  }

  /// Logs all stored data to the console.
  ///
  /// Useful for debugging purposes.
  @override
  Future<void> log() async {
    developer.log(await asString());
  }

  /// Returns the stored data as a formatted string.
  ///
  /// This method helps in debugging by providing a structured view of the stored key-value pairs.
  @override
  Future<String> asString() async {
    final StringBuffer stringBuffer = StringBuffer();

    stringBuffer.write(
      '\n----------------------------------------------------------------------------------------',
    );
    stringBuffer.write('\n$logPrefix data:');
    stringBuffer.write(
      '\n----------------------------------------------------------------------------------------',
    );

    // Retrieve all stored key-value pairs and format them.
    (await getAll()).forEach(
      (key, value) => stringBuffer.write('\n\n$key: $value'),
    );

    stringBuffer.write(
      '\n----------------------------------------------------------------------------------------',
    );

    return stringBuffer.toString();
  }
}
