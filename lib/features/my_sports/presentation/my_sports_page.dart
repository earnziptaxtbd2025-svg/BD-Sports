import 'package:flutter/material.dart';

import '../../../core/widgets/placeholder_page.dart';

class MySportsPage extends StatelessWidget {
  const MySportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderPage(
      title: 'My Sports',
      icon: Icons.emoji_events_outlined,
      description: 'Your tournaments, matches and teams. Built in Step 1.7.',
    );
  }
}
