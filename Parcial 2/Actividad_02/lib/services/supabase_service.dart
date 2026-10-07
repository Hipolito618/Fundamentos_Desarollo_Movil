import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/song_model.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  SupabaseService._internal();

  final _supabase = Supabase.instance.client;

  User? get currentUser => _supabase.auth.currentUser;
  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;

  Future<AuthResponse> signIn(String email, String password) async {
    return await _supabase.auth.signInWithPassword(email: email, password: password);
  }

  Future<AuthResponse> signUp(String email, String password) async {
    return await _supabase.auth.signUp(email: email, password: password);
  }

  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  Future<List<Song>> getSongs() async {
    final response = await _supabase.from('canciones').select().order('id');
    return (response as List).map((json) => Song.fromJson(json)).toList();
  }

  Future<void> toggleFavorite(int songId, bool isCurrentlyFavorite) async {
    await _supabase.from('canciones').update({
      'favorita': !isCurrentlyFavorite
    }).eq('id', songId);
  }
}

