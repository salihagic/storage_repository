/// A utility class that defines constant keys for the storage repository.
/// These keys are used to manage different storage-related configurations
/// and ensure consistency across the application.
class StorageRepositoryKeys {
  /// The key used for encryption within the storage repository.
  /// This is crucial for securely storing sensitive data.
  static const String encryptionKey = '__STORAGE_REPOSITORY:ENCRYPTION_KEY__';

  /// The default prefix for storage keys.
  /// Used to namespace storage keys and prevent conflicts with other data.
  static const String defaultKeyPrefix =
      'STORAGE_REPOSITORY:DEFAULT_KEY_PREFIX';

  /// The key used to track migration completion status.
  /// Ensures that data migration from Hive to SharedPreferences/FlutterSecureStorage
  /// is performed only once.
  static const String migrationCheckKey =
      'STORAGE_REPOSITORY:MIGRATION_CHECK_KEY';

  /// The default log prefix for the storage repository.
  /// Useful for logging and debugging storage-related operations.
  static const String defaultStorageRepositoryLogPrefix =
      '__STORAGE_REPOSITORY:LOG__';

  /// The default log prefix for the secure storage repository implementation.
  /// Helps differentiate secure storage logs from general storage logs.
  static const String defaultSecureStorageRepositoryImplLogPrefix =
      '__SECURE_STORAGE_REPOSITORY:LOG__';
}
