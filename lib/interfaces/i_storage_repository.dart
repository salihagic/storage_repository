///Abstract class for Storage repository to serve as
///an interface when using DI pattern
abstract class IStorageRepository {
  ///Method declaration for initializing the storage
  Future<IStorageRepository> init();

  ///Method declaration for saving the data under a given key
  Future<bool> set<T>(dynamic key, T value);

  ///Method declaration to get the data by a given key
  Future<T?> get<T>(dynamic key);

  ///Method declaration for checking the existance of saved
  ///data under a given key
  Future<bool> contains(dynamic key);

  ///Method declaration for deleting the data saved under a given key
  Future<bool> delete(dynamic key);

  ///Method declaration for a method that should log all the data to the console
  Future print();

  ///Method declaration for a method that should clear all the data
  Future clear();
}
