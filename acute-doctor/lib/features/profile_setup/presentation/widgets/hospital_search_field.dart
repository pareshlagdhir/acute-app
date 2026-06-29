import 'package:flutter/material.dart';

import '../../../onboarding/data/models/profile_models.dart';
import '../../../../../core/theme/tokens/tokens.dart';

/// A search field for hospitals.
///
/// Calls the injected [search] callback as the user types; when the query is
/// non-empty and no matching hospital was found, offers an "Add as
/// clinic/hospital" affordance. Selecting a result or creating a new one emits
/// the hospital via [onSelected].
///
/// Purely presentational — all side-effects are injected.
class HospitalSearchField extends StatefulWidget {
  const HospitalSearchField({
    required this.search,
    required this.onCreate,
    required this.onSelected,
    this.initialHospital,
    super.key,
  });

  /// Searches for hospitals matching the given query string.
  final Future<List<Hospital>> Function(String query) search;

  /// Creates a new hospital with the given name and type strings.
  final Future<Hospital> Function(String name, String type) onCreate;

  /// Emits the selected or newly created hospital.
  final ValueChanged<Hospital> onSelected;

  /// Optional pre-selected hospital (edit mode).
  final Hospital? initialHospital;

  @override
  State<HospitalSearchField> createState() => _HospitalSearchFieldState();
}

class _HospitalSearchFieldState extends State<HospitalSearchField> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  List<Hospital> _results = [];
  bool _loading = false;
  bool _showSuggestions = false;
  bool _creatingNew = false;
  String? _createError;

  @override
  void initState() {
    super.initState();
    if (widget.initialHospital != null) {
      _controller.text = widget.initialHospital!.name;
    }
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _onChanged(String query) async {
    if (query.isEmpty) {
      setState(() {
        _results = [];
        _showSuggestions = false;
      });
      return;
    }
    setState(() => _loading = true);
    final results = await widget.search(query);
    if (!mounted) return;
    setState(() {
      _results = results;
      _loading = false;
      _showSuggestions = true;
    });
  }

  void _selectHospital(Hospital hospital) {
    _controller.text = hospital.name;
    setState(() {
      _results = [];
      _showSuggestions = false;
    });
    widget.onSelected(hospital);
    _focusNode.unfocus();
  }

  Future<void> _addNew(String name) async {
    setState(() {
      _creatingNew = true;
      _showSuggestions = false;
      _createError = null;
    });
    try {
      final hospital = await widget.onCreate(name, 'hospital');
      if (!mounted) return;
      _controller.text = hospital.name;
      setState(() => _creatingNew = false);
      widget.onSelected(hospital);
      _focusNode.unfocus();
    } on Exception catch (e) {
      if (!mounted) return;
      setState(() {
        _creatingNew = false;
        _createError = e.toString().replaceFirst('Exception: ', '');
      });
    } on Object catch (e) {
      if (!mounted) return;
      setState(() {
        _creatingNew = false;
        _createError = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final query = _controller.text.trim();
    final hasNoMatch = query.isNotEmpty &&
        !_loading &&
        _results.every((h) => h.name.toLowerCase() != query.toLowerCase());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(
          controller: _controller,
          focusNode: _focusNode,
          decoration: InputDecoration(
            labelText: 'Hospital / Clinic *',
            suffixIcon: _loading || _creatingNew
                ? const Padding(
                    padding: EdgeInsets.all(12),
                    child: SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : null,
          ),
          onChanged: _onChanged,
          textInputAction: TextInputAction.search,
        ),
        if (_createError != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              _createError!,
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
                fontSize: 12,
              ),
            ),
          ),
        if (_showSuggestions && (_results.isNotEmpty || hasNoMatch))
          Material(
            elevation: 2,
            borderRadius: AppRadii.brMd,
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.zero,
              itemCount: _results.length + (hasNoMatch ? 1 : 0),
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                if (index < _results.length) {
                  final hospital = _results[index];
                  return ListTile(
                    leading: const Icon(Icons.local_hospital_outlined),
                    title: Text(hospital.name),
                    subtitle: hospital.city != null ? Text(hospital.city!) : null,
                    dense: true,
                    onTap: () => _selectHospital(hospital),
                  );
                }
                // "Add new" affordance
                return ListTile(
                  leading: const Icon(Icons.add_circle_outline),
                  title: Text("Add '$query' as hospital/clinic"),
                  dense: true,
                  onTap: () => _addNew(query),
                );
              },
            ),
          ),
      ],
    );
  }
}
