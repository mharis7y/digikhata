import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/business_profile_model.dart';

/// BusinessProvider manages profile and business setup state per agents.md.
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
