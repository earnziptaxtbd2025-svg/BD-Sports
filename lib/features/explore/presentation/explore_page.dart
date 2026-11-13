import 'package:flutter/material.dart';

import '../../../core/widgets/placeholder_page.dart';

class ExplorePage extends StatelessWidget {
  const ExplorePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderPage(
      title: 'Explore',
      icon: Icons.search,
      description: 'Search tournaments, teams, players and coaches. Built in Step 1.6.',
    );
  }
}
