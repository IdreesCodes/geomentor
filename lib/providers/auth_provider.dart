import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/supabase_service.dart';
import '../model/user_profile.dart';

final supabaseServiceProvider = Provider<SupabaseService>((ref) {
  return SupabaseService();
});

final authStateProvider = StreamProvider<User?>((ref) {
  final supabaseService = ref.watch(supabaseServiceProvider);
  return supabaseService.authStateChanges;
});

final currentUserProvider = Provider<User?>((ref) {
  final supabaseService = ref.watch(supabaseServiceProvider);
  return supabaseService.currentUser;
});

class AuthNotifier extends StateNotifier<AsyncValue<User?>> {
  final SupabaseService _supabaseService;
  StreamSubscription<User?>? _authSubscription;

  AuthNotifier(this._supabaseService) : super(const AsyncValue.loading()) {
    _authSubscription = _supabaseService.authStateChanges.listen((user) {
      if (!mounted) return; // Check if notifier is still mounted
      state = AsyncValue.data(user);
    });
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }

  Future<void> signUp({
    required String email,
    required String password,
    Map<String, dynamic>? userData,
  }) async {
    try {
      state = const AsyncValue.loading();
      print('🔄 Starting signup process for email: $email');

      // Test connection first
      print('🔍 Testing database connection...');
      final connectionTest = await _supabaseService.testConnection();
      print('🔍 Connection test result: $connectionTest');

      final authResponse = await _supabaseService.signUp(
        email: email,
        password: password,
        userData: userData,
      );

      print('✅ Supabase Signup Response:');
      print('   - User ID: ${authResponse.user?.id}');
      print('   - Email: ${authResponse.user?.email}');
      print('   - Email Confirmed: ${authResponse.user?.emailConfirmedAt}');
      print(
        '   - Session: ${authResponse.session != null ? "Created" : "None"}',
      );
      print(
        '   - Error: ${authResponse.user?.identities?.length ?? 0} identities',
      );
      print('   - User Metadata: ${authResponse.user?.userMetadata}');

      // Create user profile in database after successful signup
      final currentUser = _supabaseService.currentUser;
      print('👤 Current User after signup: ${currentUser?.id ?? "None"}');

      // Use the user from authResponse since currentUser might be null after signup
      final userId = authResponse.user?.id;
      if (userId != null && userData != null) {
        print(
          '📝 User signup completed, checking if trigger created profile...',
        );

        // Wait a moment for the trigger to execute
        await Future.delayed(Duration(milliseconds: 1000));

        // Check if our user was created by the trigger - use a direct query
        try {
          print('🔍 Checking if user profile was created by trigger...');
          final userProfile = await _supabaseService.getUserById(userId);
          if (userProfile != null) {
            print('✅ User profile was created by trigger successfully');
            print('👤 User profile: ${userProfile.fullName}');
          } else {
            print(
              '⚠️ User profile was not created by trigger, trying manual creation...',
            );
            try {
              final userProfile = UserProfile(
                id: userId,
                email: email,
                fullName: userData['full_name'] ?? '',
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
              );
              await _supabaseService.createUserProfile(userProfile);
              print('✅ User profile created manually');
            } catch (profileError) {
              print('❌ Error creating user profile manually: $profileError');
            }
          }
        } catch (error) {
          print('❌ Error checking user profile: $error');
        }
      } else {
        print(
          '⚠️ Could not create user profile - missing user ID or user data',
        );
        print('   - User ID: $userId');
        print('   - User Data: $userData');
      }

      // Sign out after creating profile so user needs to login manually
      print('🚪 Signing out user...');
      await _supabaseService.signOut();
      print('✅ User signed out successfully');

      // Reset state to loading to trigger auth state change
      state = const AsyncValue.loading();
      print('🔄 Auth state reset to loading');
    } catch (error) {
      print('❌ Signup Error: $error');
      print('❌ Error Stack Trace: ${StackTrace.current}');
      state = AsyncValue.error(error, StackTrace.current);
    }
  }

  Future<void> signIn({required String email, required String password}) async {
    try {
      state = const AsyncValue.loading();
      print('🔄 Starting login process for email: $email');

      final authResponse = await _supabaseService.signIn(
        email: email,
        password: password,
      );

      print('✅ Supabase Login Response:');
      print('   - User ID: ${authResponse.user?.id}');
      print('   - Email: ${authResponse.user?.email}');
      print('   - Email Confirmed: ${authResponse.user?.emailConfirmedAt}');
      print(
        '   - Session: ${authResponse.session != null ? "Created" : "None"}',
      );
      print(
        '   - Access Token: ${authResponse.session?.accessToken != null ? "Present" : "None"}',
      );

      final currentUser = _supabaseService.currentUser;
      print('👤 Current User after login: ${currentUser?.id ?? "None"}');
    } catch (error) {
      print('❌ Login Error: $error');
      print('❌ Error Stack Trace: ${StackTrace.current}');
      state = AsyncValue.error(error, StackTrace.current);
    }
  }

  Future<void> signOut() async {
    try {
      print('🚪 Starting sign out process...');
      final currentUser = _supabaseService.currentUser;
      print('👤 Current User before signout: ${currentUser?.id ?? "None"}');

      await _supabaseService.signOut();
      print('✅ User signed out successfully');

      // Force reset the state to ensure it's properly cleared
      state = const AsyncValue.data(null);
    } catch (error) {
      print('❌ Signout Error: $error');
      print('❌ Error Stack Trace: ${StackTrace.current}');
      state = AsyncValue.error(error, StackTrace.current);
    }
  }

  // Method to force reset auth state
  void resetAuthState() {
    print('🔄 Resetting auth state...');
    state = const AsyncValue.data(null);
  }

  Future<void> resetPassword(String email) async {
    try {
      await _supabaseService.resetPassword(email);
    } catch (error) {
      state = AsyncValue.error(error, StackTrace.current);
    }
  }
}

final authNotifierProvider =
    StateNotifierProvider<AuthNotifier, AsyncValue<User?>>((ref) {
      final supabaseService = ref.watch(supabaseServiceProvider);
      return AuthNotifier(supabaseService);
    });
