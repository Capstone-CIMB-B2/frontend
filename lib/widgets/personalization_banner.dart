import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../screens/personalisasi_screen.dart';
import '../services/api_service.dart';
import '../models/promo_response.dart';

class PersonalizationBanner extends StatefulWidget {
  const PersonalizationBanner({super.key});

  @override
  State<PersonalizationBanner> createState() => _PersonalizationBannerState();
}

class _PersonalizationBannerState extends State<PersonalizationBanner> {
  PromoResponse? _promo;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    isPersonalizationEnabledNotifier.addListener(_fetchRecommendation);
    _fetchRecommendation();
  }

  @override
  void dispose() {
    isPersonalizationEnabledNotifier.removeListener(_fetchRecommendation);
    super.dispose();
  }

  Future<void> _fetchRecommendation() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    final promo = await ApiService.getRecommendation();
    if (mounted) {
      setState(() {
        _promo = promo;
        _isLoading = false;
      });
      if (promo != null) {
        ApiService.trackInteraction(
          featureAccessed: 'Personalization Banner',
          action: 'view',
          interactionType: 'insight_view',
        );
      }
    }
  }

  void _handleCta(PromoResponse promo) {
    ApiService.trackInteraction(
      featureAccessed: 'Personalization Banner',
      action: 'click',
      interactionType: 'cta_click',
    );
    final cta = promo.predictedCta?.toLowerCase() ?? '';
    final url = promo.ctaUrl ?? '';

    if (url == '/profile/consent' || cta.contains('aktifkan')) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const PersonalisasiScreen()),
      );
    } else if (cta.contains('schedule') || cta.contains('jadwal')) {
      Navigator.pushNamed(context, '/tagihan');
    } else if (cta.contains('transfer')) {
      Navigator.pushNamed(context, '/transfer');
    } else {
      // Tampilkan detail promo dalam dialog premium
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              const Icon(Icons.stars_rounded, color: Color(0xFFD90002)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  promo.promoTitle,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
          content: Text(
            promo.generatedMessage ?? promo.message,
            style: const TextStyle(fontSize: 14, height: 1.4),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text(
                'Tutup',
                style: TextStyle(
                  color: Color(0xFFD90002),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        height: 100,
        decoration: BoxDecoration(
          color: const Color(0xFFFFF9EC),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFF3E5D8)),
        ),
        child: const Center(
          child: CircularProgressIndicator(
            color: Color(0xFFD90002),
            strokeWidth: 2,
          ),
        ),
      );
    }

    if (_promo == null) {
      return const SizedBox.shrink();
    }

    final promo = _promo!;
    final String text = promo.generatedMessage ?? promo.promoTitle;
    final String actionText = promo.predictedCta ?? 'Lihat Selengkapnya';

    return Align(
      alignment: Alignment.topCenter,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF9EC), // Soft yellow/cream background
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFF3E5D8)), // Soft pinkish border
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 4, right: 14),
              child: SvgPicture.asset(
                'assets/icons/PersonalizationBanner.svg',
                width: 30,
                height: 30,
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    text,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF333333),
                      height: 1.4,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () => _handleCta(promo),
                    child: Row(
                      children: [
                        Text(
                          actionText.trim(),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFD90002),
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.arrow_forward_rounded,
                          size: 16,
                          color: Color(0xFFD90002),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

