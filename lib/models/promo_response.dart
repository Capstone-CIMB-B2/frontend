class PromoResponse {
  final String userId;
  final String message;
  final String promoTitle;
  final String promoType;

  PromoResponse({
    required this.userId,
    required this.message,
    required this.promoTitle,
    required this.promoType,
  });

  factory PromoResponse.fromJson(Map<String, dynamic> json) {
    return PromoResponse(
      userId: json['user_id'] ?? '',
      message: json['message'] ?? '',
      promoTitle: json['promo_title'] ?? '',
      promoType: json['promo_type'] ?? '',
    );
  }
}
