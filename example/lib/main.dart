import 'package:flutter/material.dart';
import 'package:storage_repository/storage_repository.dart';

const KEY = 'COUNTER_VALUE';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final storageRepository = StorageRepository();
  await storageRepository.init();

  runApp(
    MaterialApp(
      title: 'Storage repository example',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: Home(storageRepository: storageRepository),
    ),
  );
}

class Home extends StatefulWidget {
  final IStorageRepository storageRepository;

  Home({required this.storageRepository});

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  void initState() {
    super.initState();
    widget.storageRepository.clear();
  }

  int getCurrentValue() {
    return widget.storageRepository.get<int>(KEY) ?? 0;
  }

  Future setNewValue(int value) async {
    await widget.storageRepository.set(KEY, value);
  }

  Future onPressed() async {
    final currentValue = getCurrentValue();
    await setNewValue(currentValue + 1);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Storage repository counter'),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('You have clicked increment button this many times:'),
            Text(
              getCurrentValue().toString(),
              style: TextStyle(fontSize: 26.0),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: onPressed,
        child: Icon(Icons.add),
      ),
    );
  }
}
