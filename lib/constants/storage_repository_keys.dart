/// A utility class that defines constant keys for the storage repository.
/// These keys are used to manage different storage-related configurations
/// and ensure consistency across the application.
class StorageRepositoryKeys {
  /// The key used for encryption within the storage repository.
  /// This is crucial for securely storing sensitive data.
  static const String encryptionKey = '__STORAGE_REPOSITORY:ENCRYPTION_KEY__';

  /// The default key for accessing the general storage box.
  /// Used to store non-sensitive, application-wide data.
  static const String defaultBoxKey = '__STORAGE_REPOSITORY:DEFAULT_BOX__';

  /// The default log prefix for the storage repository.
  /// Useful for logging and debugging storage-related operations.
  static const String defaultStorageRepositoryLogPrefix = 'Storage repository';

  /// The default log prefix for the secure storage repository implementation.
  /// Helps differentiate secure storage logs from general storage logs.
  static const String defaultSecureStorageRepositoryImplLogPrefix = 'Secure storage repository';

  /// The default key for accessing the secure storage box.
  /// Used to store sensitive data securely, typically with encryption.
  static const String defaultSecureBoxKey = '__STORAGE_REPOSITORY:DEFAULT_SECURE_BOX__';
}
