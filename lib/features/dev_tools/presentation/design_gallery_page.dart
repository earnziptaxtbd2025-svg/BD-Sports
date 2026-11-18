import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_badge.dart';
import '../../../core/widgets/app_logo.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/neon_button.dart';
import '../../../core/widgets/neon_stepper.dart';
import '../../../core/widgets/neon_tab_bar.dart';
import '../../../core/widgets/neon_text_field.dart';
import '../../../core/widgets/score_header.dart';
import '../../../core/widgets/stadium_background.dart';
import '../../../core/widgets/stat_bar.dart';

/// Developer tool: every design widget on one screen, to compare with the approved
/// design on a real phone. Removed in the final release.
class DesignGalleryPage extends StatefulWidget {
  const DesignGalleryPage({super.key});

  @override
  State<DesignGalleryPage> createState() => _DesignGalleryPageState();
}

class _DesignGalleryPageState extends State<DesignGalleryPage> {
  /// Brand colours are the same in dark and light. Backgrounds follow the palette.
  List<(String, Color)> _swatches(AppPalette p) => <(String, Color)>[
        ('bgDeep', p.bgDeep),
        ('bgBase', p.bgBase),
        ('surface', p.surface),
        ('accent', p.accent),
        ('neonGreen', AppColors.neonGreen),
        ('electricBlue', AppColors.electricBlue),
        ('teamRed', AppColors.teamRed),
        ('purple', AppColors.purple),
        ('gold', AppColors.gold),
        ('orange', AppColors.orange),
        ('liveRed', AppColors.liveRed),
        ('cyan', AppColors.cyan),
      ];

  static const List<String> _stepLabels = <String>[
    'Basic Info',
    'Rules',
    'Prize & Fee',
    'Location',
    'Preview',
  ];

  int _tab = 0;
  int _step = 2;
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Design gallery')),
      body: StadiumBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.screenH,
              vertical: AppSpacing.lg,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                _section('Logo', const Center(child: AppLogo(showName: true))),
                _section('Colours', _colours()),
                _section('Buttons', _buttons()),
                _section('Tabs', _tabs()),
                _section('Badges', _badges()),
                _section('Input fields', _fields()),
                _section('Stepper', _stepper()),
                _section('Score header: football', _football()),
                _section('Score header: cricket', _cricket()),
                _section('Statistics', _stats()),
                _section(
                  'Glass card',
                  GlassCard(
                    glowColor: AppColors.neonGreen,
                    child: Text(
                      'A glass card with a neon edge.',
                      style: context.appText.body,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _section(String title, Widget child) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: Text(
              title,
              style: context.appText.heading.copyWith(color: context.palette.accent),
            ),
          ),
          child,
        ],
      ),
    );
  }

  Widget _colours() {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: <Widget>[
        for (final (String name, Color color) in _swatches(context.palette))
          Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                width: 56,
                height: 40,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: AppRadius.smAll,
                  border: Border.all(color: context.palette.border),
                ),
              ),
              const SizedBox(height: 2),
              Text(name, style: context.appText.caption.copyWith(fontSize: 10)),
            ],
          ),
      ],
    );
  }

  Widget _buttons() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        NeonButton(
          label: 'Register for This Tournament',
          icon: Icons.groups,
          onPressed: () {},
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: <Widget>[
            Expanded(
              child: NeonButton(
                label: 'Download',
                icon: Icons.download,
                style: NeonButtonStyle.blue,
                onPressed: () {},
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: NeonButton(
                label: 'Share',
                icon: Icons.share,
                style: NeonButtonStyle.purple,
                onPressed: () {},
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        NeonButton(
          label: 'Stop Live',
          icon: Icons.stop,
          style: NeonButtonStyle.red,
          onPressed: () {},
        ),
        const SizedBox(height: AppSpacing.md),
        NeonButton(
          label: 'Submit & Lock Lineup',
          subLabel: '(Before Match Start)',
          icon: Icons.lock,
          onPressed: () {},
        ),
        const SizedBox(height: AppSpacing.md),
        NeonButton(
          label: 'Cancel',
          style: NeonButtonStyle.outline,
          onPressed: () {},
        ),
        const SizedBox(height: AppSpacing.md),
        const NeonButton(label: 'Disabled', onPressed: null),
        const SizedBox(height: AppSpacing.md),
        NeonButton(
          label: _loading ? 'Saving...' : 'Tap to see loading',
          isLoading: _loading,
          onPressed: () async {
            setState(() => _loading = true);
            await Future<void>.delayed(const Duration(seconds: 2));
            if (mounted) {
              setState(() => _loading = false);
            }
          },
        ),
      ],
    );
  }

  Widget _tabs() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        NeonTabBar(
          selectedIndex: _tab,
          onChanged: (int i) => setState(() => _tab = i),
          tabs: const <NeonTab>[
            NeonTab(label: 'Scorecard', icon: Icons.bar_chart),
            NeonTab(label: 'Match Info', icon: Icons.info_outline),
            NeonTab(label: 'Stats', icon: Icons.stacked_bar_chart),
            NeonTab(label: 'Partnership', icon: Icons.handshake_outlined),
          ],
        ),
      ],
    );
  }

  Widget _badges() {
    return const Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: <Widget>[
        AppBadge(label: 'Approved', tone: AppBadgeTone.success, icon: Icons.check),
        AppBadge(label: 'Pending Review', tone: AppBadgeTone.warning),
        AppBadge(label: 'Rejected', tone: AppBadgeTone.danger),
        AppBadge(label: 'Info', tone: AppBadgeTone.info),
        AppBadge(label: 'BAT', tone: AppBadgeTone.blue),
        AppBadge(label: 'ALL', tone: AppBadgeTone.purple),
        AppBadge(label: 'BOWL', tone: AppBadgeTone.orange),
        AppBadge(label: 'Plain'),
      ],
    );
  }

  Widget _fields() {
    return const Column(
      children: <Widget>[
        NeonTextField(
          label: 'Tournament Name',
          hint: 'Enter tournament name...',
          prefixIcon: Icons.emoji_events_outlined,
          isRequired: true,
        ),
        SizedBox(height: AppSpacing.md),
        NeonTextField(
          label: 'Phone Number',
          hint: '01XXXXXXXXX',
          prefixIcon: Icons.phone_android,
          keyboardType: TextInputType.phone,
        ),
        SizedBox(height: AppSpacing.md),
        NeonTextField(
          label: 'Rules',
          hint: 'Enter tournament rules...',
          maxLines: 4,
          maxLength: 1000,
        ),
      ],
    );
  }

  Widget _stepper() {
    return Column(
      children: <Widget>[
        NeonStepper(labels: _stepLabels, currentStep: _step),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: <Widget>[
            Expanded(
              child: NeonButton(
                label: 'Back',
                style: NeonButtonStyle.outline,
                onPressed: _step > 0 ? () => setState(() => _step--) : null,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: NeonButton(
                label: 'Next',
                onPressed: _step < _stepLabels.length - 1
                    ? () => setState(() => _step++)
                    : null,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _football() {
    return const ScoreHeader(
      homeName: 'Rangpur FC',
      awayName: 'Lalmonirhat United',
      score: '1 - 0',
      status: '1st Half • 63:24',
      competition: 'Bangladesh Football Championship 2026',
      isLive: true,
    );
  }

  Widget _cricket() {
    return const ScoreHeader(
      homeName: 'Rangpur Royals',
      awayName: 'Lalmonirhat United',
      score: '180/5',
      status: '(20.0 Over)',
      competition: 'Rangpur Stadium',
    );
  }

  Widget _stats() {
    return const GlassCard(
      child: Column(
        children: <Widget>[
          StatBar(label: 'Possession', homeValue: 58, awayValue: 42, suffix: '%'),
          SizedBox(height: AppSpacing.md),
          StatBar(label: 'Shots on Target', homeValue: 7, awayValue: 3),
          SizedBox(height: AppSpacing.md),
          StatBar(label: 'Corners', homeValue: 5, awayValue: 2),
        ],
      ),
    );
  }
}
