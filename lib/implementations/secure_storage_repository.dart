import 'package:hive/hive.dart';
import 'package:storage_repository/implementations/storage_repository.dart';
import 'package:storage_repository/interfaces/i_storage_repository.dart';

///A secure implementation of IStorageRepository
///Use this implementation in case you want to persist some sensitive data like user tokens
class SecureStorageRepository extends StorageRepository
    implements IStorageRepository {
  late final String key;
  final List<int> encryptionKey;

  SecureStorageRepository({
    this.key = 'DEFAULT_SECURE_BOX',
    required this.encryptionKey,
  }) : assert(encryptionKey.length == 32,
            'encryptionKey must be 32 bytes (256 bit) long');

  ///Method that should be called as soon as possible
  @override
  Future<IStorageRepository> init() async {
    storage =
        await Hive.openBox(key, encryptionCipher: HiveAesCipher(encryptionKey));
    return this;
  }

  /// Generates strong 32 byte (256 bit) encryption key for secure storage
  static List<int> generateSecureKey() => Hive.generateSecureKey();
}
