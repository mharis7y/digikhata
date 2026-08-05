import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/business_profile_model.dart';

/// BusinessProvider manages profile and business setup state per agents.md.
/// Also loads the saved profile from Supabase on app start so the Home screen
/// can display the business name, type, and category.
class BusinessProvider extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;

  BusinessProfileModel? _profile;
  bool _isLoading = false;
  String? _errorMessage;

  BusinessProfileModel? get profile => _profile;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void updateProfile(BusinessProfileModel profile) {
    _profile = profile;
    notifyListeners();
  }

  /// Loads the business profile from Supabase for the given user.
  /// Called on app start (from splash screen) so the Home screen has
  /// the business name immediately available.
  Future<void> loadProfile(String userId) async {
    try {
      final data = await _supabase
          .from('profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();

      if (data != null) {
        _profile = BusinessProfileModel(
          userId: data['id'] as String,
          selfieUrl: data['selfie_url'] as String?,
          cnicFrontUrl: data['cnic_front_url'] as String?,
          cnicBackUrl: data['cnic_back_url'] as String?,
          isNotBusinessPerson:
              data['is_not_business_person'] as bool? ?? false,
          businessName: data['business_name'] as String?,
          businessType: data['business_type'] as String?,
          businessCategory: data['business_category'] as String?,
        );
        notifyListeners();
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('BusinessProvider.loadProfile error: $e');
      }
    }
  }

  /// Saves the business profile to Supabase and marks profile setup complete.
  Future<bool> saveProfile(String userId) async {
    if (_profile == null) return false;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Upsert profile data
      await _supabase.from('profiles').upsert({
        'id': userId,
        'selfie_url': _profile!.selfieUrl,
        'cnic_front_url': _profile!.cnicFrontUrl,
        'cnic_back_url': _profile!.cnicBackUrl,
        'is_not_business_person': _profile!.isNotBusinessPerson,
        'business_name': _profile!.businessName,
        'business_type': _profile!.businessType,
        'business_category': _profile!.businessCategory,
        'is_profile_setup_complete': true,
        'updated_at': DateTime.now().toIso8601String(),
      });

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      // Log the real error for debugging
      if (kDebugMode) {
        debugPrint('BusinessProvider.saveProfile error: $e');
      }
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
