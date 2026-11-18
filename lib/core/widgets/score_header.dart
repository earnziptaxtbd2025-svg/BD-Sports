import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_palette.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import 'glass_card.dart';
import 'live_badge.dart';
import 'team_crest.dart';

/// Match header: two teams and the score in the middle. Used by football and cricket.
///
/// - [score]: "1 - 0" for football, "180/5" for cricket.
/// - [status]: line under the score, e.g. "1st Half 63:24" or "(20.0 Over)".
/// - [homeLogo]/[awayLogo]: team logo. If empty, a [TeamCrest] with letters is shown.
class ScoreHeader extends StatelessWidget {
  const ScoreHeader({
    super.key,
    required this.homeName,
    required this.awayName,
    required this.score,
    this.status,
    this.competition,
    this.isLive = false,
    this.liveLabel = 'LIVE',
    this.homeLogo,
    this.awayLogo,
  });

  final String homeName;
  final String awayName;
  final String score;
  final String? status;
  final String? competition;
  final bool isLive;
  final String liveLabel;
  final Widget? homeLogo;
  final Widget? awayLogo;

  @override
  Widget build(BuildContext context) {
    final AppPalette p = context.palette;
    final AppText t = context.appText;
    final String? statusText = status;
    final String? competitionText = competition;

    final String spoken = <String>[
      if (isLive) liveLabel,
      homeName,
      score,
      awayName,
      if (statusText != null) statusText,
    ].join(', ');

    return Semantics(
      container: true,
      label: spoken,
      child: ExcludeSemantics(
        child: GlassCard(
          glowColor: isLive ? AppColors.liveRed : null,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              if (competitionText != null) ...<Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(Icons.emoji_events, size: 16, color: p.goldText),
                    const SizedBox(width: AppSpacing.xs + 2),
                    Flexible(
                      child: Text(
                        competitionText,
                        style: t.caption,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
              ],
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    flex: 3,
                    child: _Team(
                      name: homeName,
                      logo: homeLogo ??
                          TeamCrest(name: homeName, color: AppColors.teamBlue),
                    ),
                  ),
                  Expanded(
                    flex: 4,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        if (isLive) ...<Widget>[
                          LiveBadge(label: liveLabel),
                          const SizedBox(height: AppSpacing.sm),
                        ],
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(score, style: t.score),
                        ),
                        if (statusText != null) ...<Widget>[
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            statusText,
                            style: t.caption,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: _Team(
                      name: awayName,
                      logo: awayLogo ??
                          TeamCrest(name: awayName, color: AppColors.teamRed),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Team extends StatelessWidget {
  const _Team({required this.name, required this.logo});

  final String name;
  final Widget logo;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        logo,
        const SizedBox(height: AppSpacing.sm),
        Text(
          name,
          style: context.appText.heading.copyWith(fontSize: 15),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
