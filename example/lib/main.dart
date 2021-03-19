import 'package:flutter/material.dart';
import 'package:storage_repository/storage_repository.dart';

void main() {
  // final storageRepository = StorageRepository();
  // //Or use like this to support dependency injection
  // IStorageRepository concreteStorageRepository = StorageRepository();

  // //Initialize like this(if you want to separate storage by some parameter)
  // await storageRepository.init(prefix: 'current_user_id');

  // storageRepository.set('key', 'dynamic value');
  // concreteStorageRepository.set('key2', 1);

  // final firstValue = storageRepository.get('key');
  // final secondValue = concreteStorageRepository.get('key2');

  // assert(firstValue == 'dynamic value');
  // assert(secondValue == 1);

  // assert(storageRepository.containsKey('key'));

  // storageRepository.delete('key');

  // assert(!storageRepository.containsKey('key'));

  // storageRepository.log();

  // storageRepository.clear();

  runApp(App());
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Column(
          children: [
            Expanded(
              child: Text(''),
            ),
          ],
        ),
      ),
    );
  }
}
