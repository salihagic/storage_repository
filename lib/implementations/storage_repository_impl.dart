import 'dart:convert';
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:storage_repository/constants/storage_repository_keys.dart';
import 'package:storage_repository/interfaces/storage_repository.dart';

/// A basic implementation of [StorageRepository].
///
/// This class provides a non-secure storage solution using Hive.
/// It should NOT be used for storing sensitive data, such as user tokens.
///
/// It allows storing, retrieving, and managing data efficiently in a local database.
class StorageRepositoryImpl implements StorageRepository {
  /// Hive storage box instance.
  late Box storage;

  /// Key used to identify the storage box.
  late final String key;

  /// Prefix used in log messages to identify storage-related logs.
  final String logPrefix;

  /// Constructor for `StorageRepositoryImpl`.
  ///
  /// - [key]: The storage box key, used for retrieving the correct Hive storage.
  /// - [logPrefix]: Prefix for log messages.
  StorageRepositoryImpl({
    this.key = StorageRepositoryKeys.defaultBoxKey,
    this.logPrefix = StorageRepositoryKeys.defaultStorageRepositoryLogPrefix,
  });

  /// Initializes the storage repository.
  ///
  /// This method should be called immediately after creating an instance of this class.
  /// It attempts to open the Hive box, and in case of failure, it resets the storage and retries.
  ///
  /// Returns an instance of [StorageRepository] once initialized.
  @override
  Future<StorageRepository> init() async {
    try {
      // Attempt to open the Hive storage box.
      storage = await Hive.openBox(key);
    } catch (e) {
      debugPrint(e.toString());

      // If an error occurs, delete the storage box and retry opening it.
      Hive.deleteBoxFromDisk(key);
      try {
        storage = await Hive.openBox(key);
      } catch (e) {
        debugPrint(e.toString());
      }
    }
    return this;
  }

  /// Saves a key-value pair to the device's storage.
  ///
  /// - [key]: The key to store the data under.
  /// - [value]: The data to be stored.
  ///
  /// Returns `true` if the operation was successful, otherwise `false`.
  @override
  Future<bool> set(dynamic key, dynamic value) async {
    try {
      // Convert value to JSON format before storing.
      final encodedValue = json.encode(value);
      await storage.put(key, encodedValue);
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
  dynamic get(dynamic key) {
    try {
      if (key == null) {
        return null;
      }

      // Retrieve the encoded value from storage.
      final encodedValue = storage.get(key);

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
    final entries = storage.keys.map(
      (key) {
        final encodedValue = storage.get(key);

        return MapEntry<String, dynamic>(
          key,
          (encodedValue == null || encodedValue is! String) ? encodedValue : json.decode(encodedValue),
        );
      },
    );

    return Map.fromEntries(entries);
  }

  /// Checks if a given key exists in the storage.
  ///
  /// - [key]: The key to check.
  ///
  /// Returns `true` if the key exists, otherwise `false`.
  @override
  Future<bool> contains(dynamic key) async {
    return key != null && storage.containsKey(key);
  }

  /// Deletes an item from storage using the given key.
  ///
  /// - [key]: The key of the item to delete.
  ///
  /// Returns `true` if deletion was successful, otherwise `false`.
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

  /// **Use with caution**
  ///
  /// Clears all data stored in the repository.
  ///
  /// Returns `true` if successful, otherwise `false`.
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

  /// Logs all stored data to the console.
  ///
  /// Useful for debugging purposes.
  @override
  Future log() async {
    developer.log(await asString());
  }

  /// Returns the stored data as a formatted string.
  ///
  /// This method helps in debugging by providing a structured view of the stored key-value pairs.
  @override
  Future<String> asString() async {
    final StringBuffer stringBuffer = StringBuffer();

    stringBuffer.write('\n----------------------------------------------------------------------------------------');
    stringBuffer.write('\n$logPrefix data:');
    stringBuffer.write('\n----------------------------------------------------------------------------------------');

    // Retrieve all stored key-value pairs and format them.
    (await getAll()).forEach((key, value) => stringBuffer.write('\n\n$key: $value'));

    stringBuffer.write('\n----------------------------------------------------------------------------------------');

    return stringBuffer.toString();
  }
}
