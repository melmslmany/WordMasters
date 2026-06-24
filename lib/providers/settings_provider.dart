import 'package:flutter/material.dart';

import '../data/store_data.dart';
import '../services/storage_service.dart';

class SettingsProvider extends ChangeNotifier {
  SettingsProvider(this._storage);

  final StorageService _storage;

  bool musicEnabled = true;
  bool soundsEnabled = true;
  String uiLanguage = 'en';
  int levelsPerCategory = 20;
  String selectedBackgroundId = 'default';
  Set<String> ownedBackgrounds = {'default'};
  String? customBackgroundPath;

  bool get isArabicUi => uiLanguage == 'ar';

  /// The custom-image background descriptor (synthetic, never in the store list).
  static const StoreBackground customBackground = StoreBackground(
    id: StoreData.customId,
    nameEn: 'My Photo',
    nameAr: 'صورتي',
    price: 0,
    colors: [Color(0xFF000000), Color(0xFF101010)],
    isCustom: true,
  );

  StoreBackground? get selectedBackground {
    if (selectedBackgroundId == StoreData.customId) return customBackground;
    return StoreData.byId(selectedBackgroundId) ?? StoreData.backgrounds.first;
  }

  bool get hasCustomBackground =>
      customBackgroundPath != null && customBackgroundPath!.isNotEmpty;

  bool ownsBackground(String id) =>
      ownedBackgrounds.contains(id) ||
      StoreData.byId(id)?.isDefault == true;

  Future<void> load() async {
    musicEnabled = _storage.musicEnabled;
    soundsEnabled = _storage.soundsEnabled;
    uiLanguage = _storage.uiLanguage;
    levelsPerCategory = _storage.levelsPerCategory;
    selectedBackgroundId = _storage.selectedBackgroundId;
    ownedBackgrounds = _storage.getOwnedBackgrounds();
    customBackgroundPath = _storage.customBackgroundPath;
    notifyListeners();
  }

  Future<void> setMusic(bool value) async {
    musicEnabled = value;
    await _storage.setMusicEnabled(value);
    notifyListeners();
  }

  Future<void> setSounds(bool value) async {
    soundsEnabled = value;
    await _storage.setSoundsEnabled(value);
    notifyListeners();
  }

  Future<void> setUiLanguage(String code) async {
    uiLanguage = code;
    await _storage.setUiLanguage(code);
    notifyListeners();
  }

  Future<void> setLevelsPerCategory(int count) async {
    levelsPerCategory = count;
    await _storage.setLevelsPerCategory(count);
    notifyListeners();
  }

  Future<void> selectBackground(String id) async {
    if (!ownsBackground(id)) return;
    selectedBackgroundId = id;
    await _storage.setSelectedBackground(id);
    notifyListeners();
  }

  Future<void> purchaseBackground(String id) async {
    ownedBackgrounds.add(id);
    selectedBackgroundId = id;
    await _storage.ownBackground(id);
    await _storage.setSelectedBackground(id);
    notifyListeners();
  }

  Future<void> setCustomBackground(String path) async {
    customBackgroundPath = path;
    selectedBackgroundId = StoreData.customId;
    await _storage.setCustomBackgroundPath(path);
    await _storage.setSelectedBackground(StoreData.customId);
    notifyListeners();
  }

  Future<void> selectCustomBackground() async {
    if (!hasCustomBackground) return;
    selectedBackgroundId = StoreData.customId;
    await _storage.setSelectedBackground(StoreData.customId);
    notifyListeners();
  }
}
