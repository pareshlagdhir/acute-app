import 'package:flutter/material.dart';

import '../../../../core/theme/tokens/tokens.dart';
import '../../../../core/widgets/widgets.dart';

class AlertsPage extends StatelessWidget {
  const AlertsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Alerts')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        children: const [
          AcuteBadge(label: 'Active alert', variant: AcuteBadgeVariant.activeAlert),
          SizedBox(height: AppSpacing.lg),
          Text('No alerts yet', style: AppTypography.title),
        ],
      ),
    );
  }
}
