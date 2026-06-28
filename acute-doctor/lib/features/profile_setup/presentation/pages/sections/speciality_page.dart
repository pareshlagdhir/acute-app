import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/theme/tokens/tokens.dart';
import '../../../../../core/widgets/acute_button.dart';
import '../../../../onboarding/data/models/profile_models.dart';
import '../../../../onboarding/presentation/providers/onboarding_providers.dart';
import '../../widgets/catalog_picker.dart';

class SpecialityPage extends ConsumerWidget {
  const SpecialityPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileControllerProvider);

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('Specialities'),
      ),
      body: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(e.toString())),
        data: (profile) => _SpecialityBody(profile: profile),
      ),
    );
  }
}

class _SpecialityBody extends ConsumerStatefulWidget {
  const _SpecialityBody({required this.profile});

  final DoctorProfile profile;

  @override
  ConsumerState<_SpecialityBody> createState() => _SpecialityBodyState();
}

class _SpecialityBodyState extends ConsumerState<_SpecialityBody> {
  bool _saving = false;
  String? _error;

  Future<void> _delete(String id) async {
    setState(() {
      _saving = true;
      _error = null;
    });
    final res = await ref.read(doctorRepositoryProvider).deleteSpeciality(id);
    if (!mounted) return;
    res.fold(
      (f) => setState(() {
        _saving = false;
        _error = f.message;
      }),
      (_) async {
        try {
          await ref.read(profileControllerProvider.notifier).refresh();
          if (mounted) setState(() => _saving = false);
        } on Exception catch (e) {
          if (mounted) {
            setState(() {
              _saving = false;
              _error = 'Failed to refresh: $e';
            });
          }
        }
      },
    );
  }

  Future<void> _add(String name) async {
    setState(() {
      _saving = true;
      _error = null;
    });
    final res = await ref.read(doctorRepositoryProvider).addSpeciality(name);
    if (!mounted) return;
    res.fold(
      (f) => setState(() {
        _saving = false;
        _error = f.message;
      }),
      (_) async {
        try {
          await ref.read(profileControllerProvider.notifier).refresh();
          if (mounted) {
            Navigator.of(context).pop();
            setState(() => _saving = false);
          }
        } on Exception catch (e) {
          if (mounted) {
            setState(() {
              _saving = false;
              _error = 'Failed to refresh: $e';
            });
          }
        }
      },
    );
  }

  Future<void> _openPicker() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: AppRadii.lg),
      ),
      builder: (ctx) => UncontrolledProviderScope(
        container: ProviderScope.containerOf(context),
        child: _SpecialityPicker(onSelected: _add),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xxl,
                vertical: AppSpacing.lg,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.profile.specialities.isEmpty)
                    const Center(child: Text('No specialities added yet.'))
                  else
                    Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.sm,
                      children: widget.profile.specialities.map((s) {
                        return Chip(
                          label: Text(s.name),
                          onDeleted: _saving ? null : () => _delete(s.id),
                        );
                      }).toList(),
                    ),
                  if (_error != null) ...[
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      _error!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.xxl,
              AppSpacing.md,
              AppSpacing.xxl,
              AppSpacing.xxl,
            ),
            child: AcuteButton(
              label: 'Add speciality',
              icon: Icons.add,
              onPressed: _saving ? null : _openPicker,
            ),
          ),
        ],
      ),
    );
  }
}

class _SpecialityPicker extends ConsumerStatefulWidget {
  const _SpecialityPicker({required this.onSelected});

  final ValueChanged<String> onSelected;

  @override
  ConsumerState<_SpecialityPicker> createState() => _SpecialityPickerState();
}

class _SpecialityPickerState extends ConsumerState<_SpecialityPicker> {
  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.xxl,
        AppSpacing.xl,
        AppSpacing.xxl,
        AppSpacing.xxl + bottomPadding,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Add Speciality', style: AppTypography.title),
          const SizedBox(height: AppSpacing.xl),
          CatalogPicker(
            label: 'Speciality',
            search: (q) async {
              final result =
                  await ref.read(doctorRepositoryProvider).searchSpecialities(q);
              return result.getOrElse(() => []);
            },
            onSelected: widget.onSelected,
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(
            'Type a speciality name and tap a suggestion, or press Done to add a custom one.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
