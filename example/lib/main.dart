import 'package:flutter/material.dart';
import 'package:storage_repository/storage_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize both storage types
  final storage = StorageRepositoryImpl();
  final secureStorage = SecureStorageRepositoryImpl();

  await Future.wait([storage.init(), secureStorage.init()]);

  runApp(
    MaterialApp(
      title: 'Storage Repository Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: StorageDemo(storage: storage, secureStorage: secureStorage),
    ),
  );
}

class StorageDemo extends StatefulWidget {
  final StorageRepository storage;
  final StorageRepository secureStorage;

  const StorageDemo({
    super.key,
    required this.storage,
    required this.secureStorage,
  });

  @override
  State<StorageDemo> createState() => _StorageDemoState();
}

class _StorageDemoState extends State<StorageDemo> {
  final _keyController = TextEditingController();
  final _valueController = TextEditingController();
  bool _useSecureStorage = false;
  String _output = '';

  StorageRepository get _activeStorage =>
      _useSecureStorage ? widget.secureStorage : widget.storage;

  String get _storageType => _useSecureStorage ? 'Secure' : 'Standard';

  Future<void> _saveValue() async {
    final key = _keyController.text.trim();
    final value = _valueController.text.trim();

    if (key.isEmpty) {
      _showMessage('Please enter a key');
      return;
    }

    final success = await _activeStorage.set(key, value);
    _showMessage(
      success ? 'Saved "$key" to $_storageType storage' : 'Failed to save',
    );
  }

  Future<void> _getValue() async {
    final key = _keyController.text.trim();

    if (key.isEmpty) {
      _showMessage('Please enter a key');
      return;
    }

    final value = await _activeStorage.get(key);
    setState(() {
      _output = value != null ? 'Value: $value' : 'Key "$key" not found';
    });
  }

  Future<void> _deleteValue() async {
    final key = _keyController.text.trim();

    if (key.isEmpty) {
      _showMessage('Please enter a key');
      return;
    }

    final success = await _activeStorage.delete(key);
    _showMessage(success ? 'Deleted "$key"' : 'Failed to delete');
  }

  Future<void> _showAllData() async {
    final data = await _activeStorage.getAll();
    setState(() {
      if (data.isEmpty) {
        _output = '$_storageType storage is empty';
      } else {
        _output =
            '$_storageType storage contents:\n${data.entries.map((e) => '  ${e.key}: ${e.value}').join('\n')}';
      }
    });
  }

  Future<void> _clearStorage() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Clear Storage'),
            content: Text('Clear all data from $_storageType storage?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Clear'),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      await _activeStorage.clear();
      _showMessage('$_storageType storage cleared');
      setState(() => _output = '');
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }

  @override
  void dispose() {
    _keyController.dispose();
    _valueController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Storage Repository'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Storage type selector
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Icon(Icons.storage),
                    const SizedBox(width: 12),
                    const Text('Storage Type:'),
                    const Spacer(),
                    SegmentedButton<bool>(
                      segments: const [
                        ButtonSegment(value: false, label: Text('Standard')),
                        ButtonSegment(value: true, label: Text('Secure')),
                      ],
                      selected: {_useSecureStorage},
                      onSelectionChanged: (selection) {
                        setState(() {
                          _useSecureStorage = selection.first;
                          _output = '';
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Input fields
            TextField(
              controller: _keyController,
              decoration: const InputDecoration(
                labelText: 'Key',
                border: OutlineInputBorder(),
                hintText: 'Enter storage key',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _valueController,
              decoration: const InputDecoration(
                labelText: 'Value',
                border: OutlineInputBorder(),
                hintText: 'Enter value to store',
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),

            // Action buttons
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton.icon(
                  onPressed: _saveValue,
                  icon: const Icon(Icons.save),
                  label: const Text('Save'),
                ),
                FilledButton.tonalIcon(
                  onPressed: _getValue,
                  icon: const Icon(Icons.search),
                  label: const Text('Get'),
                ),
                OutlinedButton.icon(
                  onPressed: _deleteValue,
                  icon: const Icon(Icons.delete),
                  label: const Text('Delete'),
                ),
                OutlinedButton.icon(
                  onPressed: _showAllData,
                  icon: const Icon(Icons.list),
                  label: const Text('Show All'),
                ),
                TextButton.icon(
                  onPressed: _clearStorage,
                  icon: const Icon(Icons.clear_all),
                  label: const Text('Clear'),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Output display
            if (_output.isNotEmpty)
              Card(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            _useSecureStorage ? Icons.lock : Icons.folder,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Output',
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                        ],
                      ),
                      const Divider(),
                      SelectableText(
                        _output,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 24),

            // Info card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'About Storage Types',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Standard Storage (StorageRepositoryImpl)\n'
                      'Uses SharedPreferences. Good for preferences, settings, and cached data.\n\n'
                      'Secure Storage (SecureStorageRepositoryImpl)\n'
                      'Uses platform encryption (iOS Keychain, Android Keystore). '
                      'Use for tokens, passwords, and sensitive data.',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
