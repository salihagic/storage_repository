# Storage Repository

A Flutter package that provides a clean abstraction layer for persistent key-value storage with both secure and non-secure implementations.

[![pub package](https://img.shields.io/pub/v/storage_repository.svg)](https://pub.dev/packages/storage_repository)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)

## Features

- **Simple API** - Easy-to-use interface for storing and retrieving data
- **Secure Storage** - Platform-level encryption for sensitive data (iOS Keychain, Android Keystore)
- **Non-Secure Storage** - Fast storage using SharedPreferences for general app data
- **Key Namespacing** - Isolate data with custom key prefixes
- **JSON Serialization** - Automatically handles complex data types
- **Cross-Platform** - Works on iOS, Android, Web, Windows, macOS, and Linux

## Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  storage_repository: ^2.0.2
```

Then run:

```bash
flutter pub get
```

## Quick Start

### Basic Setup

```dart
import 'package:storage_repository/storage_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Create and initialize storage
  final storage = StorageRepositoryImpl();
  await storage.init();

  // Store data
  await storage.set('username', 'john_doe');
  await storage.set('settings', {'theme': 'dark', 'notifications': true});

  // Retrieve data
  final username = await storage.get('username'); // 'john_doe'
  final settings = await storage.get('settings'); // {'theme': 'dark', ...}

  runApp(MyApp(storage: storage));
}
```

### Secure Storage (for sensitive data)

```dart
// Use SecureStorageRepositoryImpl for tokens, passwords, API keys, etc.
final secureStorage = SecureStorageRepositoryImpl();
await secureStorage.init();

// Store sensitive data with platform-level encryption
await secureStorage.set('auth_token', 'eyJhbGciOiJIUzI1NiIs...');
await secureStorage.set('api_key', 'sk-1234567890');

// Retrieve encrypted data
final token = await secureStorage.get('auth_token');
```

## API Reference

### StorageRepository Interface

Both `StorageRepositoryImpl` and `SecureStorageRepositoryImpl` implement the same interface:

| Method | Description | Returns |
|--------|-------------|---------|
| `init()` | Initialize the storage | `Future<StorageRepository>` |
| `set(key, value)` | Store a value | `Future<bool>` |
| `get(key)` | Retrieve a value | `Future<dynamic>` |
| `getAll()` | Get all stored key-value pairs | `Future<Map<String, dynamic>>` |
| `contains(key)` | Check if a key exists | `Future<bool>` |
| `delete(key)` | Remove a key-value pair | `Future<bool>` |
| `clear()` | Remove all data | `Future<bool>` |
| `log()` | Print all data to console | `Future<void>` |
| `asString()` | Get string representation of all data | `Future<String>` |

## Usage Examples

### Storing Different Data Types

```dart
final storage = StorageRepositoryImpl();
await storage.init();

// Strings
await storage.set('name', 'Alice');

// Numbers
await storage.set('age', 25);
await storage.set('score', 99.5);

// Booleans
await storage.set('is_premium', true);

// Lists
await storage.set('tags', ['flutter', 'dart', 'mobile']);

// Maps/Objects
await storage.set('user', {
  'id': 1,
  'name': 'Alice',
  'email': 'alice@example.com',
});
```

### Custom Key Prefixes

Use key prefixes to namespace your storage and avoid key collisions:

```dart
// User-related data
final userStorage = StorageRepositoryImpl(keyPrefix: 'USER');
await userStorage.init();
await userStorage.set('profile', {...});

// App settings
final settingsStorage = StorageRepositoryImpl(keyPrefix: 'SETTINGS');
await settingsStorage.init();
await settingsStorage.set('theme', 'dark');
```

### Dependency Injection Pattern

```dart
class AuthService {
  final StorageRepository _secureStorage;

  AuthService(this._secureStorage);

  Future<void> saveToken(String token) async {
    await _secureStorage.set('auth_token', token);
  }

  Future<String?> getToken() async {
    return await _secureStorage.get('auth_token');
  }

  Future<void> logout() async {
    await _secureStorage.delete('auth_token');
  }
}

// Usage
final secureStorage = SecureStorageRepositoryImpl();
await secureStorage.init();
final authService = AuthService(secureStorage);
```

### Checking and Managing Data

```dart
// Check if a key exists before accessing
if (await storage.contains('user_preferences')) {
  final prefs = await storage.get('user_preferences');
  // Use preferences...
}

// Get all stored data
final allData = await storage.getAll();
print('Stored keys: ${allData.keys}');

// Debug: log all data to console
await storage.log();

// Clear all data (use with caution!)
await storage.clear();
```

## When to Use Each Implementation

| Use Case | Implementation |
|----------|---------------|
| User preferences | `StorageRepositoryImpl` |
| UI state / settings | `StorageRepositoryImpl` |
| Cached data | `StorageRepositoryImpl` |
| Authentication tokens | `SecureStorageRepositoryImpl` |
| API keys | `SecureStorageRepositoryImpl` |
| Passwords / credentials | `SecureStorageRepositoryImpl` |
| Personal identifiable information | `SecureStorageRepositoryImpl` |

## Platform Support

| Platform | Non-Secure | Secure |
|----------|------------|--------|
| Android | SharedPreferences | EncryptedSharedPreferences + Keystore |
| iOS | NSUserDefaults | Keychain |
| Web | LocalStorage | LocalStorage (limited security) |
| Windows | File-based | File-based with encryption |
| macOS | NSUserDefaults | Keychain |
| Linux | File-based | File-based with encryption |

## License

MIT License - see [LICENSE](LICENSE) for details.

## Contributing

Contributions are welcome! Please feel free to submit issues and pull requests on [GitHub](https://github.com/salihagic/storage_repository).
