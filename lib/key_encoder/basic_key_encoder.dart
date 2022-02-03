import 'key_encoder.dart';

class BasicKeyEncoder implements KeyEncoder {
  const BasicKeyEncoder();

  String encode(String key) => key;
  String decode(String key) => key;
}
