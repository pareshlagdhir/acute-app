import 'package:flutter/material.dart';

import '../../../../core/theme/tokens/tokens.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: const Padding(
        padding: EdgeInsets.all(AppSpacing.xxl),
        child: Text('Profile & settings', style: AppTypography.title),
      ),
    );
  }
}
