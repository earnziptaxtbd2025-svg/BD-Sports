import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_effects.dart';
import '../theme/app_palette.dart';
import '../theme/app_text_styles.dart';

/// One item of a [NeonBottomNav].
class NeonNavItem {
  const NeonNavItem({required this.label, required this.icon, this.selectedIcon});

  final String label;
  final IconData icon;

  /// Icon when chosen. If empty, [icon] is used.
  final IconData? selectedIcon;
}

/// Bottom navigation of the design. One item ([centerIndex]) can be a big raised
/// glowing round button (the "Create" button).
class NeonBottomNav extends StatelessWidget {
  const NeonBottomNav({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onChanged,
    this.centerIndex,
  });

  final List<NeonNavItem> items;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  /// Index of the raised item. Empty means all items are flat.
  final int? centerIndex;

  static const double _barHeight = 64;
  static const double _raise = 20;
  static const double _bigButton = 56;

  @override
  Widget build(BuildContext context) {
    final AppPalette p = context.palette;
    final double bottomInset = MediaQuery.of(context).viewPadding.bottom;
    final bool hasRaised = centerIndex != null;
    final double total = _barHeight + (hasRaised ? _raise : 0);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        SizedBox(
          height: total,
          child: Stack(
            children: <Widget>[
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                height: _barHeight,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: p.bgDeep,
                    border: Border(top: BorderSide(color: p.border)),
                  ),
                ),
              ),
              Positioned.fill(
                child: Row(
                  children: <Widget>[
                    for (int i = 0; i < items.length; i++)
                      Expanded(
                        child: _NavCell(
                          item: items[i],
                          selected: i == selectedIndex,
                          raised: i == centerIndex,
                          onTap: () => onChanged(i),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Container(height: bottomInset, color: p.bgDeep),
      ],
    );
  }
}

class _NavCell extends StatelessWidget {
  const _NavCell({
    required this.item,
    required this.selected,
    required this.raised,
    required this.onTap,
  });

  final NeonNavItem item;
  final bool selected;
  final bool raised;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final AppPalette p = context.palette;
    final Color color = selected ? p.accent : p.textSecondary;
    final IconData icon = selected ? (item.selectedIcon ?? item.icon) : item.icon;

    final Widget iconWidget = raised
        ? Container(
            width: NeonBottomNav._bigButton,
            height: NeonBottomNav._bigButton,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppEffects.buttonGreen,
              border: Border.all(color: AppColors.borderGreen),
              boxShadow: AppEffects.glow(AppColors.neonGreen, strength: p.glowStrength),
            ),
            child: Icon(icon, size: 30, color: AppColors.textPrimary),
          )
        : Icon(icon, size: 26, color: color);

    return Semantics(
      button: true,
      selected: selected,
      label: item.label,
      excludeSemantics: true,
      onTap: onTap,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              iconWidget,
              const SizedBox(height: 2),
              Text(
                item.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.caption.copyWith(
                  fontSize: 12,
                  height: 1.2,
                  color: color,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
