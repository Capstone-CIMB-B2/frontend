class PromoResponse {
  final String userId;
  final String message;
  final String promoTitle;
  final String promoType;
  final String? generatedMessage;
  final String? predictedCta;
  final String? ctaUrl;
  final String? triggerReason;
  final String? categoryFocus;

  PromoResponse({
    required this.userId,
    required this.message,
    required this.promoTitle,
    required this.promoType,
    this.generatedMessage,
    this.predictedCta,
    this.ctaUrl,
    this.triggerReason,
    this.categoryFocus,
  });

  factory PromoResponse.fromJson(Map<String, dynamic> json) {
    return PromoResponse(
      userId: (json['user_id'] ?? '').toString(),
      message: json['message'] ?? '',
      promoTitle: json['promo_title'] ?? '',
      promoType: json['promo_type'] ?? '',
      generatedMessage: json['generated_message'],
      predictedCta: json['predicted_cta'],
      ctaUrl: json['cta_url'],
      triggerReason: json['trigger_reason'],
      categoryFocus: json['category_focus'],
    );
  }
}

