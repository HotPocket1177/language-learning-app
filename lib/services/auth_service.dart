import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_service.dart';

class AuthService {
  final SupabaseClient _supabase = SupabaseService.client;

  // Get current user
  User? get currentUser => _supabase.auth.currentUser;

  // Get current user ID
  String? get currentUserId => _supabase.auth.currentUser?.id;

  // Check if user is signed in
  bool get isSignedIn => _supabase.auth.currentUser != null;

  // Check if user is guest (anonymous)
  bool get isGuest => _supabase.auth.currentUser?.isAnonymous ?? false;

  // Auth state changes stream
  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;

  // Sign up with email and password
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String username,
  }) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {'username': username},
      );

      if (response.user == null) {
        throw 'Failed to create account. Please try again.';
      }

      return response;
    } on AuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'An unexpected error occurred: $e';
    }
  }

  // Sign in with email and password
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw 'Failed to sign in. Please check your credentials.';
      }

      return response;
    } on AuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'An unexpected error occurred: $e';
    }
  }

  // Sign in anonymously (Guest Mode)
  Future<AuthResponse> signInAnonymously() async {
    try {
      final response = await _supabase.auth.signInAnonymously(
        data: {'username': 'Guest'},
      );

      if (response.user == null) {
        throw 'Failed to sign in as guest.';
      }

      return response;
    } on AuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'An unexpected error occurred: $e';
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
    } on AuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'Failed to sign out: $e';
    }
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _supabase.auth.resetPasswordForEmail(email);
    } on AuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'Failed to send password reset email: $e';
    }
  }

  // Update user profile
  Future<void> updateProfile({
    String? username,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final updates = <String, dynamic>{};
      if (username != null) {
        updates['username'] = username;
      }
      if (metadata != null) {
        updates.addAll(metadata);
      }

      if (updates.isNotEmpty) {
        await _supabase.auth.updateUser(
          UserAttributes(data: updates),
        );
      }
    } on AuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'Failed to update profile: $e';
    }
  }

  // Get user metadata
  Map<String, dynamic>? get userMetadata {
    return _supabase.auth.currentUser?.userMetadata;
  }

  // Get username
  String get username {
    final metadata = userMetadata;
    if (metadata != null && metadata.containsKey('username')) {
      return metadata['username'] as String;
    }
    return isGuest ? 'Guest' : 'Student';
  }

  // Handle Supabase Auth exceptions
  String _handleAuthException(AuthException e) {
    switch (e.statusCode) {
      case '400':
        if (e.message.contains('already registered')) {
          return 'This email is already registered. Please sign in instead.';
        }
        if (e.message.contains('Invalid')) {
          return 'Invalid email or password format.';
        }
        return 'Bad request. Please check your input.';

      case '401':
      case '422':
        return 'Invalid email or password. Please try again.';

      case '429':
        return 'Too many requests. Please wait a moment and try again.';

      case '500':
        return 'Server error. Please try again later.';

      default:
        if (e.message.contains('Email not confirmed')) {
          return 'Please verify your email address before signing in.';
        }
        if (e.message.contains('Invalid login')) {
          return 'Invalid email or password.';
        }
        if (e.message.contains('User not found')) {
          return 'No account found with this email.';
        }
        if (e.message.contains('weak password')) {
          return 'Password is too weak. Use at least 6 characters.';
        }
        return e.message.isNotEmpty ? e.message : 'Authentication error occurred.';
    }
  }

  // Delete user account
  Future<void> deleteAccount() async {
    try {
      // Note: Supabase doesn't have a direct delete user endpoint from client
      // This would typically be done via a server-side function
      // For now, we'll just sign out
      await signOut();
    } catch (e) {
      throw 'Failed to delete account: $e';
    }
  }
}
