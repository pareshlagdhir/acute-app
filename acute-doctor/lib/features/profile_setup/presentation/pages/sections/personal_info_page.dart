import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/theme/tokens/tokens.dart';
import '../../../../../core/widgets/acute_button.dart';
import '../../../../onboarding/data/models/profile_models.dart';
import '../../../../onboarding/presentation/providers/onboarding_providers.dart';

class PersonalInfoPage extends ConsumerStatefulWidget {
  const PersonalInfoPage({super.key});

  @override
  ConsumerState<PersonalInfoPage> createState() => _PersonalInfoPageState();
}

class _PersonalInfoPageState extends ConsumerState<PersonalInfoPage> {
  final _first = TextEditingController();
  final _middle = TextEditingController();
  final _last = TextEditingController();
  final _email = TextEditingController();

  bool _seeded = false;
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _first.dispose();
    _middle.dispose();
    _last.dispose();
    _email.dispose();
    super.dispose();
  }

  void _seed(DoctorProfile profile) {
    if (_seeded) return;
    _seeded = true;
    _first.text = profile.firstName ?? '';
    _middle.text = profile.middleName ?? '';
    _last.text = profile.lastName ?? '';
    _email.text = profile.email ?? '';
  }

  Future<void> _save() async {
    setState(() {
      _saving = true;
      _error = null;
    });
    final res = await ref.read(doctorRepositoryProvider).updatePersonal(
          firstName: _first.text.trim(),
          middleName: _middle.text.trim().isEmpty ? null : _middle.text.trim(),
          lastName: _last.text.trim(),
          email: _email.text.trim().isEmpty ? null : _email.text.trim(),
        );
    if (!mounted) return;
    res.fold(
      (f) => setState(() {
        _saving = false;
        _error = f.message;
      }),
      (_) async {
        await ref.read(profileControllerProvider.notifier).refresh();
        if (mounted) context.pop();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(profileControllerProvider)
      ..whenData(_seed);

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('Personal Information'),
      ),
      body: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(e.toString())),
        data: (_) => SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.xxl,
              AppSpacing.lg,
              AppSpacing.xxl,
              AppSpacing.xxl,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: _first,
                  decoration: const InputDecoration(labelText: 'First name'),
                ),
                const SizedBox(height: AppSpacing.lg),
                TextField(
                  controller: _middle,
                  decoration: const InputDecoration(labelText: 'Middle name (optional)'),
                ),
                const SizedBox(height: AppSpacing.lg),
                TextField(
                  controller: _last,
                  decoration: const InputDecoration(labelText: 'Last name'),
                ),
                const SizedBox(height: AppSpacing.lg),
                TextField(
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(labelText: 'Email (optional)'),
                ),
                if (_error != null) ...[
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    _error!,
                    style: TextStyle(color: Theme.of(context).colorScheme.error),
                  ),
                ],
                const SizedBox(height: AppSpacing.xl),
                AcuteButton(
                  label: 'Save',
                  loading: _saving,
                  onPressed: _saving ? null : _save,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
