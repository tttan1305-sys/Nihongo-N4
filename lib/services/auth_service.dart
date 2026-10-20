import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

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
    final provider = GoogleAuthProvider()
      ..setCustomParameters({'prompt': 'select_account'});
    // Web mở cửa sổ đăng nhập Google; Android mở trình duyệt trong app.
    if (kIsWeb) {
      await _auth.signInWithPopup(provider);
    } else {
      await _auth.signInWithProvider(provider);
    }
  }

  @override
  Future<void> signOut() => _auth.signOut();
}
