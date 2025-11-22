/// A utility class that defines constant keys for the storage repository.
/// These keys are used to manage different storage-related configurations
/// and ensure consistency across the application.
class StorageRepositoryKeys {
  /// The default prefix for storage keys.
  /// Used to namespace storage keys and prevent conflicts with other data.
  static const String defaultStorageKeyPrefix = 'STORAGE';
  static const String defaultSecureStorageKeyPrefix = 'SECURE_STORAGE';

  /// The key used to track migration completion status.
  /// Ensures that data migration from Hive to SharedPreferences/FlutterSecureStorage
  /// is performed only once.
  static const String migrationCheckKey = 'MIGRATION_CHECK_KEY';

  /// The key used for encryption within the storage repository.
  /// This is crucial for securely storing sensitive data.
  /// **This is deprecated and will be removed once all app data is migrated from Hive.**
  @Deprecated('Will be removed once all apps data is migrated from Hive')
  static const String encryptionKey = '__STORAGE_REPOSITORY:ENCRYPTION_KEY__';

  /// **This is deprecated and will be removed once all app data is migrated from Hive.**
  @Deprecated('Will be removed once all apps data is migrated from Hive')
  static const String migrationDefaultBoxKey =
      '__STORAGE_REPOSITORY:DEFAULT_BOX__';

  /// **This is deprecated and will be removed once all app data is migrated from Hive.**
  @Deprecated('Will be removed once all apps data is migrated from Hive')
  static const String migrationDefaultSecureBoxKey =
      '__STORAGE_REPOSITORY:DEFAULT_SECURE_BOX__';
}
