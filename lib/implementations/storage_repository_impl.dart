import 'dart:convert';
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:storage_repository/constants/storage_repository_keys.dart';
import 'package:storage_repository/interfaces/storage_repository.dart';

/// A basic implementation of [StorageRepository].
///
/// This class provides a non-secure storage solution using SharedPreferences.
/// It should NOT be used for storing sensitive data, such as user tokens.
///
/// It allows storing, retrieving, and managing data efficiently in local storage.
class StorageRepositoryImpl implements StorageRepository {
  /// SharedPreferences instance.
  late SharedPreferences storage;

  /// Key used to identify the storage box.
  late final String keyPrefix;

  /// Prefix used in log messages to identify storage-related logs.
  final String logPrefix;

  /// Constructor for `StorageRepositoryImpl`.
  ///
  /// - [keyPrefix]: The prefix used to namespace storage keys for this repository instance.
  /// - [logPrefix]: Prefix for log messages.
  StorageRepositoryImpl({
    this.keyPrefix = StorageRepositoryKeys.defaultKeyPrefix,
    this.logPrefix = StorageRepositoryKeys.defaultStorageRepositoryLogPrefix,
  });

  String _generateKey(String key) => '$keyPrefix-$key';
  String _sanitizeKey(String key) =>
      keyPrefix.isNotEmpty ? key.substring(keyPrefix.length + 1) : key;

  /// Initializes the storage repository.
  ///
  /// This method should be called immediately after creating an instance of this class.
  /// It performs one-time migration from Hive storage if [migrateFromHive] is true.
  ///
  /// Returns an instance of [StorageRepository] once initialized.
  @override
  Future<StorageRepository> init([bool migrateFromHive = true]) async {
    storage = await SharedPreferences.getInstance();

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

    Box? hiveStorageBox;

    try {
      // Attempt to open the Hive storage box.
      hiveStorageBox = await Hive.openBox(keyPrefix);
    } catch (e) {
      debugPrint(e.toString());

      // If an error occurs, delete the storage box and retry opening it.
      Hive.deleteBoxFromDisk(keyPrefix);
      try {
        hiveStorageBox = await Hive.openBox(keyPrefix);
      } catch (e) {
        debugPrint(e.toString());
      }
    }

    if (hiveStorageBox != null) {
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
      await storage.setString(_generateKey(key), encodedValue);
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
      final encodedValue = storage.get(_generateKey(key));

      // If value is not found or is not a string, return it as is.
      if (encodedValue == null || encodedValue is! String) {
        return encodedValue;
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
    final entries = storage
        .getKeys()
        .where((key) => key.startsWith(keyPrefix))
        .toList()
        .map((key) {
          final encodedValue = storage.get(key);

          return MapEntry<String, dynamic>(
            _sanitizeKey(key),
            (encodedValue == null || encodedValue is! String)
                ? encodedValue
                : json.decode(encodedValue),
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
    return storage.containsKey(_generateKey(key));
  }

  /// Deletes an item from storage using the given key.
  ///
  /// - [key]: The key of the item to delete.
  ///
  /// Returns `true` if deletion was successful, otherwise `false`.
  @override
  Future<bool> delete(String key) async {
    try {
      await storage.remove(_generateKey(key));
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
      final allKeys = storage.getKeys().where(
        (key) => key.startsWith(keyPrefix),
      );

      for (final key in allKeys) {
        await storage.remove(key);
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
