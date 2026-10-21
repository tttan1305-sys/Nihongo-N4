import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../firebase_options.dart';

/// Người dùng đã đăng nhập.
class AppUser {
  final String uid;
  final String? name;
  final String? email;
  final String? photoUrl;

  const AppUser({required this.uid, this.name, this.email, this.photoUrl});
}

/// Đăng nhập bằng tài khoản Google (Gmail).
abstract class AuthService extends ChangeNotifier {
  /// false khi app chưa nối Firebase: ẩn đăng nhập, học không cần tài khoản.
  bool get available;

  AppUser? get user;

  Future<void> signInWithGoogle();

  Future<void> signOut();
}

/// Dùng khi chưa cấu hình Firebase.
class NoAuthService extends AuthService {
  @override
  bool get available => false;

  @override
  AppUser? get user => null;

  @override
  Future<void> signInWithGoogle() async =>
      throw StateError('Ứng dụng chưa nối Firebase');

  @override
  Future<void> signOut() async {}
}

class FirebaseAuthService extends AuthService {
  final FirebaseAuth _auth;
  AppUser? _user;

  FirebaseAuthService(this._auth) {
    _user = _toUser(_auth.currentUser);
    _auth.authStateChanges().listen((u) {
      _user = _toUser(u);
      notifyListeners();
    });
  }

  static AppUser? _toUser(User? u) => u == null
      ? null
      : AppUser(
          uid: u.uid,
          name: u.displayName,
          email: u.email,
          photoUrl: u.photoURL,
        );

  @override
  bool get available => true;

  @override
  AppUser? get user => _user;

  @override
  Future<void> signInWithGoogle() async {
    if (kIsWeb) {
      // Web mở cửa sổ đăng nhập Google.
      final provider = GoogleAuthProvider()
        ..setCustomParameters({'prompt': 'select_account'});
      await _auth.signInWithPopup(provider);
      return;
    }
    // Android chọn tài khoản Google ngay trong app (không qua trình duyệt,
    // vì Chrome báo "missing initial state"), rồi đưa ID token cho Firebase.
    final google = await _google();
    final account = await google.authenticate();
    final idToken = account.authentication.idToken;
    if (idToken == null) throw StateError('Google không trả về ID token');
    await _auth.signInWithCredential(
      GoogleAuthProvider.credential(idToken: idToken),
    );
  }

  Future<GoogleSignIn>? _googleInit;

  Future<GoogleSignIn> _google() => _googleInit ??= () async {
    await GoogleSignIn.instance.initialize(
      serverClientId: googleServerClientId,
    );
    return GoogleSignIn.instance;
  }();

  @override
  Future<void> signOut() async {
    // Đăng xuất cả Google để lần sau được chọn lại tài khoản.
    if (!kIsWeb && _googleInit != null) {
      try {
        await (await _google()).signOut();
      } catch (e) {
        debugPrint('Đăng xuất Google lỗi: $e');
      }
    }
    await _auth.signOut();
  }
}
