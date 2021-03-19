import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

abstract class IStorageRepository {
  Future init({String prefix = ''});
  Future set<E>(dynamic key, E value);
  E? get<E>(dynamic key);
  bool containsKey(dynamic key);
  Future delete(dynamic key);
  void log();
  Future clear({String prefix = ''});
}

class StorageRepository implements IStorageRepository {
  late Box _box;

  Future init({String prefix = ''}) async {
    await Hive.initFlutter();
    _box = await Hive.openBox('${prefix}storageBox');
  }

  @override
  Future set<E>(dynamic key, E value) {
    return _box.put(key, value);
  }

  @override
  E? get<E>(dynamic key) {
    return _box.get(key);
  }

  @override
  bool containsKey(dynamic key) {
    return _box.containsKey(key);
  }

  @override
  Future delete(dynamic key) {
    return _box.delete(key);
  }

  void log() {
    print('\n----------------------------------------------------------------------------------------');
    print('Storage repository data:');
    print('----------------------------------------------------------------------------------------');
    _box.keys.forEach((key) {
      print('\n\n${key.toString()}: ${_box.get(key)}');
    });
    print('\n----------------------------------------------------------------------------------------\n');
  }

  Future clear({String prefix = ''}) async {
    await Hive.initFlutter();
    await Hive.deleteBoxFromDisk('${prefix}storageBox');
  }
}
