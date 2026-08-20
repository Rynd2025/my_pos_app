import 'package:flutter/services.dart';

class ScanFeedbackService {
  static const MethodChannel _channel = MethodChannel('com.example.billing_app/feedback');

  static Future<void> beep() async {
    try {
      await _channel.invokeMethod('beep');
    } on PlatformException catch (e) {
      // Ignore errors in production
    }
  }
}
