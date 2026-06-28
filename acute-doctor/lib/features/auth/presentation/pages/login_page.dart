import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/app_routes.dart';
import '../../../../core/theme/tokens/tokens.dart';
import '../../../../core/widgets/widgets.dart';
import '../providers/auth_providers.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _phone = TextEditingController();
  String? _localError;

  @override
  void dispose() {
    _phone.dispose();
    super.dispose();
  }

  Future<void> _onSend() async {
    final mobile = _phone.text.trim();
    if (mobile.length != 10) {
      setState(() => _localError = 'Enter a 10-digit mobile number');
      return;
    }
    setState(() => _localError = null);

    final controller = ref.read(authControllerProvider.notifier);
    final ok = await controller.sendOtp(mobile);
    if (!mounted || !ok) return;
    unawaited(context.push('${AppRoutes.otp}?mobile=$mobile'));
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authControllerProvider);
    final errorText = _localError ?? auth.error;

    return Scaffold(
      appBar: AppBar(leading: const BackButton()),
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
              const Text('Sign in to Acutework', style: AppTypography.title),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'We\'ll send a one-time code to verify your number.',
                style: AppTypography.body.copyWith(color: AppColors.muted),
              ),
              const SizedBox(height: AppSpacing.xxxl),
              TextField(
                controller: _phone,
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(10),
                ],
                decoration: InputDecoration(
                  labelText: 'Mobile number',
                  prefixText: '+91  ',
                  errorText: errorText,
                ),
              ),
              const Spacer(),
              AcuteButton(
                label: 'Send code',
                icon: Icons.arrow_forward,
                loading: auth.isSending,
                onPressed: auth.isSending ? null : _onSend,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
