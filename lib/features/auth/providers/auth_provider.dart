import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';

/// AuthProvider manages authentication state per agents.md.
///
/// Flow:
/// - Email → OTP sent → OTP verified
/// - Existing user → Home
/// - New user → Profile Setup
class AuthProvider extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;

  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _currentUser != null;
  bool get isSuperAdmin => _currentUser?.isSuperAdmin ?? false;

  /// Sends OTP to the given email via Supabase magic link / OTP.
  Future<bool> sendOtp(String email) async {
    _setLoading(true);
    _clearError();
    try {
      await _supabase.auth.signInWithOtp(
        email: email,
        shouldCreateUser: true,
      );
      _setLoading(false);
      return true;
    } on AuthException catch (e) {
      _setError(e.message);
      return false;
    } catch (e) {
      _setError('Failed to send OTP. Please try again.');
      return false;
    }
  }

  /// Verifies OTP. On success, loads user profile and determines routing.
  Future<bool> verifyOtp(String email, String otp) async {
    _setLoading(true);
    _clearError();
    try {
      final response = await _supabase.auth.verifyOTP(
        email: email,
        token: otp,
        type: OtpType.email,
      );

      if (response.user != null) {
        await _loadUserProfile(response.user!.id, email);
        _setLoading(false);
        return true;
      } else {
        _setError('Invalid OTP. Please try again.');
        return false;
      }
    } on AuthException catch (e) {
      _setError(e.message);
      return false;
    } catch (e) {
      _setError('Verification failed. Please try again.');
      return false;
    }
  }

  /// Loads (or creates) a user profile from Supabase.
  Future<void> _loadUserProfile(String userId, String email) async {
    try {
      final data = await _supabase
          .from('profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();

      if (data != null) {
        _currentUser = UserModel.fromJson(data);
      } else {
        // New user — profile not yet set up
        _currentUser = UserModel(
          id: userId,
          email: email,
          isProfileSetupComplete: false,
          createdAt: DateTime.now(),
        );
      }
      notifyListeners();
    } catch (_) {
      // Fallback: treat as new user
      _currentUser = UserModel(
        id: userId,
        email: email,
        isProfileSetupComplete: false,
        createdAt: DateTime.now(),
      );
      notifyListeners();
    }
  }

  /// Checks if there is an existing Supabase session on app start.
  Future<void> checkSession() async {
    final session = _supabase.auth.currentSession;
    if (session != null) {
      await _loadUserProfile(session.user.id, session.user.email ?? '');
    }
  }

  /// Updates the current user in state (used after profile setup).
  void setUser(UserModel user) {
    _currentUser = user;
    notifyListeners();
  }

  /// Logs out the current user.
  Future<void> logout() async {
    await _supabase.auth.signOut();
    _currentUser = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    _isLoading = false;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }
}
