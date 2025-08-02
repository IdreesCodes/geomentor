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
    print('🔧 SupabaseService: Initializing Supabase...');
    print('🔧 SupabaseService: URL: ${SupabaseConfig.supabaseUrl}');
    print(
      '🔧 SupabaseService: Anon Key: ${SupabaseConfig.supabaseAnonKey.substring(0, 20)}...',
    );

    await Supabase.initialize(
      url: SupabaseConfig.supabaseUrl,
      anonKey: SupabaseConfig.supabaseAnonKey,
    );
    _client = Supabase.instance.client;

    print('🔧 SupabaseService: Initialization complete');
    print('🔧 SupabaseService: Client initialized successfully');
  }

  SupabaseClient get client => _client;

  // Authentication methods
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    Map<String, dynamic>? userData,
  }) async {
    print('🔧 SupabaseService: Starting signUp for $email');
    print('🔧 SupabaseService: User data: $userData');

    final response = await _client.auth.signUp(
      email: email,
      password: password,
      data: userData,
    );

    print('🔧 SupabaseService: SignUp response received');
    print('🔧 SupabaseService: User created: ${response.user != null}');
    print('🔧 SupabaseService: Session created: ${response.session != null}');

    return response;
  }

  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    print('🔧 SupabaseService: Starting signIn for $email');

    final response = await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );

    print('🔧 SupabaseService: SignIn response received');
    print('🔧 SupabaseService: User authenticated: ${response.user != null}');
    print('🔧 SupabaseService: Session created: ${response.session != null}');

    return response;
  }

  Future<void> signOut() async {
    print('🔧 SupabaseService: Starting signOut');
    await _client.auth.signOut();
    print('🔧 SupabaseService: SignOut completed');
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
    try {
      print('🔧 SupabaseService: Getting user by ID: $userId');
      final response = await _client
          .from('users')
          .select()
          .eq('id', userId)
          .single();

      print('🔧 SupabaseService: User found: ${response != null}');
      return response != null ? UserProfile.fromJson(response) : null;
    } catch (error) {
      print('❌ SupabaseService: Error getting user by ID: $error');
      return null;
    }
  }

  Future<UserProfile?> getCurrentUserProfile() async {
    final user = _client.auth.currentUser;
    print('🔧 SupabaseService: Getting current user profile');
    print('🔧 SupabaseService: Current user - ${user?.id}');

    if (user == null) {
      print('🔧 SupabaseService: No current user found');
      return null;
    }

    try {
      final profile = await getUserById(user.id);
      print('🔧 SupabaseService: Profile retrieved - ${profile?.fullName}');
      return profile;
    } catch (error) {
      print('❌ SupabaseService: Error getting user profile: $error');
      return null;
    }
  }

  Future<void> createUserProfile(UserProfile userProfile) async {
    print(
      '🔧 SupabaseService: Creating user profile for ${userProfile.fullName}',
    );
    print('🔧 SupabaseService: Profile data: ${userProfile.toJson()}');

    try {
      // First, let's check if the table exists and what the current user is
      final currentUser = _client.auth.currentUser;
      print(
        '🔧 SupabaseService: Current user when creating profile: ${currentUser?.id}',
      );

      // Try to insert the profile directly
      final response = await _client.from('users').insert(userProfile.toJson());
      print('🔧 SupabaseService: User profile created successfully');
      print('🔧 SupabaseService: Response: $response');
    } catch (error) {
      print('❌ SupabaseService: Error creating user profile: $error');
      print('❌ SupabaseService: Error details: ${error.toString()}');

      // Fallback: try direct insert
      try {
        print('🔧 SupabaseService: Trying direct insert as fallback...');
        final response = await _client
            .from('users')
            .insert(userProfile.toJson());
        print('🔧 SupabaseService: Direct insert successful: $response');
      } catch (directError) {
        print('❌ SupabaseService: Direct insert also failed: $directError');

        // Let's also try to check if the table exists
        try {
          final tableCheck = await _client
              .from('users')
              .select('count')
              .limit(1);
          print('🔧 SupabaseService: Table check result: $tableCheck');
        } catch (tableError) {
          print('❌ SupabaseService: Table check failed: $tableError');
        }
      }

      throw error;
    }
  }

  Future<void> updateUserProfile(String userId, UserProfile userProfile) async {
    await _client.from('users').update(userProfile.toJson()).eq('id', userId);
  }

  Future<void> deleteUserProfile(String userId) async {
    await _client.from('users').delete().eq('id', userId);
  }

  // Debug method to check all users in the table
  Future<List<Map<String, dynamic>>> getAllUsers() async {
    try {
      print('🔧 SupabaseService: Testing connection to users table...');
      final response = await _client.from('users').select('*');
      print('🔧 SupabaseService: All users in table: $response');
      return List<Map<String, dynamic>>.from(response);
    } catch (error) {
      print('❌ SupabaseService: Error getting all users: $error');
      print('❌ SupabaseService: Error type: ${error.runtimeType}');
      return [];
    }
  }

  // Test connection method
  Future<bool> testConnection() async {
    try {
      print('🔧 SupabaseService: Testing database connection...');
      // Try a simple query to test connection
      final response = await _client.from('users').select('count').limit(1);
      print('🔧 SupabaseService: Connection test successful: $response');
      return true;
    } catch (error) {
      print('❌ SupabaseService: Connection test failed: $error');
      return false;
    }
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
