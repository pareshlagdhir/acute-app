import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/errors/failures.dart';
import '../../../../../core/theme/tokens/tokens.dart';
import '../../../../../core/widgets/acute_button.dart';
import '../../../../onboarding/data/models/profile_models.dart';
import '../../../../onboarding/presentation/providers/onboarding_providers.dart';
import '../../widgets/hospital_search_field.dart';

class ExperiencePage extends ConsumerWidget {
  const ExperiencePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileControllerProvider);

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('Experience'),
      ),
      body: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(e.toString())),
        data: (profile) => _ExperienceBody(profile: profile),
      ),
    );
  }
}

class _ExperienceBody extends ConsumerWidget {
  const _ExperienceBody({required this.profile});

  final DoctorProfile profile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SafeArea(
      child: Column(
        children: [
          Expanded(
            child: profile.experiences.isEmpty
                ? const Center(child: Text('No experience entries yet.'))
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xxl,
                      vertical: AppSpacing.lg,
                    ),
                    itemCount: profile.experiences.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: AppSpacing.md),
                    itemBuilder: (context, index) {
                      final exp = profile.experiences[index];
                      return _ExperienceCard(experience: exp);
                    },
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
              label: 'Add experience',
              icon: Icons.add,
              onPressed: () => _openForm(context, null),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openForm(BuildContext context, Experience? experience) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: AppRadii.lg),
      ),
      builder: (ctx) => UncontrolledProviderScope(
        container: ProviderScope.containerOf(context),
        child: _ExperienceForm(experience: experience),
      ),
    );
  }
}

class _ExperienceCard extends ConsumerStatefulWidget {
  const _ExperienceCard({required this.experience});

  final Experience experience;

  @override
  ConsumerState<_ExperienceCard> createState() => _ExperienceCardState();
}

class _ExperienceCardState extends ConsumerState<_ExperienceCard> {
  @override
  Widget build(BuildContext context) {
    final exp = widget.experience;
    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        title: Row(
          children: [
            Expanded(child: Text(exp.hospital.name)),
            if (exp.isCurrent)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xxs,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: AppRadii.brPill,
                ),
                child: Text(
                  'Current',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                ),
              ),
          ],
        ),
        subtitle: exp.designation != null ? Text(exp.designation!) : null,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              tooltip: 'Edit',
              onPressed: () => _openEdit(context),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: 'Delete',
              color: Theme.of(context).colorScheme.error,
              onPressed: () => _confirmDelete(context),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openEdit(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: AppRadii.lg),
      ),
      builder: (ctx) => UncontrolledProviderScope(
        container: ProviderScope.containerOf(context),
        child: _ExperienceForm(experience: widget.experience),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete experience'),
        content: const Text(
          'Are you sure you want to remove this experience entry?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    if (!mounted) return;
    final res = await ref
        .read(doctorRepositoryProvider)
        .deleteExperience(widget.experience.id);
    if (!mounted) return;
    final failure = res.fold<Failure?>((f) => f, (_) => null);
    if (failure != null) {
      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text(failure.message)),
      );
      return;
    }
    await ref.read(profileControllerProvider.notifier).refresh();
  }
}

class _ExperienceForm extends ConsumerStatefulWidget {
  const _ExperienceForm({this.experience});

  final Experience? experience;

  @override
  ConsumerState<_ExperienceForm> createState() => _ExperienceFormState();
}

class _ExperienceFormState extends ConsumerState<_ExperienceForm> {
  final _designationController = TextEditingController();

  String _formatDate(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';

  Hospital? _selectedHospital;
  String? _startDate;
  String? _endDate;
  bool _isCurrent = false;
  bool _saving = false;
  String? _error;

  bool get _isEdit => widget.experience != null;

  @override
  void initState() {
    super.initState();
    if (_isEdit) {
      final exp = widget.experience!;
      _selectedHospital = exp.hospital;
      _designationController.text = exp.designation ?? '';
      _startDate = exp.startDate;
      _endDate = exp.endDate;
      _isCurrent = exp.isCurrent;
    }
  }

  @override
  void dispose() {
    _designationController.dispose();
    super.dispose();
  }

  Future<void> _pickDate({required bool isStart}) async {
    final now = DateTime.now();
    final initial = isStart
        ? (_startDate != null ? DateTime.parse(_startDate!) : now)
        : (_endDate != null ? DateTime.parse(_endDate!) : now);

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1970),
      lastDate: now,
    );
    if (picked == null) return;
    final formatted = _formatDate(picked);
    setState(() {
      if (isStart) {
        _startDate = formatted;
      } else {
        _endDate = formatted;
      }
    });
  }

  Future<void> _save() async {
    if (_selectedHospital == null) {
      setState(() => _error = 'Please select or add a hospital/clinic.');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });

    final designation = _designationController.text.trim().isEmpty
        ? null
        : _designationController.text.trim();

    if (_isEdit) {
      final changes = <String, dynamic>{
        'hospital_id': _selectedHospital!.id,
        if (designation != null) 'designation': designation,
        if (_startDate != null) 'start_date': _startDate,
        if (_endDate != null) 'end_date': _endDate,
        'is_current': _isCurrent,
      };
      final res = await ref
          .read(doctorRepositoryProvider)
          .updateExperience(widget.experience!.id, changes);
      if (!mounted) return;
      final failure = res.fold<Failure?>((f) => f, (_) => null);
      if (failure != null) {
        setState(() {
          _saving = false;
          _error = failure.message;
        });
        return;
      }
      Navigator.of(context).pop();
      await ref.read(profileControllerProvider.notifier).refresh();
      if (mounted) setState(() => _saving = false);
    } else {
      final res = await ref.read(doctorRepositoryProvider).addExperience(
            hospitalId: _selectedHospital!.id,
            designation: designation,
            startDate: _startDate,
            endDate: _endDate,
            isCurrent: _isCurrent,
          );
      if (!mounted) return;
      final failure = res.fold<Failure?>((f) => f, (_) => null);
      if (failure != null) {
        setState(() {
          _saving = false;
          _error = failure.message;
        });
        return;
      }
      Navigator.of(context).pop();
      await ref.read(profileControllerProvider.notifier).refresh();
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;
    final repo = ref.read(doctorRepositoryProvider);

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
          Text(
            _isEdit ? 'Edit Experience' : 'Add Experience',
            style: AppTypography.title,
          ),
          const SizedBox(height: AppSpacing.xl),
          HospitalSearchField(
            initialHospital: _selectedHospital,
            search: (q) async {
              final result = await repo.searchHospitals(q);
              return result.getOrElse(() => []);
            },
            onCreate: (name, type) async {
              final result =
                  await repo.createHospital(name: name, type: type);
              return result.fold(
                (f) => throw Exception(f.message),
                (h) => h,
              );
            },
            onSelected: (hospital) => setState(() {
              _selectedHospital = hospital;
            }),
          ),
          const SizedBox(height: AppSpacing.lg),
          TextField(
            controller: _designationController,
            decoration: const InputDecoration(
              labelText: 'Designation (optional)',
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.calendar_today_outlined, size: 16),
                  label: Text(
                    _startDate ?? 'Start date',
                    overflow: TextOverflow.ellipsis,
                  ),
                  onPressed: () => _pickDate(isStart: true),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.calendar_today_outlined, size: 16),
                  label: Text(
                    _isCurrent
                        ? 'Present'
                        : (_endDate ?? 'End date'),
                    overflow: TextOverflow.ellipsis,
                  ),
                  onPressed: _isCurrent ? null : () => _pickDate(isStart: false),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Currently working here'),
            value: _isCurrent,
            onChanged: (value) => setState(() {
              _isCurrent = value;
              if (value) _endDate = null;
            }),
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
            label: _isEdit ? 'Update' : 'Save',
            loading: _saving,
            onPressed: _saving ? null : _save,
          ),
        ],
      ),
    );
  }
}
