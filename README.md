# Storage repository

Abstraction for persisting and reading data to platform specific storage.

## Usage
```
Future  main() async {
    final storageRepository = StorageRepository();
    //Or use like this to support dependency injection
    IStorageRepository concreteStorageRepository = StorageRepository();

    //init must be called
    await storageRepository.init();

    //or like this(if you want to separate storage by some parameter)
    await storageRepository.init(prefix: 'current_user_id');

    storageRepository.set('key', 'dynamic value');

    final value = storageRepository.get('key');

    bool containsKey = storageRepository.containsKey('key');

    storageRepository.delete('key');

    storageRepository.log();

    storageRepository.clear();
}
```
