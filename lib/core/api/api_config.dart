import 'package:flutter/foundation.dart';

class ApiConfig {
  ApiConfig._();

  static String get baseUrl {
    if (kIsWeb) return 'http://localhost/api-test/public';
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2/api-test/public';
    }
    return 'http://localhost/api-test/public';
  }
}
