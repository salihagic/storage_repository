import 'package:flutter/material.dart';
import 'package:storage_repository/storage_repository.dart';

const key = 'COUNTER_VALUE';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //This must be called once per application lifetime
  await StorageRepository.initFlutter();

  final storageRepository = StorageRepositoryImpl();
  //or
  //final storageRepository = SecureStorageRepositoryImpl();
  await storageRepository.init();

  runApp(MaterialApp(title: 'Storage repository example', theme: ThemeData(primarySwatch: Colors.blue), home: Home(storageRepository: storageRepository)));
}

class Home extends StatefulWidget {
  final StorageRepository storageRepository;

  const Home({super.key, required this.storageRepository});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _currentValue = 0;

  @override
  void initState() {
    super.initState();
    widget.storageRepository.clear();
  }

  Future<int> getCurrentValue() async {
    return await widget.storageRepository.get(key) ?? 0;
  }

  Future setNewValue(int value) async {
    await widget.storageRepository.set(key, value);
  }

  Future onPressed() async {
    var currentValue = await getCurrentValue();
    await setNewValue(currentValue + 1);
    _currentValue = await getCurrentValue();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: Text('Storage repository counter')), body: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [Text('You have clicked increment button this many times:'), Text(_currentValue.toString(), style: TextStyle(fontSize: 26.0))])), floatingActionButton: FloatingActionButton(onPressed: onPressed, child: Icon(Icons.add)));
  }
}
