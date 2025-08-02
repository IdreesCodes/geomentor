import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';
import '../model/user_profile.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  SupabaseService._internal();

  late final SupabaseClient _client;

  Future<void> initialize() async {
    await Supabase.initialize(
      url: SupabaseConfig.supabaseUrl,
      anonKey: SupabaseConfig.supabaseAnonKey,
    );
    _client = Supabase.instance.client;
  }

  SupabaseClient get client => _client;

  // Authentication methods
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    Map<String, dynamic>? userData,
  }) async {
    return await _client.auth.signUp(
      email: email,
      password: password,
      data: userData,
    );
  }

  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  Future<void> resetPassword(String email) async {
    await _client.auth.resetPasswordForEmail(email);
  }

  User? get currentUser => _client.auth.currentUser;

  Stream<User?> get authStateChanges =>
      _client.auth.onAuthStateChange.map((event) => event.session?.user);

  // Database methods
  Future<List<UserProfile>> getUsers() async {
    final response = await _client.from('users').select();

    return (response as List)
        .map((user) => UserProfile.fromJson(user))
        .toList();
  }

  Future<UserProfile?> getUserById(String userId) async {
    final response = await _client
        .from('users')
        .select()
        .eq('id', userId)
        .single();

    return response != null ? UserProfile.fromJson(response) : null;
  }

  Future<UserProfile?> getCurrentUserProfile() async {
    final user = _client.auth.currentUser;
    if (user == null) return null;

    return getUserById(user.id);
  }

  Future<void> createUserProfile(UserProfile userProfile) async {
    await _client.from('users').insert(userProfile.toJson());
  }

  Future<void> updateUserProfile(String userId, UserProfile userProfile) async {
    await _client.from('users').update(userProfile.toJson()).eq('id', userId);
  }

  Future<void> deleteUserProfile(String userId) async {
    await _client.from('users').delete().eq('id', userId);
  }

  // Storage methods
  Future<String> uploadFile({
    required String bucket,
    required String path,
    required Uint8List bytes,
    String? contentType,
  }) async {
    await _client.storage
        .from(bucket)
        .uploadBinary(
          path,
          bytes,
          fileOptions: FileOptions(contentType: contentType),
        );

    return _client.storage.from(bucket).getPublicUrl(path);
  }

  Future<void> deleteFile({
    required String bucket,
    required String path,
  }) async {
    await _client.storage.from(bucket).remove([path]);
  }
}
