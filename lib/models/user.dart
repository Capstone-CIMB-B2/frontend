class UserModel {
  final String username;
  final String fullName;
  final String phoneNumber;
  final String nik;
  final String dob;
  final String birthPlace;
  final String emailAddress;
  final String occupation;
  final String address;
  final String city;
  final String province;
  final double monthlyIncome;
  final bool consentPersonalization;

  const UserModel({
    required this.username,
    required this.fullName,
    required this.phoneNumber,
    required this.nik,
    required this.dob,
    required this.birthPlace,
    required this.emailAddress,
    required this.occupation,
    required this.address,
    required this.city,
    required this.province,
    required this.monthlyIncome,
    required this.consentPersonalization,
  });

  /// Buat dari response API GET /profile
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      username: json['username'] as String? ?? '',
      fullName: json['full_name'] as String? ?? '',
      phoneNumber: json['phone_number'] as String? ?? '',
      nik: json['nik'] as String? ?? json['national_id'] as String? ?? '',
      dob: json['dob'] as String? ?? json['birth_date'] as String? ?? '',
      birthPlace: json['birth_place'] as String? ?? '',
      emailAddress: json['email_address'] as String? ?? '',
      occupation: json['occupation'] as String? ?? '',
      address: json['address'] as String? ?? json['street_address'] as String? ?? '',
      city: json['city'] as String? ?? '',
      province: json['province'] as String? ?? '',
      monthlyIncome: (json['monthly_income'] as num?)?.toDouble() ?? 0.0,
      consentPersonalization: json['consent_personalization'] as bool? ?? false,
    );
  }

  /// Untuk dikirim ke API PUT /profile (edit profil)
  Map<String, dynamic> toJson() {
    return {
      'full_name': fullName,
      'phone_number': phoneNumber,
      'nik': nik,
      'dob': dob,
      'birth_place': birthPlace,
      'email_address': emailAddress,
      'occupation': occupation,
      'address': address,
      'city': city,
      'province': province,
      'monthly_income': monthlyIncome,
      'consent_personalization': consentPersonalization,
    };
  }

  /// Untuk edit profil
  UserModel copyWith({
    String? username,
    String? fullName,
    String? phoneNumber,
    String? nik,
    String? dob,
    String? birthPlace,
    String? emailAddress,
    String? occupation,
    String? address,
    String? city,
    String? province,
    double? monthlyIncome,
    bool? consentPersonalization,
  }) {
    return UserModel(
      username: username ?? this.username,
      fullName: fullName ?? this.fullName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      nik: nik ?? this.nik,
      dob: dob ?? this.dob,
      birthPlace: birthPlace ?? this.birthPlace,
      emailAddress: emailAddress ?? this.emailAddress,
      occupation: occupation ?? this.occupation,
      address: address ?? this.address,
      city: city ?? this.city,
      province: province ?? this.province,
      monthlyIncome: monthlyIncome ?? this.monthlyIncome,
      consentPersonalization:
          consentPersonalization ?? this.consentPersonalization,
    );
  }

  /// Nama yang ditampilkan di header transfer, settings, dll
  String get displayName => fullName.toUpperCase();

  // /// Inisial untuk avatar
  // String get initials {
  //   final parts = fullName.trim().split(' ');
  //   return parts.length >= 2
  //       ? '${parts[0][0]}${parts[1][0]}'.toUpperCase()
  //       : fullName.substring(0, 2).toUpperCase();
  // }

  /// Nomor HP yang di-mask untuk ditampilkan (misal: 08****1234)
  String get maskedPhone {
    if (phoneNumber.length < 6) return phoneNumber;
    final first = phoneNumber.substring(0, 2);
    final last = phoneNumber.substring(phoneNumber.length - 4);
    return '$first****$last';
  }
}