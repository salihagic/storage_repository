import 'dart:convert';
import 'package:flutter/foundation.dart';

import 'key_encoder.dart';

class JsonKeyEncoder implements KeyEncoder {
  const JsonKeyEncoder();

  String encode(String key) {
    try {
      return json.encode(key);
    } catch (e) {
      debugPrint('StorageRepository Exception: Failed to json encode key: $key with type ${key.runtimeType}. All keys must be json serializable.');
      throw e;
    }
  }

  String decode(String key) {
    try {
      return json.decode(key);
    } catch (e) {
      debugPrint('StorageRepository Exception: Please make sure you are using a valid key encoder All keys must be json serialized.');
      throw e;
    }
  }
}
