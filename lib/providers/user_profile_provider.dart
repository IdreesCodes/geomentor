import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../model/user_profile.dart';
import '../services/supabase_service.dart';
import 'auth_provider.dart';

final userProfileProvider = FutureProvider<UserProfile?>((ref) async {
  final supabaseService = ref.watch(supabaseServiceProvider);
  return await supabaseService.getCurrentUserProfile();
});

class UserProfileNotifier extends StateNotifier<AsyncValue<UserProfile?>> {
  final SupabaseService _supabaseService;

  UserProfileNotifier(this._supabaseService)
    : super(const AsyncValue.loading()) {
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      state = const AsyncValue.loading();
      final profile = await _supabaseService.getCurrentUserProfile();
      state = AsyncValue.data(profile);
    } catch (error) {
      state = AsyncValue.error(error, StackTrace.current);
    }
  }

  Future<void> updateProfile(UserProfile profile) async {
    try {
      state = const AsyncValue.loading();
      await _supabaseService.updateUserProfile(profile.id, profile);
      state = AsyncValue.data(profile);
    } catch (error) {
      state = AsyncValue.error(error, StackTrace.current);
    }
  }

  Future<void> refreshProfile() async {
    await _loadProfile();
  }
}

final userProfileNotifierProvider =
    StateNotifierProvider<UserProfileNotifier, AsyncValue<UserProfile?>>((ref) {
      final supabaseService = ref.watch(supabaseServiceProvider);
      return UserProfileNotifier(supabaseService);
    });
