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
      case TargetPlatform.windows:
        return windows;
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
    apiKey: 'AIzaSyAZ1wP21lrUeJyBfwSQGvFEpBzhyphsvHk',
    appId: '1:800472182695:web:bc7980d4649e85da765082',
    messagingSenderId: '800472182695',
    projectId: 'my-task-manager-63389',
    authDomain: 'my-task-manager-63389.firebaseapp.com',
    databaseURL: 'https://my-task-manager-63389-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'my-task-manager-63389.firebasestorage.app',
    measurementId: 'G-Y0YG8KHNGL',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyD62mSloFrjL1X4Qh0D6kN091dMN3YKM0o',
    appId: '1:800472182695:android:dcb82fa2b8cc5492765082',
    messagingSenderId: '800472182695',
    projectId: 'my-task-manager-63389',
    databaseURL: 'https://my-task-manager-63389-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'my-task-manager-63389.firebasestorage.app',
  );
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBbCsZz_FhJXE8_YzilxAIuP3-DWTyGTlQ',
    appId: '1:800472182695:ios:454cf72f2f9f5e44765082',
    messagingSenderId: '800472182695',
    projectId: 'my-task-manager-63389',
    databaseURL: 'https://my-task-manager-63389-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'my-task-manager-63389.firebasestorage.app',
    iosBundleId: 'com.example.myTaskManager',
  );
  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBbCsZz_FhJXE8_YzilxAIuP3-DWTyGTlQ',
    appId: '1:800472182695:ios:454cf72f2f9f5e44765082',
    messagingSenderId: '800472182695',
    projectId: 'my-task-manager-63389',
    databaseURL: 'https://my-task-manager-63389-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'my-task-manager-63389.firebasestorage.app',
    iosBundleId: 'com.example.myTaskManager',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyAZ1wP21lrUeJyBfwSQGvFEpBzhyphsvHk',
    appId: '1:800472182695:web:1084a35122c40a69765082',
    messagingSenderId: '800472182695',
    projectId: 'my-task-manager-63389',
    authDomain: 'my-task-manager-63389.firebaseapp.com',
    databaseURL: 'https://my-task-manager-63389-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'my-task-manager-63389.firebasestorage.app',
    measurementId: 'G-EPL1J2X74T',
  );
}
