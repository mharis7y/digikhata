/// Business Profile Model for profile setup per agents.md.
class BusinessProfileModel {
  final String userId;
  final String? selfieUrl;
  final String? cnicFrontUrl;
  final String? cnicBackUrl;
  final bool isNotBusinessPerson;
  final String? businessName;
  final String? businessType;
  final String? businessCategory;

  const BusinessProfileModel({
    required this.userId,
    this.selfieUrl,
    this.cnicFrontUrl,
    this.cnicBackUrl,
    this.isNotBusinessPerson = false,
    this.businessName,
    this.businessType,
    this.businessCategory,
  });

  factory BusinessProfileModel.fromJson(Map<String, dynamic> json) {
    return BusinessProfileModel(
      userId: json['user_id'] as String,
      selfieUrl: json['selfie_url'] as String?,
      cnicFrontUrl: json['cnic_front_url'] as String?,
      cnicBackUrl: json['cnic_back_url'] as String?,
      isNotBusinessPerson: json['is_not_business_person'] as bool? ?? false,
      businessName: json['business_name'] as String?,
      businessType: json['business_type'] as String?,
      businessCategory: json['business_category'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'selfie_url': selfieUrl,
      'cnic_front_url': cnicFrontUrl,
      'cnic_back_url': cnicBackUrl,
      'is_not_business_person': isNotBusinessPerson,
      'business_name': businessName,
      'business_type': businessType,
      'business_category': businessCategory,
    };
  }

  BusinessProfileModel copyWith({
    String? userId,
    String? selfieUrl,
    String? cnicFrontUrl,
    String? cnicBackUrl,
    bool? isNotBusinessPerson,
    String? businessName,
    String? businessType,
    String? businessCategory,
  }) {
    return BusinessProfileModel(
      userId: userId ?? this.userId,
      selfieUrl: selfieUrl ?? this.selfieUrl,
      cnicFrontUrl: cnicFrontUrl ?? this.cnicFrontUrl,
      cnicBackUrl: cnicBackUrl ?? this.cnicBackUrl,
      isNotBusinessPerson: isNotBusinessPerson ?? this.isNotBusinessPerson,
      businessName: businessName ?? this.businessName,
      businessType: businessType ?? this.businessType,
      businessCategory: businessCategory ?? this.businessCategory,
    );
  }
}
