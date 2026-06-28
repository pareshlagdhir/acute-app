import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pinput/pinput.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../../core/theme/tokens/tokens.dart';
import '../../../../core/widgets/widgets.dart';
import '../providers/auth_providers.dart';

class OtpPage extends ConsumerStatefulWidget {
  const OtpPage({required this.mobile, super.key});

  final String mobile;

  @override
  ConsumerState<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends ConsumerState<OtpPage> {
  final _controller = TextEditingController();
  Timer? _ticker;
  int _seconds = AppConstants.otpResendSeconds;

  @override
  void initState() {
    super.initState();
    _startResendTimer();
  }

  void _startResendTimer() {
    _seconds = AppConstants.otpResendSeconds;
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      if (_seconds == 0) {
        t.cancel();
      } else {
        setState(() => _seconds--);
      }
    });
  }

  Future<void> _onCompleted(String otp) async {
    if (otp.length != AppConstants.otpLength) return;
    final ok = await ref.read(authControllerProvider.notifier).verifyOtp(otp);
    if (!mounted) return;
    if (ok) {
      context.go(AppRoutes.profileSetup);
    } else {
      _controller.clear();
    }
  }

  Future<void> _onResend() async {
    final ok = await ref.read(authControllerProvider.notifier).resendOtp();
    if (!mounted || !ok) return;
    _startResendTimer();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Code resent')),
    );
  }

  String get _maskedMobile {
    final m = widget.mobile;
    if (m.length < 4) return m;
    return '+91 ${m.substring(0, 2)}XXX XX${m.substring(m.length - 3)}';
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authControllerProvider);
    final defaultPin = PinTheme(
      width: 52,
      height: 60,
      textStyle: AppTypography.title,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadii.brMd,
        border: Border.all(color: AppColors.hairline),
      ),
    );
    final focusedPin = defaultPin.copyDecorationWith(
      border: Border.all(color: AppColors.primaryTeal, width: 1.5),
      color: AppColors.softTeal.withValues(alpha: 0.4),
    );
    final errorPin = defaultPin.copyDecorationWith(
      border: Border.all(color: AppColors.emergencyRed, width: 1.5),
    );

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
              const Text('Enter the 6-digit code', style: AppTypography.title),
              const SizedBox(height: AppSpacing.sm),
              RichText(
                text: TextSpan(
                  style: AppTypography.body.copyWith(color: AppColors.muted),
                  children: [
                    const TextSpan(text: 'We sent it to '),
                    TextSpan(
                      text: _maskedMobile,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: AppColors.ink,
                      ),
                    ),
                    const TextSpan(
                      text:
                          '. This keeps your account tied to your registered number.',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xxxl),
              Pinput(
                controller: _controller,
                length: AppConstants.otpLength,
                defaultPinTheme: defaultPin,
                focusedPinTheme: focusedPin,
                errorPinTheme: errorPin,
                forceErrorState: auth.error != null,
                onCompleted: _onCompleted,
                onChanged: (_) {
                  if (auth.error != null) {
                    ref.read(authControllerProvider.notifier).clearError();
                  }
                },
              ),
              if (auth.error != null) ...[
                const SizedBox(height: AppSpacing.sm),
                Text(
                  auth.error!,
                  style: AppTypography.body.copyWith(color: AppColors.emergencyRed),
                ),
              ],
              const SizedBox(height: AppSpacing.xl),
              Center(
                child: _seconds > 0
                    ? Text(
                        'Resend code in 00:${_seconds.toString().padLeft(2, '0')}',
                        style: AppTypography.body.copyWith(color: AppColors.muted),
                      )
                    : TextButton(
                        onPressed: auth.isResending ? null : _onResend,
                        child: Text(auth.isResending ? 'Resending…' : 'Resend code'),
                      ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: const BoxDecoration(
                  color: AppColors.surfaceMuted,
                  borderRadius: AppRadii.brMd,
                ),
                child: Row(
                  children: [
                    const Icon(Icons.lock_outline, size: 18, color: AppColors.muted),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        'Your number is verified once. We never share it with responders unless you trigger an alert.',
                        style: AppTypography.body.copyWith(color: AppColors.muted),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              AcuteButton(
                label: 'Verify and continue',
                icon: Icons.arrow_forward,
                loading: auth.isVerifying,
                onPressed: auth.isVerifying
                    ? null
                    : () => _onCompleted(_controller.text),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
