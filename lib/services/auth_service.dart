import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Get current user
  User? get currentUser => _supabase.auth.currentUser;

  // Auth state changes
  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;

  // Register with email and password
  Future<Map<String, dynamic>> registerWithEmailPassword({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      print('🔥 Starting registration...');

      // 1. Sign up with Supabase Auth
      final AuthResponse res = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {'display_name': displayName},
      );

      final User? user = res.user;

      if (user != null) {
        // 2. Create profile entry (Trigger usually handles this, but we'll do it manually to be safe or if trigger isn't set)
        // Note: Ideally, use a Database Trigger in Supabase to create a profile on new user.
        // For now, we'll try to insert/upsert to 'profiles' table.
        try {
          await _supabase.from('profiles').upsert({
            'id': user.id,
            'email': email,
            'display_name': displayName,
            'created_at': DateTime.now().toIso8601String(),
          });
        } catch (e) {
          print('⚠️ Profile creation warning: $e');
          // Ignore if trigger already did it
        }
      }

      return {
        'success': true,
        'message':
            'Registration successful! Please check your email for confirmation.',
        'user': user,
      };
    } on AuthException catch (e) {
      print('❌ Registration error: ${e.message}');
      throw Exception(e.message);
    } catch (e) {
      print('❌ Registration error: $e');
      throw Exception('Registration failed: $e');
    }
  }

  // Sign in with Google
  Future<Map<String, dynamic>> signInWithGoogle() async {
    try {
      print('🌐 Starting Google Sign-In...');
      
      // 1. Trigger Google Sign-In
      // Setup: Ensure Google Sign-In is configured in Google Cloud Console & Supabase
      // iOS: GoogleService-Info.plist in ios/Runner
      // Android: google-services.json in android/app

      final GoogleSignIn googleSignIn = GoogleSignIn(
        // serverClientId: 'YOUR_WEB_CLIENT_ID.apps.googleusercontent.com', // Optional: simpler to config in Supabase
      );
      
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      
      if (googleUser == null) {
        throw Exception('Google Sign-In canceled by user.');
      }
      
      print('✅ Google user obtained: ${googleUser.email}');

      // 2. Obtain auth details
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final accessToken = googleAuth.accessToken;
      final idToken = googleAuth.idToken;

      if (accessToken == null) {
        throw Exception('No Access Token found.');
      }
      if (idToken == null) {
        throw Exception('No ID Token found.');
      }

      print('🔑 Tokens obtained. Signing in to Supabase...');

      // 3. Sign in to Supabase with ID Token
      final AuthResponse res = await _supabase.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );

      final User? user = res.user;
      
      if (user != null) {
        // Upsert profile (similar to email auth)
        try {
           await _supabase.from('profiles').upsert({
            'id': user.id,
            'email': user.email,
            'display_name': user.userMetadata?['full_name'] ?? googleUser.displayName,
            'avatar_url': user.userMetadata?['avatar_url'] ?? googleUser.photoUrl,
            'created_at': DateTime.now().toIso8601String(),
          });
        } catch (e) {
          print('⚠️ Profile upsert warning: $e');
        }
      }

      return {'success': true, 'message': 'Google Login successful', 'user': user};

    } on Exception catch (e) {
      print('❌ Google Login error: $e');
      throw Exception('Google Login failed: $e');
    }
  }

  // Sign in with email and password
  Future<Map<String, dynamic>> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    try {
      print('🔐 Starting login...');

      final AuthResponse res = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      return {'success': true, 'message': 'Login successful', 'user': res.user};
    } on AuthException catch (e) {
      print('❌ Login error: ${e.message}');
      throw Exception(e.message);
    } catch (e) {
      print('❌ Login error: $e');
      throw Exception('Login failed: $e');
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      await _supabase.auth.signOut();
      try {
        await GoogleSignIn().signOut();
      } catch (_) {
        // Ignore if google sign in wasn't used or fails
      }
    } catch (e) {
      print('❌ Logout error: $e');
      throw Exception('Logout failed: $e');
    }
  }

  // Reset password
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _supabase.auth.resetPasswordForEmail(
        email,
        redirectTo: 'io.supabase.petperks://login-callback',
      );
    } on AuthException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception('Failed to send reset email: $e');
    }
  }

  // Update password
  Future<void> updatePassword(String newPassword) async {
    try {
      await _supabase.auth.updateUser(UserAttributes(password: newPassword));
    } on AuthException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception('Failed to update password: $e');
    }
  }

  // Delete account
  // Note: Only Service Role can delete users usually, or requires special function.
  // For now, we will mark as deleted or delete profile.
  // Deleting the auth user from client side is tricky without admin API.
  Future<void> deleteAccount() async {
    // This often requires an Edge Function or RPC if "Enable delete user from client" is disabled.
    throw Exception(
      'Delete account requires admin privileges or backend function.',
    );
  }
  // Check if email is registered
  Future<bool> isEmailRegistered(String email) async {
    try {
      // Use RPC function 'check_email_exists'
      // This requires the SQL function to be created in Supabase first.
      final bool exists = await _supabase.rpc('check_email_exists', params: {
        'email_to_check': email,
      });

      return exists;
    } catch (e) {
      print('Error checking email via RPC: $e');
      // If RPC fails (e.g. function not found), strict security might say return false 
      // or throw error. Here we return false to assume "not found" or "error preventing found".
      return false;
    }
  }
}
