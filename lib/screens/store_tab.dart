import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../core/constants/app_colors.dart';
import '../data/store_data.dart';
import '../l10n/app_localizations.dart';
import '../providers/ads_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/game_provider.dart';
import '../providers/progression_provider.dart';
import '../providers/settings_provider.dart';
import '../widgets/background_painter.dart';
import '../widgets/common_widgets.dart';

class StoreTab extends StatelessWidget {
  const StoreTab({
    super.key,
    required this.l10n,
    required this.game,
    required this.settings,
    required this.progression,
    required this.auth,
  });

  final AppLocalizations l10n;
  final GameProvider game;
  final SettingsProvider settings;
  final ProgressionProvider progression;
  final AuthProvider auth;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        NeonHeader(
          leading: const SizedBox(width: 48),
          title: l10n.store,
          subtitle: l10n.storeDesc,
          badge: 'STORE',
          trailing: CurrencyDisplay(keys: game.keys, coins: game.coins),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _SectionTitle(l10n.backgrounds),
              const SizedBox(height: 8),
              _CustomImageCard(
                l10n: l10n,
                settings: settings,
                selected: settings.selectedBackgroundId == StoreData.customId,
                onPick: () => _pickCustomImage(context, settings),
                onApply: () => settings.selectCustomBackground(),
              ),
              for (final bg in StoreData.backgrounds)
                _BackgroundCard(
                  background: bg,
                  l10n: l10n,
                  owned: settings.ownsBackground(bg.id),
                  selected: settings.selectedBackgroundId == bg.id,
                  canAfford: game.coins >= bg.price,
                  onBuy: () => _buyBackground(context, bg),
                  onSelect: () => settings.selectBackground(bg.id),
                ),
              const SizedBox(height: 20),
              _SectionTitle(l10n.coinPacks),
              const SizedBox(height: 8),
              for (final pack in StoreData.coinPacks)
                _CoinPackCard(
                  pack: pack,
                  l10n: l10n,
                  onBuy: () => _buyCoinPack(context, pack),
                ),
              const SizedBox(height: 20),
              _SectionTitle(l10n.adsSection),
              const SizedBox(height: 8),
              _AdsSection(l10n: l10n, game: game, auth: auth),
              const SizedBox(height: 20),
              _CloudSaveCard(l10n: l10n, auth: auth),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _buyBackground(BuildContext context, StoreBackground bg) async {
    if (settings.ownsBackground(bg.id)) {
      await settings.selectBackground(bg.id);
      return;
    }
    if (game.coins < bg.price) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.notEnoughCoins)),
        );
      }
      return;
    }

    final ok = await game.spendCoins(bg.price);
    if (!ok) return;

    await settings.purchaseBackground(bg.id);
    await progression.onBackgroundPurchased();
    await auth.syncToCloud();

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${l10n.purchased}: ${bg.name(l10n.isArabic)}')),
      );
    }
  }

  Future<void> _buyCoinPack(BuildContext context, CoinPack pack) async {
    final total = pack.coins + pack.bonus;
    await game.addCoins(total);
    await auth.syncToCloud();
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('+$total 🪙')),
      );
    }
  }

  Future<void> _pickCustomImage(
    BuildContext context,
    SettingsProvider settings,
  ) async {
    try {
      final picker = ImagePicker();
      final file = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1600,
        imageQuality: 85,
      );
      if (file == null) return;
      await settings.setCustomBackground(file.path);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.backgroundApplied)),
        );
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.imagePickFailed)),
        );
      }
    }
  }
}

class _CustomImageCard extends StatelessWidget {
  const _CustomImageCard({
    required this.l10n,
    required this.settings,
    required this.selected,
    required this.onPick,
    required this.onApply,
  });

  final AppLocalizations l10n;
  final SettingsProvider settings;
  final bool selected;
  final VoidCallback onPick;
  final VoidCallback onApply;

  @override
  Widget build(BuildContext context) {
    final has = settings.hasCustomBackground;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.neonPurple.withValues(alpha: 0.18),
            AppColors.surface.withValues(alpha: 0.85),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: selected
              ? AppColors.neonCyan.withValues(alpha: 0.6)
              : AppColors.neonPurple.withValues(alpha: 0.35),
        ),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              width: 56,
              height: 56,
              child: has
                  ? (kIsWeb
                      ? Image.network(settings.customBackgroundPath!,
                          fit: BoxFit.cover)
                      : Image.file(File(settings.customBackgroundPath!),
                          fit: BoxFit.cover))
                  : Container(
                      color: AppColors.surfaceLight,
                      child: const Icon(Icons.add_photo_alternate_rounded,
                          color: AppColors.neonCyan),
                    ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.customBackground,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  has ? (selected ? l10n.active : l10n.owned) : l10n.chooseImage,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (has && !selected)
            _StoreActionButton(
              label: l10n.apply,
              color: AppColors.neonCyan,
              onTap: onApply,
            ),
          if (has && !selected) const SizedBox(width: 6),
          _StoreActionButton(
            label: l10n.chooseImage,
            color: AppColors.neonPurple,
            onTap: onPick,
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 16,
        fontWeight: FontWeight.w800,
      ),
    );
  }
}

class _BackgroundCard extends StatelessWidget {
  const _BackgroundCard({
    required this.background,
    required this.l10n,
    required this.owned,
    required this.selected,
    required this.canAfford,
    required this.onBuy,
    required this.onSelect,
  });

  final StoreBackground background;
  final AppLocalizations l10n;
  final bool owned;
  final bool selected;
  final bool canAfford;
  final VoidCallback onBuy;
  final VoidCallback onSelect;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: selected
              ? AppColors.neonCyan.withValues(alpha: 0.6)
              : Colors.white12,
        ),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              width: 56,
              height: 56,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: background.colors,
                  ),
                ),
                child: CustomPaint(
                  painter: BackgroundPatternPainter(
                    pattern: background.pattern,
                    accent: background.accent,
                  ),
                  size: const Size(56, 56),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  background.name(l10n.isArabic),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  owned
                      ? (selected ? l10n.active : l10n.owned)
                      : '${background.price} 🪙',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          _StoreActionButton(
            label: owned ? (selected ? '✓' : l10n.apply) : l10n.buy,
            color: owned ? AppColors.neonCyan : AppColors.neonGreen,
            enabled: owned || canAfford,
            onTap: owned ? onSelect : onBuy,
          ),
        ],
      ),
    );
  }
}

class _CoinPackCard extends StatelessWidget {
  const _CoinPackCard({
    required this.pack,
    required this.l10n,
    required this.onBuy,
  });

  final CoinPack pack;
  final AppLocalizations l10n;
  final VoidCallback onBuy;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.accentGold.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.monetization_on_rounded,
            color: AppColors.accentGold,
            size: 32,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${pack.coins}${pack.bonus > 0 ? ' +${pack.bonus}' : ''} 🪙',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  pack.priceLabel,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          _StoreActionButton(
            label: l10n.buy,
            color: AppColors.accentGold,
            onTap: onBuy,
          ),
        ],
      ),
    );
  }
}

class _StoreActionButton extends StatelessWidget {
  const _StoreActionButton({
    required this.label,
    required this.color,
    required this.onTap,
    this.enabled = true,
  });

  final String label;
  final Color color;
  final VoidCallback onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: enabled ? color : Colors.grey.shade800,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Text(
            label,
            style: TextStyle(
              color: enabled ? Colors.white : Colors.white54,
              fontWeight: FontWeight.w800,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }
}

class _AdsSection extends StatelessWidget {
  const _AdsSection({
    required this.l10n,
    required this.game,
    required this.auth,
  });

  final AppLocalizations l10n;
  final GameProvider game;
  final AuthProvider auth;

  static const int removeAdsCost = 3000;
  static const int rewardedCoins = 50;

  @override
  Widget build(BuildContext context) {
    final ads = context.watch<AdsProvider>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Remove ads
        Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surface.withValues(alpha: 0.85),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.neonPink.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              const Icon(Icons.block_rounded,
                  color: AppColors.neonPink, size: 30),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.removeAds,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      ads.removeAds
                          ? l10n.adsRemoved
                          : '$removeAdsCost 🪙',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              if (ads.removeAds)
                const Icon(Icons.check_circle_rounded,
                    color: AppColors.neonGreen, size: 28)
              else
                _StoreActionButton(
                  label: l10n.buy,
                  color: AppColors.neonPink,
                  enabled: game.coins >= removeAdsCost,
                  onTap: () => _buyRemoveAds(context, ads),
                ),
            ],
          ),
        ),
        // Rewarded ad for free coins
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.neonGreen.withValues(alpha: 0.18),
                AppColors.surface.withValues(alpha: 0.85),
              ],
            ),
            borderRadius: BorderRadius.circular(14),
            border:
                Border.all(color: AppColors.neonGreen.withValues(alpha: 0.4)),
          ),
          child: Row(
            children: [
              const Icon(Icons.ondemand_video_rounded,
                  color: AppColors.neonGreen, size: 30),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.watchAdForCoins,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      '+$rewardedCoins 🪙',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              _StoreActionButton(
                label: l10n.watch,
                color: AppColors.neonGreen,
                onTap: () => _watchRewarded(context, ads),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _buyRemoveAds(BuildContext context, AdsProvider ads) async {
    if (game.coins < removeAdsCost) return;
    final ok = await game.spendCoins(removeAdsCost);
    if (!ok) return;
    await ads.setRemoveAds(true);
    await auth.syncToCloud();
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.adsRemoved)),
      );
    }
  }

  Future<void> _watchRewarded(BuildContext context, AdsProvider ads) async {
    if (!ads.rewardedReady) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.adNotReady)),
        );
      }
      return;
    }
    final earned = await ads.showRewarded();
    if (earned) {
      await game.addCoins(rewardedCoins);
      await auth.syncToCloud();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('+$rewardedCoins 🪙')),
        );
      }
    }
  }
}

class _CloudSaveCard extends StatelessWidget {
  const _CloudSaveCard({required this.l10n, required this.auth});

  final AppLocalizations l10n;
  final AuthProvider auth;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.neonBlue.withValues(alpha: 0.2),
            AppColors.surface.withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.neonBlue.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(Icons.cloud_done_rounded, color: AppColors.neonCyan),
              const SizedBox(width: 8),
              Text(
                l10n.cloudSave,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            auth.isSignedIn
                ? '${l10n.synced}: ${auth.displayLabel}'
                : l10n.cloudSaveDesc,
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
          ),
          const SizedBox(height: 12),
          GameButton(
            label: l10n.syncNow,
            onTap: () async {
              await auth.syncToCloud();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.syncComplete)),
                );
              }
            },
            color: AppColors.neonBlue,
          ),
          const SizedBox(height: 8),
          GameButton(
            label: l10n.googleSignIn,
            icon: Icons.login_rounded,
            onTap: () async {
              await auth.signInWithGoogle();
              if (context.mounted) {
                await context.read<GameProvider>().load();
                await context.read<SettingsProvider>().load();
                await context.read<ProgressionProvider>().load();
              }
            },
            color: AppColors.neonPurple,
          ),
        ],
      ),
    );
  }
}
