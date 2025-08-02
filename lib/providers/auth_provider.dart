import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/supabase_service.dart';

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

  AuthNotifier(this._supabaseService) : super(const AsyncValue.loading()) {
    _supabaseService.authStateChanges.listen((user) {
      state = AsyncValue.data(user);
    });
  }

  Future<void> signUp({
    required String email,
    required String password,
    Map<String, dynamic>? userData,
  }) async {
    try {
      state = const AsyncValue.loading();
      await _supabaseService.signUp(
        email: email,
        password: password,
        userData: userData,
      );
    } catch (error) {
      state = AsyncValue.error(error, StackTrace.current);
    }
  }

  Future<void> signIn({required String email, required String password}) async {
    try {
      state = const AsyncValue.loading();
      await _supabaseService.signIn(email: email, password: password);
    } catch (error) {
      state = AsyncValue.error(error, StackTrace.current);
    }
  }

  Future<void> signOut() async {
    try {
      await _supabaseService.signOut();
    } catch (error) {
      state = AsyncValue.error(error, StackTrace.current);
    }
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
