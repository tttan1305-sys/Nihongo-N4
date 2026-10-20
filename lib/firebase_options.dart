import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

/// Cấu hình Firebase của dự án (các giá trị này không phải bí mật).
/// Còn null nghĩa là chưa nối Firebase: app chạy chế độ không đăng nhập.
FirebaseOptions? get currentFirebaseOptions {
  if (kIsWeb) return _web;
  if (defaultTargetPlatform == TargetPlatform.android) return _android;
  return null;
}

const FirebaseOptions? _web = null;

const FirebaseOptions? _android = null;
