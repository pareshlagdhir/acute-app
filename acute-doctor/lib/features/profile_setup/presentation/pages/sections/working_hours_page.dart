import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/errors/failures.dart';
import '../../../../../core/theme/tokens/tokens.dart';
import '../../../../../core/widgets/acute_button.dart';
import '../../../../onboarding/data/models/profile_models.dart';
import '../../../../onboarding/presentation/providers/onboarding_providers.dart';

/// Day label lookup: dayOfWeek 0 = Monday … 6 = Sunday.
const _kDayLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

/// Format a [TimeOfDay] to `'HH:mm:ss'` without importing intl.
String _formatTime(TimeOfDay t) {
  final h = t.hour.toString().padLeft(2, '0');
  final m = t.minute.toString().padLeft(2, '0');
  return '$h:$m:00';
}

/// Display a `'HH:mm:ss'` string as `'HH:mm'`.
String _displayTime(String hms) => hms.substring(0, 5);


class WorkingHoursPage extends ConsumerWidget {
  const WorkingHoursPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileControllerProvider);

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('Working Hours'),
      ),
      body: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(e.toString())),
        data: (profile) => _WorkingHoursBody(profile: profile),
      ),
    );
  }
}

class _WorkingHoursBody extends ConsumerWidget {
  const _WorkingHoursBody({required this.profile});

  final DoctorProfile profile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (profile.experiences.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.xxl),
          child: Text(
            'No experience added yet.\n'
            'Please add an experience first before setting working hours.',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return SafeArea(
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xxl,
          vertical: AppSpacing.lg,
        ),
        itemCount: profile.experiences.length,
        separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.xxl),
        itemBuilder: (context, index) {
          final exp = profile.experiences[index];
          return _ExperienceHoursCard(experience: exp);
        },
      ),
    );
  }
}

class _ExperienceHoursCard extends ConsumerWidget {
  const _ExperienceHoursCard({required this.experience});

  final Experience experience;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Group working hours by dayOfWeek.
    final byDay = <int, List<WorkingHour>>{};
    for (final wh in experience.workingHours) {
      byDay.putIfAbsent(wh.dayOfWeek, () => []).add(wh);
    }

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              experience.hospital.name,
              style: AppTypography.title,
            ),
            const SizedBox(height: AppSpacing.md),
            if (experience.workingHours.isEmpty)
              const Text('No slots added yet.')
            else
              ...List.generate(7, (day) {
                final slots = byDay[day];
                if (slots == null || slots.isEmpty) return const SizedBox.shrink();
                return _DayGroup(
                  experienceId: experience.id,
                  day: day,
                  slots: slots,
                );
              }),
            const SizedBox(height: AppSpacing.lg),
            AcuteButton(
              label: 'Add slot',
              icon: Icons.add,
              onPressed: () => _openAddSlot(context, experience.id),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openAddSlot(BuildContext context, String experienceId) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: AppRadii.lg),
      ),
      builder: (ctx) => UncontrolledProviderScope(
        container: ProviderScope.containerOf(context),
        child: _AddSlotForm(experienceId: experienceId),
      ),
    );
  }
}

class _DayGroup extends ConsumerStatefulWidget {
  const _DayGroup({
    required this.experienceId,
    required this.day,
    required this.slots,
  });

  final String experienceId;
  final int day;
  final List<WorkingHour> slots;

  @override
  ConsumerState<_DayGroup> createState() => _DayGroupState();
}

class _DayGroupState extends ConsumerState<_DayGroup> {
  Future<void> _delete(WorkingHour wh) async {
    final res = await ref
        .read(doctorRepositoryProvider)
        .deleteWorkingHour(widget.experienceId, wh.id);
    if (!mounted) return;
    final failure = res.fold<Failure?>((f) => f, (_) => null);
    if (failure != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(failure.message)),
      );
      return;
    }
    await ref.read(profileControllerProvider.notifier).refresh();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _kDayLabels[widget.day],
          style: AppTypography.bodyStrong,
        ),
        const SizedBox(height: AppSpacing.xs),
        ...widget.slots.map(
          (wh) => ListTile(
            contentPadding: EdgeInsets.zero,
            dense: true,
            title: Text(
              '${_displayTime(wh.startTime)} – ${_displayTime(wh.endTime)}',
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: 'Delete slot',
              color: Theme.of(context).colorScheme.error,
              onPressed: () => _delete(wh),
            ),
          ),
        ),
        const Divider(),
      ],
    );
  }
}

class _AddSlotForm extends ConsumerStatefulWidget {
  const _AddSlotForm({required this.experienceId});

  final String experienceId;

  @override
  ConsumerState<_AddSlotForm> createState() => _AddSlotFormState();
}

class _AddSlotFormState extends ConsumerState<_AddSlotForm> {
  int _selectedDay = 0;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  bool _saving = false;
  String? _error;

  Future<void> _pickTime({required bool isStart}) async {
    final initial = isStart
        ? (_startTime ?? const TimeOfDay(hour: 9, minute: 0))
        : (_endTime ?? const TimeOfDay(hour: 17, minute: 0));
    final picked = await showTimePicker(context: context, initialTime: initial);
    if (picked == null) return;
    setState(() {
      if (isStart) {
        _startTime = picked;
      } else {
        _endTime = picked;
      }
    });
  }

  Future<void> _save() async {
    if (_startTime == null || _endTime == null) {
      setState(() => _error = 'Please select both start and end time.');
      return;
    }

    // Validate end > start.
    final startMinutes = _startTime!.hour * 60 + _startTime!.minute;
    final endMinutes = _endTime!.hour * 60 + _endTime!.minute;
    if (endMinutes <= startMinutes) {
      setState(() => _error = 'End time must be after start time.');
      return;
    }

    setState(() {
      _saving = true;
      _error = null;
    });

    final res = await ref.read(doctorRepositoryProvider).addWorkingHour(
          experienceId: widget.experienceId,
          dayOfWeek: _selectedDay,
          startTime: _formatTime(_startTime!),
          endTime: _formatTime(_endTime!),
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
    final notifier = ref.read(profileControllerProvider.notifier);
    await notifier.refresh();
    if (!mounted) return;
    Navigator.of(context).pop();
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
          const Text('Add Slot', style: AppTypography.title),
          const SizedBox(height: AppSpacing.xl),
          DropdownButtonFormField<int>(
            initialValue: _selectedDay,
            decoration: const InputDecoration(labelText: 'Day'),
            items: List.generate(
              7,
              (i) => DropdownMenuItem(value: i, child: Text(_kDayLabels[i])),
            ),
            onChanged: (v) => setState(() => _selectedDay = v ?? 0),
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.access_time, size: 16),
                  label: Text(
                    _startTime != null
                        ? _displayTime(_formatTime(_startTime!))
                        : 'Start time',
                    overflow: TextOverflow.ellipsis,
                  ),
                  onPressed: () => _pickTime(isStart: true),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.access_time, size: 16),
                  label: Text(
                    _endTime != null
                        ? _displayTime(_formatTime(_endTime!))
                        : 'End time',
                    overflow: TextOverflow.ellipsis,
                  ),
                  onPressed: () => _pickTime(isStart: false),
                ),
              ),
            ],
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
    );
  }
}
