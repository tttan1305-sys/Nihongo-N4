import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

/// Cấu hình Firebase của dự án (các giá trị này không phải bí mật).
/// Nền tảng nào còn null nghĩa là chưa nối Firebase: chạy chế độ không đăng nhập.
FirebaseOptions? get currentFirebaseOptions {
  if (kIsWeb) return _web;
  if (defaultTargetPlatform == TargetPlatform.android) return _android;
  return null;
}

const FirebaseOptions _web = FirebaseOptions(
  apiKey: 'AIzaSyD_of4FyRmh23sx0ZL6DUdOI-G55WOQrp4',
  appId: '1:482095874185:web:07b4ea59f95793371c8658',
  messagingSenderId: '482095874185',
  projectId: 'nihongo-n4-3be63',
  authDomain: 'nihongo-n4-3be63.firebaseapp.com',
  storageBucket: 'nihongo-n4-3be63.firebasestorage.app',
);

const FirebaseOptions _android = FirebaseOptions(
  apiKey: 'AIzaSyDPAB-E-GjdaUBBmwHwHd8T0S9gYxc35As',
  appId: '1:482095874185:android:8dc1144b06683a631c8658',
  messagingSenderId: '482095874185',
  projectId: 'nihongo-n4-3be63',
  storageBucket: 'nihongo-n4-3be63.firebasestorage.app',
);
