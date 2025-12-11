import 'package:firebase_auth/firebase_auth.dart';
import 'api_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ApiService _apiService = ApiService();

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Register with email and password
  Future<Map<String, dynamic>> registerWithEmailPassword({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      print('🔥 Starting registration...');
      print('📧 Email: $email');
      
      // 1. Create user in Firebase first (client-side)
      print('📝 Creating user in Firebase...');
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      print('✅ Firebase user created: ${userCredential.user?.uid}');

      // 2. Update display name
      await userCredential.user?.updateDisplayName(displayName);
      await userCredential.user?.reload();
      
      // Get fresh user data to confirm display name
      User? updatedUser = _auth.currentUser;
      print('✅ Display name updated: ${updatedUser?.displayName}');

      // 3. Get ID token
      String? idToken = await updatedUser?.getIdToken();
      if (idToken == null) {
        throw Exception('Failed to get Firebase token');
      }
      print('✅ Got Firebase token');

      // 4. Sync to backend with token
      print('🔄 Syncing to backend...');
      final backendResponse = await _apiService.login(idToken);
      print('✅ Backend sync successful');

      // 5. Sign out after successful registration
      // User needs to login separately with their credentials
      print('🚪 Signing out after registration...');
      await _auth.signOut();

      return {
        'success': true,
        'message': 'Registration successful! Please login with your credentials.',
        'user': updatedUser,
        'backend_response': backendResponse,
      };
    } on FirebaseAuthException catch (e) {
      print('❌ Firebase error: ${e.code} - ${e.message}');
      String message = 'Registration failed';
      if (e.code == 'weak-password') {
        message = 'The password provided is too weak.';
      } else if (e.code == 'email-already-in-use') {
        message = 'An account already exists for that email.';
      } else if (e.code == 'invalid-email') {
        message = 'The email address is not valid.';
      } else {
        message = 'Registration failed: ${e.message}';
      }
      throw Exception(message);
    } catch (e) {
      print('❌ Registration error: $e');
      throw Exception('Registration failed: $e');
    }
  }

  // Sign in with email and password
  Future<Map<String, dynamic>> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    try {
      print('🔐 Starting login...');
      print('📧 Email: $email');
      
      // 1. Sign in with Firebase
      print('🔥 Signing in to Firebase...');
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      print('✅ Firebase login successful: ${userCredential.user?.uid}');

      // 2. Get ID token
      String? idToken = await userCredential.user?.getIdToken();
      if (idToken == null) {
        throw Exception('Failed to get ID token');
      }
      print('✅ Got Firebase token');

      // 3. Login to backend
      print('🔄 Syncing with backend...');
      final backendResponse = await _apiService.login(idToken);
      print('✅ Backend sync successful');

      // 4. Save token
      await _apiService.saveToken(idToken);

      return {
        'success': true,
        'message': 'Login successful',
        'user': userCredential.user,
        'backend_response': backendResponse,
      };
    } on FirebaseAuthException catch (e) {
      print('❌ Firebase auth error: ${e.code} - ${e.message}');
      String message = 'Login failed';
      if (e.code == 'user-not-found') {
        message = 'No user found for that email.';
      } else if (e.code == 'wrong-password') {
        message = 'Wrong password provided.';
      } else if (e.code == 'invalid-email') {
        message = 'The email address is not valid.';
      } else if (e.code == 'user-disabled') {
        message = 'This user has been disabled.';
      } else if (e.code == 'invalid-credential') {
        message = 'Invalid email or password.';
      } else {
        message = 'Login failed: ${e.message}';
      }
      throw Exception(message);
    } catch (e) {
      print('❌ Login error: $e');
      throw Exception('Login failed: $e');
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      // 1. Logout from backend first
      await _apiService.logout();

      // 2. Sign out from Firebase
      await _auth.signOut();
    } catch (e) {
      print('❌ Logout error: $e');
      // Even if backend logout fails, sign out from Firebase
      await _auth.signOut();
      throw Exception('Logout failed: $e');
    }
  }

  // Refresh token (should be called periodically, e.g., every 50 minutes)
  Future<String?> refreshToken() async {
    try {
      User? user = _auth.currentUser;
      if (user == null) return null;

      // Force refresh token
      String? newToken = await user.getIdToken(true);
      if (newToken != null) {
        await _apiService.saveToken(newToken);
      }
      return newToken;
    } catch (e) {
      throw Exception('Failed to refresh token: $e');
    }
  }

  // Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      await _apiService.forgotPassword(email);
    } on FirebaseAuthException catch (e) {
      String message = 'Failed to send reset email';
      if (e.code == 'user-not-found') {
        message = 'No user found for that email.';
      } else if (e.code == 'invalid-email') {
        message = 'The email address is not valid.';
      }
      throw Exception(message);
    } catch (e) {
      throw Exception('Failed to send reset email: $e');
    }
  }

  // Update password
  Future<void> updatePassword(String newPassword) async {
    try {
      User? user = _auth.currentUser;
      if (user == null) throw Exception('No user logged in');

      await user.updatePassword(newPassword);
      await _apiService.updatePassword(
        newPassword: newPassword,
        newPasswordConfirmation: newPassword,
      );
    } on FirebaseAuthException catch (e) {
      String message = 'Failed to update password';
      if (e.code == 'weak-password') {
        message = 'The password provided is too weak.';
      } else if (e.code == 'requires-recent-login') {
        message = 'Please re-login and try again.';
      }
      throw Exception(message);
    } catch (e) {
      throw Exception('Failed to update password: $e');
    }
  }

  // Delete account
  Future<void> deleteAccount() async {
    try {
      // 1. Delete from backend
      await _apiService.deleteAccount();

      // 2. Delete from Firebase
      User? user = _auth.currentUser;
      if (user != null) {
        await user.delete();
      }
    } on FirebaseAuthException catch (e) {
      String message = 'Failed to delete account';
      if (e.code == 'requires-recent-login') {
        message = 'Please re-login and try again.';
      }
      throw Exception(message);
    } catch (e) {
      throw Exception('Failed to delete account: $e');
    }
  }
}
