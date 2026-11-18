import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_effects.dart';
import '../theme/app_palette.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

/// One tab of a [NeonTabBar].
class NeonTab {
  const NeonTab({required this.label, this.icon});

  final String label;
  final IconData? icon;
}

/// Row of pill tabs (e.g. Scorecard, Match Info, Stats). The chosen tab is glowing
/// green. If the tabs do not fit the screen the row scrolls sideways.
class NeonTabBar extends StatelessWidget {
  const NeonTabBar({
    super.key,
    required this.tabs,
    required this.selectedIndex,
    required this.onChanged,
  });

  final List<NeonTab> tabs;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenH),
      child: Row(
        children: <Widget>[
          for (int i = 0; i < tabs.length; i++) ...<Widget>[
            if (i > 0) const SizedBox(width: AppSpacing.sm),
            _TabPill(
              tab: tabs[i],
              selected: i == selectedIndex,
              onTap: () => onChanged(i),
            ),
          ],
        ],
      ),
    );
  }
}

class _TabPill extends StatelessWidget {
  const _TabPill({
    required this.tab,
    required this.selected,
    required this.onTap,
  });

  final NeonTab tab;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final AppPalette p = context.palette;
    final IconData? icon = tab.icon;
    final Color fg = selected ? AppColors.textPrimary : p.textSecondary;

    return Semantics(
      button: true,
      selected: selected,
      label: tab.label,
      excludeSemantics: true,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        decoration: BoxDecoration(
          gradient: selected ? AppEffects.buttonGreen : null,
          color: selected ? null : p.surface,
          borderRadius: AppRadius.pillAll,
          border: Border.all(
            color: selected ? AppColors.borderGreen : p.border,
          ),
          boxShadow: selected
              ? AppEffects.glow(AppColors.neonGreen, strength: 0.7 * p.glowStrength)
              : null,
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: onTap,
            borderRadius: AppRadius.pillAll,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: AppSpacing.minTap),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    if (icon != null) ...<Widget>[
                      Icon(icon, size: 20, color: fg),
                      const SizedBox(width: AppSpacing.sm),
                    ],
                    Text(
                      tab.label,
                      style: AppTextStyles.button.copyWith(fontSize: 14, color: fg),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
