import 'package:flutter/material.dart';
import '../models/category.dart';
import 'words_repository.dart';

abstract final class CategoriesData {
  static List<GameCategory> all = [
    GameCategory(
      id: 'animals',
      nameEn: 'Animals',
      nameAr: 'حيوانات',
      icon: Icons.pets_rounded,
      color: const Color(0xFF8B4513),
      gradient: [const Color(0xFFCD853F), const Color(0xFF8B4513)],
    ),
    GameCategory(
      id: 'food',
      nameEn: 'Food',
      nameAr: 'طعام',
      icon: Icons.restaurant_rounded,
      color: const Color(0xFFE74C3C),
      gradient: [const Color(0xFFFF6B6B), const Color(0xFFE74C3C)],
    ),
    GameCategory(
      id: 'nature',
      nameEn: 'Nature',
      nameAr: 'طبيعة',
      icon: Icons.park_rounded,
      color: const Color(0xFF27AE60),
      gradient: [const Color(0xFF2ECC71), const Color(0xFF27AE60)],
    ),
    GameCategory(
      id: 'sports',
      nameEn: 'Sports',
      nameAr: 'رياضة',
      icon: Icons.sports_soccer_rounded,
      color: const Color(0xFF2980B9),
      gradient: [const Color(0xFF3498DB), const Color(0xFF2980B9)],
    ),
    GameCategory(
      id: 'colors',
      nameEn: 'Colors',
      nameAr: 'ألوان',
      icon: Icons.palette_rounded,
      color: const Color(0xFF9B59B6),
      gradient: [const Color(0xFFBB6BD9), const Color(0xFF9B59B6)],
    ),
    GameCategory(
      id: 'countries',
      nameEn: 'Countries',
      nameAr: 'دول',
      icon: Icons.public_rounded,
      color: const Color(0xFF16A085),
      gradient: [const Color(0xFF1ABC9C), const Color(0xFF16A085)],
    ),
    GameCategory(
      id: 'jobs',
      nameEn: 'Careers',
      nameAr: 'مهن',
      icon: Icons.work_rounded,
      color: const Color(0xFF2ECC71),
      gradient: [const Color(0xFF58D68D), const Color(0xFF27AE60)],
      isLocked: true,
    ),
    GameCategory(
      id: 'fruits',
      nameEn: 'Fruits',
      nameAr: 'فواكه',
      icon: Icons.apple_rounded,
      color: const Color(0xFFE67E22),
      gradient: [const Color(0xFFF39C12), const Color(0xFFE67E22)],
    ),
    GameCategory(
      id: 'birds',
      nameEn: 'Birds',
      nameAr: 'طيور',
      icon: Icons.flutter_dash_rounded,
      color: const Color(0xFF5DADE2),
      gradient: [const Color(0xFF85C1E9), const Color(0xFF3498DB)],
    ),
    GameCategory(
      id: 'vehicles',
      nameEn: 'Vehicles',
      nameAr: 'مركبات',
      icon: Icons.directions_car_rounded,
      color: const Color(0xFF34495E),
      gradient: [const Color(0xFF5D6D7E), const Color(0xFF34495E)],
      isLocked: true,
    ),
    GameCategory(
      id: 'music',
      nameEn: 'Music',
      nameAr: 'موسيقى',
      icon: Icons.music_note_rounded,
      color: const Color(0xFFE91E63),
      gradient: [const Color(0xFFF06292), const Color(0xFFE91E63)],
    ),
    GameCategory(
      id: 'science',
      nameEn: 'Science',
      nameAr: 'علوم',
      icon: Icons.science_rounded,
      color: const Color(0xFF00BCD4),
      gradient: [const Color(0xFF4DD0E1), const Color(0xFF0097A7)],
      isLocked: true,
    ),
    GameCategory(
      id: 'body',
      nameEn: 'Human Body',
      nameAr: 'جسم الإنسان',
      icon: Icons.accessibility_new_rounded,
      color: const Color(0xFFE57373),
      gradient: [const Color(0xFFEF9A9A), const Color(0xFFC62828)],
    ),
    GameCategory(
      id: 'vegetables',
      nameEn: 'Vegetables',
      nameAr: 'خضروات',
      icon: Icons.eco_rounded,
      color: const Color(0xFF7CB342),
      gradient: [const Color(0xFF9CCC65), const Color(0xFF558B2F)],
    ),
    GameCategory(
      id: 'space',
      nameEn: 'Space',
      nameAr: 'الفضاء',
      icon: Icons.rocket_launch_rounded,
      color: const Color(0xFF5C6BC0),
      gradient: [const Color(0xFF7986CB), const Color(0xFF283593)],
      isLocked: true,
      unlockCostCoins: 250,
    ),
    GameCategory(
      id: 'school',
      nameEn: 'School',
      nameAr: 'المدرسة',
      icon: Icons.school_rounded,
      color: const Color(0xFFFFB300),
      gradient: [const Color(0xFFFFD54F), const Color(0xFFF57F17)],
      isLocked: true,
    ),
    GameCategory(
      id: 'clothes',
      nameEn: 'Clothes',
      nameAr: 'ملابس',
      icon: Icons.checkroom_rounded,
      color: const Color(0xFFAB47BC),
      gradient: [const Color(0xFFCE93D8), const Color(0xFF6A1B9A)],
      isLocked: true,
    ),
    GameCategory(
      id: 'home',
      nameEn: 'Home',
      nameAr: 'المنزل',
      icon: Icons.home_rounded,
      color: const Color(0xFF8D6E63),
      gradient: [const Color(0xFFA1887F), const Color(0xFF4E342E)],
      isLocked: true,
    ),
    GameCategory(
      id: 'weather',
      nameEn: 'Weather',
      nameAr: 'الطقس',
      icon: Icons.cloud_rounded,
      color: const Color(0xFF29B6F6),
      gradient: [const Color(0xFF4FC3F7), const Color(0xFF0277BD)],
      isLocked: true,
    ),
    GameCategory(
      id: 'insects',
      nameEn: 'Insects',
      nameAr: 'حشرات',
      icon: Icons.bug_report_rounded,
      color: const Color(0xFF66BB6A),
      gradient: [const Color(0xFF81C784), const Color(0xFF2E7D32)],
      isLocked: true,
    ),
  ];

  static GameCategory? byId(String id) {
    try {
      return all.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  static bool hasWords(String categoryId) =>
      WordsRepository.hasCategory(categoryId);
}
