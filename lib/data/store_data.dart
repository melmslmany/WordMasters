import 'package:flutter/material.dart';

/// Decorative pattern painted on top of a background gradient so that
/// backgrounds are rich scenes, not just flat colors.
enum BgPattern { none, stars, bubbles, waves, rays, aurora, snow, petals }

class StoreBackground {
  const StoreBackground({
    required this.id,
    required this.nameEn,
    required this.nameAr,
    required this.price,
    required this.colors,
    this.pattern = BgPattern.none,
    this.accent = const Color(0xFFFFFFFF),
    this.isDefault = false,
    this.isCustom = false,
  });

  final String id;
  final String nameEn;
  final String nameAr;
  final int price;
  final List<Color> colors;
  final BgPattern pattern;
  final Color accent;
  final bool isDefault;
  final bool isCustom;

  String name(bool isArabic) => isArabic ? nameAr : nameEn;
}

class CoinPack {
  const CoinPack({
    required this.id,
    required this.coins,
    required this.priceLabel,
    required this.bonus,
  });

  final String id;
  final int coins;
  final String priceLabel;
  final int bonus;
}

abstract final class StoreData {
  static const customId = 'custom';

  static const backgrounds = [
    StoreBackground(
      id: 'default',
      nameEn: 'Neon Night',
      nameAr: 'ليل نيون',
      price: 0,
      colors: [Color(0xFF1B1040), Color(0xFF0A0E1A)],
      pattern: BgPattern.stars,
      accent: Color(0xFF8B7BFF),
      isDefault: true,
    ),
    StoreBackground(
      id: 'mountain',
      nameEn: 'Mountain Dawn',
      nameAr: 'فجر الجبال',
      price: 150,
      colors: [Color(0xFF1A3A5C), Color(0xFF2D5A3D), Color(0xFF0A0E1A)],
      pattern: BgPattern.rays,
      accent: Color(0xFF7FE3C0),
    ),
    StoreBackground(
      id: 'sunset',
      nameEn: 'Sunset Valley',
      nameAr: 'وادي الغروب',
      price: 200,
      colors: [Color(0xFF6A1B4D), Color(0xFFB5462E), Color(0xFF2A1028)],
      pattern: BgPattern.rays,
      accent: Color(0xFFFFC07A),
    ),
    StoreBackground(
      id: 'ocean',
      nameEn: 'Ocean Breeze',
      nameAr: 'نسيم البحر',
      price: 250,
      colors: [Color(0xFF0D3B4C), Color(0xFF1A6B7C), Color(0xFF051A24)],
      pattern: BgPattern.bubbles,
      accent: Color(0xFF6FE0FF),
    ),
    StoreBackground(
      id: 'forest',
      nameEn: 'Enchanted Forest',
      nameAr: 'غابة ساحرة',
      price: 300,
      colors: [Color(0xFF14401F), Color(0xFF2D7A3D), Color(0xFF09180D)],
      pattern: BgPattern.petals,
      accent: Color(0xFF9CF08A),
    ),
    StoreBackground(
      id: 'aurora',
      nameEn: 'Northern Lights',
      nameAr: 'الشفق القطبي',
      price: 400,
      colors: [Color(0xFF14093A), Color(0xFF0A3A4A), Color(0xFF0A1A2A)],
      pattern: BgPattern.aurora,
      accent: Color(0xFF5DFFC8),
    ),
    StoreBackground(
      id: 'galaxy',
      nameEn: 'Deep Galaxy',
      nameAr: 'مجرة عميقة',
      price: 450,
      colors: [Color(0xFF2A0F4A), Color(0xFF120630), Color(0xFF05010F)],
      pattern: BgPattern.stars,
      accent: Color(0xFFD08BFF),
    ),
    StoreBackground(
      id: 'cherry',
      nameEn: 'Cherry Bloom',
      nameAr: 'أزهار الكرز',
      price: 350,
      colors: [Color(0xFF5A1B3A), Color(0xFF8A2D55), Color(0xFF2A1020)],
      pattern: BgPattern.petals,
      accent: Color(0xFFFF9EC6),
    ),
    StoreBackground(
      id: 'winter',
      nameEn: 'Winter Frost',
      nameAr: 'صقيع الشتاء',
      price: 350,
      colors: [Color(0xFF15314F), Color(0xFF2C5C7A), Color(0xFF0A1622)],
      pattern: BgPattern.snow,
      accent: Color(0xFFCDEBFF),
    ),
    StoreBackground(
      id: 'desert',
      nameEn: 'Desert Dunes',
      nameAr: 'كثبان الصحراء',
      price: 300,
      colors: [Color(0xFF6B4A1B), Color(0xFFB5832E), Color(0xFF2A1C0A)],
      pattern: BgPattern.waves,
      accent: Color(0xFFFFD98A),
    ),
  ];

  static const coinPacks = [
    CoinPack(id: 'coins_100', coins: 100, priceLabel: 'Free', bonus: 0),
    CoinPack(id: 'coins_500', coins: 500, priceLabel: '\$0.99', bonus: 50),
    CoinPack(id: 'coins_1200', coins: 1200, priceLabel: '\$1.99', bonus: 200),
    CoinPack(id: 'coins_3000', coins: 3000, priceLabel: '\$4.99', bonus: 750),
  ];

  static StoreBackground? byId(String id) {
    for (final bg in backgrounds) {
      if (bg.id == id) return bg;
    }
    return null;
  }
}
