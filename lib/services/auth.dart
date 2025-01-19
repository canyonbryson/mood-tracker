import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
// If you need secure storage for tokens or IDs (advanced case)

class AuthService {
  final userStream = FirebaseAuth.instance.authStateChanges();
  User? get user => FirebaseAuth.instance.currentUser;

  Future<void> anonLogin() async {
    try {
      if (FirebaseAuth.instance.currentUser?.isAnonymous == true) {
        // Already anonymous and signed in, no action needed
        return;
      }

      await FirebaseAuth.instance.signInAnonymously();

    } on FirebaseAuthException catch (e) {
      print('Anon login error: $e');
      rethrow;
    }
  }

  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
  }

  Future<void> googleLogin() async {
    try {
      final googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return; // user canceled

      final googleAuth = await googleUser.authentication;
      final authCredential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await FirebaseAuth.instance.signInWithCredential(authCredential);
    } on FirebaseAuthException catch (e) {
      // handle error
      print('Google login error: $e');
      rethrow;
    }
  }

  /// APPLE LOGIN
  Future<void> appleLogin() async {
    try {
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );
      final oauthCredential = AppleAuthProvider.credential(
        appleCredential.authorizationCode,
      );
      // final oauthCredential = OAuthProvider("apple.com").credential(
      //   idToken: appleCredential.identityToken,
      //   accessToken: appleCredential.authorizationCode,
      // );

      await FirebaseAuth.instance.signInWithCredential(oauthCredential);

    } on SignInWithAppleAuthorizationException catch (e) {
      // Handle Apple sign-in specific exceptions
      print('Apple sign in error: $e');
    } on FirebaseAuthException catch (e) {
      // Handle Firebase Auth exceptions
      print('Firebase Auth error: $e');
      rethrow;
    } catch (e) {
      print('Unknown apple login error: $e');
      rethrow;
    }
  }
}
