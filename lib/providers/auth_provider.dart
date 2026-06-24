import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../services/cloud_sync_service.dart';

enum AuthStatus { initial, loading, signedIn, error }

class AuthProvider extends ChangeNotifier {
  AuthProvider(this._cloudSync);

  final CloudSyncService _cloudSync;
  final _auth = FirebaseAuth.instance;

  AuthStatus status = AuthStatus.initial;
  User? user;
  String? errorMessage;
  bool cloudSynced = false;

  bool get isSignedIn => user != null;
  String? get uid => user?.uid;
  String get displayLabel =>
      user?.displayName ?? user?.email ?? user?.uid.substring(0, 8) ?? '';

  Future<void> init() async {
    status = AuthStatus.loading;
    notifyListeners();

    try {
      user = _auth.currentUser;
      if (user == null) {
        final cred = await _auth.signInAnonymously();
        user = cred.user;
      }
      status = AuthStatus.signedIn;
      if (user != null) {
        await _cloudSync.pullSave(user!.uid);
        cloudSynced = true;
      }
    } catch (e) {
      status = AuthStatus.signedIn;
      errorMessage = e.toString();
      debugPrint('Auth init failed: $e');
    }
    notifyListeners();
  }

  Future<void> signInWithGoogle() async {
    status = AuthStatus.loading;
    notifyListeners();

    try {
      if (kIsWeb) {
        final provider = GoogleAuthProvider();
        if (_auth.currentUser?.isAnonymous ?? false) {
          final cred = await _auth.currentUser!.linkWithPopup(provider);
          user = cred.user;
        } else {
          final cred = await _auth.signInWithPopup(provider);
          user = cred.user;
        }
      } else {
        await GoogleSignIn.instance.initialize();
        final googleUser = await GoogleSignIn.instance.authenticate();
        final googleAuth = googleUser.authentication;
        final clientAuth = await googleUser.authorizationClient
            .authorizeScopes(['email', 'profile']);
        final credential = GoogleAuthProvider.credential(
          accessToken: clientAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        if (_auth.currentUser?.isAnonymous ?? false) {
          await _auth.currentUser!.linkWithCredential(credential);
          user = _auth.currentUser;
        } else {
          final cred = await _auth.signInWithCredential(credential);
          user = cred.user;
        }
      }

      status = AuthStatus.signedIn;
      await _cloudSync.pullSave(user!.uid);
      cloudSynced = true;
    } catch (e) {
      status = AuthStatus.error;
      errorMessage = e.toString();
      debugPrint('Google sign-in failed: $e');
    }
    notifyListeners();
  }

  Future<void> syncToCloud() async {
    if (user == null) return;
    await _cloudSync.pushSave(user!.uid);
    cloudSynced = true;
    notifyListeners();
  }

  Future<void> signOut() async {
    await _auth.signOut();
    user = null;
    cloudSynced = false;
    status = AuthStatus.initial;
    notifyListeners();
    await init();
  }
}
