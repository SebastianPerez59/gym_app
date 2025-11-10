// Generated file (manual template). Replace the placeholder values with your Firebase project's values
// or run `flutterfire configure` to generate the real file.

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions no está configurado para esta plataforma.',
        );
    }
  }

  // === WEB ===
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'YOUR_WEB_API_KEY_HERE',
    appId: 'YOUR_WEB_APP_ID_HERE',
    messagingSenderId: 'YOUR_SENDER_ID_HERE',
    projectId: 'YOUR_PROJECT_ID_HERE',
    authDomain: 'YOUR_AUTH_DOMAIN_HERE',
    storageBucket: 'YOUR_STORAGE_BUCKET_HERE',
    measurementId: 'YOUR_MEASUREMENT_ID_HERE',
  );

  // === ANDROID ===
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'YOUR_ANDROID_API_KEY_HERE',
    appId: 'YOUR_ANDROID_APP_ID_HERE', // ej: 1:1234567890:android:abcdef123456
    messagingSenderId: 'YOUR_SENDER_ID_HERE',
    projectId: 'YOUR_PROJECT_ID_HERE',
    storageBucket: 'YOUR_STORAGE_BUCKET_HERE',
  );

  // === iOS ===
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'YOUR_IOS_API_KEY_HERE',
    appId: 'YOUR_IOS_APP_ID_HERE', // ej: 1:1234567890:ios:abcdef123456
    messagingSenderId: 'YOUR_SENDER_ID_HERE',
    projectId: 'YOUR_PROJECT_ID_HERE',
    storageBucket: 'YOUR_STORAGE_BUCKET_HERE',
    iosBundleId: 'com.example.yourbundleid',
  );

  // === macOS (opcional) ===
  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'YOUR_MACOS_API_KEY_HERE',
    appId: 'YOUR_MACOS_APP_ID_HERE',
    messagingSenderId: 'YOUR_SENDER_ID_HERE',
    projectId: 'YOUR_PROJECT_ID_HERE',
    storageBucket: 'YOUR_STORAGE_BUCKET_HERE',
    iosBundleId: 'com.example.yourbundleid',
  );
}
