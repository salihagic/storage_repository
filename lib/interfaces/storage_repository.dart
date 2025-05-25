import 'package:hive_flutter/hive_flutter.dart';

/// Abstract class for the storage repository, serving as an interface
/// for dependency injection (DI) patterns.
///
/// This interface defines methods for interacting with a key-value storage system.
/// Implementations should provide secure or non-secure data persistence options.
abstract class StorageRepository {
  /// Initializes the storage repository.
  ///
  /// This method should be called before using the storage to ensure it is properly set up.
  /// Returns an instance of [StorageRepository] once initialization is complete.
  Future<StorageRepository> init();

  /// Saves a value under the specified key.
  ///
  /// - [key]: The key to store the value under.
  /// - [value]: The data to be stored.
  ///
  /// Returns `true` if the operation was successful, otherwise `false`.
  Future<bool> set(String key, dynamic value);

  /// Retrieves the value stored under the specified key.
  ///
  /// - [key]: The key to look up.
  ///
  /// Returns the stored value if found, otherwise `null`.
  dynamic get(dynamic key);

  /// Retrieves all stored key-value pairs.
  ///
  /// Returns a `Map<String, dynamic>` containing all stored data.
  Future<Map<String, dynamic>> getAll();

  /// Checks whether a given key exists in the storage.
  ///
  /// - [key]: The key to check.
  ///
  /// Returns `true` if the key exists, otherwise `false`.
  Future<bool> contains(dynamic key);

  /// Deletes a value stored under the specified key.
  ///
  /// - [key]: The key of the item to delete.
  ///
  /// Returns `true` if the deletion was successful, otherwise `false`.
  Future<bool> delete(dynamic key);

  /// Logs all stored data to the console.
  ///
  /// Useful for debugging and inspecting stored values.
  Future log();

  /// Returns a string representation of all stored data.
  ///
  /// This method is primarily used for debugging to get a structured view of the stored data.
  Future<String> asString();

  /// Clears all stored data in the repository.
  ///
  /// **Use with caution**, as this method will permanently delete all stored data.
  Future clear();

  /// Initializes Hive for Flutter.
  ///
  /// This method should be called early in the app lifecycle to set up Hive storage.
  static Future<void> initFlutter() async => await Hive.initFlutter();
}
