import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/theme/tokens/tokens.dart';
import '../../../../../core/widgets/acute_button.dart';
import '../../../../onboarding/data/models/profile_models.dart';
import '../../../../onboarding/presentation/providers/onboarding_providers.dart';
import '../../widgets/catalog_picker.dart';

class EducationPage extends ConsumerWidget {
  const EducationPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileControllerProvider);

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('Education'),
      ),
      body: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(e.toString())),
        data: (profile) => _EducationBody(profile: profile),
      ),
    );
  }
}

class _EducationBody extends ConsumerWidget {
  const _EducationBody({required this.profile});

  final DoctorProfile profile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SafeArea(
      child: Column(
        children: [
          Expanded(
            child: profile.educations.isEmpty
                ? const Center(child: Text('No education entries yet.'))
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xxl,
                      vertical: AppSpacing.lg,
                    ),
                    itemCount: profile.educations.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: AppSpacing.md),
                    itemBuilder: (context, index) {
                      final edu = profile.educations[index];
                      return _EducationCard(education: edu);
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
              label: 'Add education',
              icon: Icons.add,
              onPressed: () => _openForm(context, null),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openForm(BuildContext context, Education? education) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: AppRadii.lg),
      ),
      builder: (ctx) => UncontrolledProviderScope(
        container: ProviderScope.containerOf(context),
        child: _EducationForm(education: education),
      ),
    );
  }
}

class _EducationCard extends ConsumerStatefulWidget {
  const _EducationCard({required this.education});

  final Education education;

  @override
  ConsumerState<_EducationCard> createState() => _EducationCardState();
}

class _EducationCardState extends ConsumerState<_EducationCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        title: Text(widget.education.degree),
        subtitle: Text('Reg. no: ${widget.education.registrationNumber}'),
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
        child: _EducationForm(education: widget.education),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete education'),
        content: const Text(
          'Are you sure you want to remove this education entry?',
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
    await ref.read(doctorRepositoryProvider).deleteEducation(widget.education.id);
    if (!mounted) return;
    await ref.read(profileControllerProvider.notifier).refresh();
  }
}

class _EducationForm extends ConsumerStatefulWidget {
  const _EducationForm({this.education});

  final Education? education;

  @override
  ConsumerState<_EducationForm> createState() => _EducationFormState();
}

class _EducationFormState extends ConsumerState<_EducationForm> {
  final _regNumberController = TextEditingController();
  final _institutionController = TextEditingController();
  final _yearController = TextEditingController();

  String _degree = '';
  bool _saving = false;
  String? _error;

  bool get _isEdit => widget.education != null;

  @override
  void initState() {
    super.initState();
    if (_isEdit) {
      _degree = widget.education!.degree;
      _regNumberController.text = widget.education!.registrationNumber;
      _institutionController.text = widget.education!.institution ?? '';
      _yearController.text = widget.education!.yearOfCompletion != null
          ? widget.education!.yearOfCompletion.toString()
          : '';
    }
  }

  @override
  void dispose() {
    _regNumberController.dispose();
    _institutionController.dispose();
    _yearController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final regNumber = _regNumberController.text.trim();
    if (_degree.isEmpty) {
      setState(() => _error = 'Please select or enter a degree.');
      return;
    }
    if (regNumber.isEmpty) {
      setState(() => _error = 'Registration number is required.');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });

    final institution = _institutionController.text.trim().isEmpty
        ? null
        : _institutionController.text.trim();
    final yearText = _yearController.text.trim();
    final year = yearText.isNotEmpty ? int.tryParse(yearText) : null;

    if (_isEdit) {
      final changes = <String, dynamic>{
        'degree': _degree,
        'registration_number': regNumber,
        if (institution != null) 'institution': institution,
        if (year != null) 'year_of_completion': year,
      };
      final res = await ref
          .read(doctorRepositoryProvider)
          .updateEducation(widget.education!.id, changes);
      if (!mounted) return;
      res.fold(
        (f) => setState(() {
          _saving = false;
          _error = f.message;
        }),
        (_) async {
          try {
            await ref.read(profileControllerProvider.notifier).refresh();
            if (mounted) Navigator.of(context).pop();
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
    } else {
      final res = await ref.read(doctorRepositoryProvider).addEducation(
            degree: _degree,
            registrationNumber: regNumber,
            institution: institution,
            yearOfCompletion: year,
          );
      if (!mounted) return;
      res.fold(
        (f) => setState(() {
          _saving = false;
          _error = f.message;
        }),
        (_) async {
          try {
            await ref.read(profileControllerProvider.notifier).refresh();
            if (mounted) Navigator.of(context).pop();
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
  }

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
          Text(
            _isEdit ? 'Edit Education' : 'Add Education',
            style: AppTypography.title,
          ),
          const SizedBox(height: AppSpacing.xl),
          CatalogPicker(
            label: 'Degree *',
            initialValue: _isEdit ? widget.education!.degree : null,
            search: (q) async {
              final result = await ref
                  .read(doctorRepositoryProvider)
                  .searchDegrees(q);
              return result.getOrElse(() => []);
            },
            onSelected: (value) => setState(() => _degree = value),
          ),
          const SizedBox(height: AppSpacing.lg),
          TextField(
            controller: _regNumberController,
            decoration: const InputDecoration(
              labelText: 'Registration number *',
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          TextField(
            controller: _institutionController,
            decoration: const InputDecoration(
              labelText: 'Institution (optional)',
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          TextField(
            controller: _yearController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: const InputDecoration(
              labelText: 'Year of completion (optional)',
            ),
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
