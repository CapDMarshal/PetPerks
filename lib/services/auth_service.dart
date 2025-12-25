import 'package:supabase_flutter/supabase_flutter.dart';

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
    } catch (e) {
      print('❌ Logout error: $e');
      throw Exception('Logout failed: $e');
    }
  }

  // Reset password
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _supabase.auth.resetPasswordForEmail(email);
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
}
