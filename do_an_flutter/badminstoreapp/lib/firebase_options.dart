// File được tạo tự động từ google-services.json
// Project: badmin-store-app

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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for ios - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDkd80GsSISxomiBvdfL4aAyO3HausPpOA',
    appId: '1:964437620250:web:1234567890abcdef', // Temporary placeholder for web
    messagingSenderId: '964437620250',
    projectId: 'badmin-store-app',
    authDomain: 'badmin-store-app.firebaseapp.com',
    storageBucket: 'badmin-store-app.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDkd80GsSISxomiBvdfL4aAyO3HausPpOA',
    appId: '1:964437620250:android:31a9365343bdab8fbe03a3',
    messagingSenderId: '964437620250',
    projectId: 'badmin-store-app',
    storageBucket: 'badmin-store-app.firebasestorage.app',
  );
}
