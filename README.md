
# Storage repository

Abstraction for persisting and reading data to platform specific storage.
You can also find this package on pub as [storage_repository](https://pub.dev/packages/storage_repository) 

## Usage
```
Future  main() async {
    WidgetsFlutterBinding.ensureInitialized();

    IStorageRepository  storageRepository  =  StorageRepository();
    //init must be called, preferably right after the instantiation
    await  storageRepository.init();

    await  storageRepository.set('some_string_key', 'Some string');
    await  storageRepository.set('some_int_key', 0);
    ///dynamic keys are also possible
    await  storageRepository.set(1, 1);

    ///result: Some string (dynamic)
    print(storageRepository.get('some_string_key'));

    ///result: 0 (dynamic)
    print(storageRepository.get('some_int_key'));

    ///result: 1 (dynamic)
    print(storageRepository.get(1));

    ///result: 1 (int?)
    print(storageRepository.get<int>(1));

    storageRepository.delete('some_string_key');

    storageRepository.print();

    storageRepository.clear();
}

```