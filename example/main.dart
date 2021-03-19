import 'package:storage_repository/storage_repository.dart';

Future main() async {
  final storageRepository = StorageRepository();
  //Or use like this to support dependency injection
  IStorageRepository concreteStorageRepository = StorageRepository();

  //Initialize like this(if you want to separate storage by some parameter)
  await storageRepository.init(prefix: 'current_user_id');

  storageRepository.set('key', 'dynamic value');
  concreteStorageRepository.set('key2', 1);

  final firstValue = storageRepository.get('key');
  final secondValue = concreteStorageRepository.get('key2');

  assert(firstValue == 'dynamic value');
  assert(secondValue == 1);

  assert(storageRepository.containsKey('key'));

  storageRepository.delete('key');

  assert(!storageRepository.containsKey('key'));

  storageRepository.log();

  storageRepository.clear();
}
