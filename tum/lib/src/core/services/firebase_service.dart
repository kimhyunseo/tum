import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

/// Firebase initialization placeholder.
///
/// This keeps local-only mode working until the project is connected.
/// Later: add firebase_options.dart via FlutterFire CLI and pass options.
class FirebaseService {
  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized) return;
    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp();
      }
      _initialized = true;
    } catch (e, st) {
      debugPrint('Firebase init skipped: $e');
      debugPrintStack(stackTrace: st);
    }
  }
}
