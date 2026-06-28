import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/app_routes.dart';
import '../../../../core/theme/tokens/tokens.dart';
import '../../../../core/widgets/widgets.dart';

enum DoctorRole { doctor, clinicOwner, hospitalAdmin, hospitalStaff }

class ProfileSetupPage extends StatefulWidget {
  const ProfileSetupPage({super.key});

  @override
  State<ProfileSetupPage> createState() => _ProfileSetupPageState();
}

class _ProfileSetupPageState extends State<ProfileSetupPage> {
  DoctorRole _selected = DoctorRole.doctor;
  static const _stepTotal = 4;
  static const _stepIndex = 2;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: Row(
            children: List.generate(_stepTotal, (i) {
              final active = i < _stepIndex;
              return Expanded(
                child: Container(
                  height: 3,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  color: active ? AppColors.primaryTeal : AppColors.hairline,
                ),
              );
            }),
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xxl,
            AppSpacing.lg,
            AppSpacing.xxl,
            AppSpacing.xxl,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'STEP $_stepIndex OF $_stepTotal',
                style: AppTypography.caption.copyWith(color: AppColors.muted),
              ),
              const SizedBox(height: AppSpacing.sm),
              const Text('What best describes your role?', style: AppTypography.title),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'We tailor responder priority and group access based on this.',
                style: AppTypography.body.copyWith(color: AppColors.muted),
              ),
              const SizedBox(height: AppSpacing.xl),
              Expanded(
                child: ListView.separated(
                  itemCount: _options.length,
                  separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
                  itemBuilder: (_, i) {
                    final opt = _options[i];
                    return AcuteSelectableCard(
                      title: opt.title,
                      subtitle: opt.subtitle,
                      icon: opt.icon,
                      selected: _selected == opt.role,
                      onTap: () => setState(() => _selected = opt.role),
                    );
                  },
                ),
              ),
              AcuteButton(
                label: 'Continue',
                icon: Icons.arrow_forward,
                onPressed: () => context.go(AppRoutes.home),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static const _options = <_RoleOption>[
    _RoleOption(DoctorRole.doctor, 'Doctor', 'Practising physician', Icons.medical_services_outlined),
    _RoleOption(DoctorRole.clinicOwner, 'Clinic owner', 'Solo or partner', Icons.work_outline),
    _RoleOption(DoctorRole.hospitalAdmin, 'Hospital admin', 'Mgmt / operations', Icons.apartment_outlined),
    _RoleOption(DoctorRole.hospitalStaff, 'Hospital staff', 'Nursing, OT, ER', Icons.favorite_outline),
  ];
}

class _RoleOption {
  const _RoleOption(this.role, this.title, this.subtitle, this.icon);
  final DoctorRole role;
  final String title;
  final String subtitle;
  final IconData icon;
}
