import 'package:flutter/material.dart';

import '../../../core/navigation/screen_spec.dart';
import '../../navigation/presentation/hub_page.dart';

class ExplorePage extends StatelessWidget {
  const ExplorePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const HubPage(
      title: 'Explore',
      hub: HubTab.explore,
      intro: 'Find tournaments, teams, players, coaches and grounds.',
    );
  }
}
