import 'package:hive_flutter/hive_flutter.dart';

///Abstract class for Storage repository to serve as
///an interface when using DI pattern
abstract class StorageRepository {
  ///Method declaration for initializing the storage
  Future<StorageRepository> init();

  ///Method declaration for saving the data under a given key
  Future<bool> set(String key, dynamic value);

  ///Method declaration to get the data by a given key
  dynamic get(dynamic key);

  ///Method declaration to get all data
  Future<Map<String, dynamic>> getAll();

  ///Method declaration for checking the existance of saved
  ///data under a given key
  Future<bool> contains(dynamic key);

  ///Method declaration for deleting the data saved under a given key
  Future<bool> delete(dynamic key);

  ///Method declaration for a method that should log all the data to the console
  Future log();

  ///Method declaration for a method that should return String representation of the data stored in the repository
  Future<String> asString();

  ///Method declaration for a method that should clear all the data
  Future clear();

  static Future<void> initFlutter() async => await Hive.initFlutter();
}
