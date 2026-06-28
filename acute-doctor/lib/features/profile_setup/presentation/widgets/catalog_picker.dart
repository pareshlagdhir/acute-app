import 'package:flutter/material.dart';

import '../../../onboarding/data/models/profile_models.dart';
import '../../../../../core/theme/tokens/tokens.dart';

/// A reusable autocomplete field that calls an injected [search] function and
/// fires [onSelected] with either the chosen catalog item's name or a free-text
/// custom value when the user submits without picking a suggestion.
///
/// [label] controls the field decoration label (defaults to "Search").
/// [initialValue] pre-fills the text field (used for edit forms).
class CatalogPicker extends StatefulWidget {
  const CatalogPicker({
    required this.search,
    required this.onSelected,
    this.label = 'Search',
    this.initialValue,
    super.key,
  });

  /// Injected search function — takes an optional query and returns a list of
  /// [CatalogItem]s. Keeping the search function injected makes this widget
  /// purely presentational and reusable for any catalog (degrees, specialities,
  /// hospitals, etc.).
  final Future<List<CatalogItem>> Function(String? query) search;

  /// Called with the selected catalog item's name, or with the raw text the
  /// user typed when submitting without choosing a suggestion (custom entry).
  final ValueChanged<String> onSelected;

  /// Decoration label shown in the text field.
  final String label;

  /// Optional pre-filled value (for edit mode).
  final String? initialValue;

  @override
  State<CatalogPicker> createState() => _CatalogPickerState();
}

class _CatalogPickerState extends State<CatalogPicker> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  List<CatalogItem> _suggestions = [];
  bool _loading = false;
  bool _showSuggestions = false;
  // Tracks whether the last value emitted came from a catalog item tap so that
  // the focus-loss listener does not double-emit the same value.
  bool _selectedFromCatalog = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialValue != null) {
      _controller.text = widget.initialValue!;
    }
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _focusNode
      ..removeListener(_onFocusChange)
      ..dispose();
    _controller.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (!_focusNode.hasFocus && !_selectedFromCatalog) {
      _submitCustom();
    }
    // Reset the guard after each focus cycle.
    if (!_focusNode.hasFocus) {
      _selectedFromCatalog = false;
    }
  }

  Future<void> _onChanged(String query) async {
    if (query.isEmpty) {
      setState(() {
        _suggestions = [];
        _showSuggestions = false;
      });
      return;
    }
    setState(() => _loading = true);
    final results = await widget.search(query);
    if (!mounted) return;
    setState(() {
      _suggestions = results;
      _loading = false;
      _showSuggestions = results.isNotEmpty;
    });
  }

  void _selectItem(CatalogItem item) {
    _controller.text = item.name;
    _selectedFromCatalog = true;
    setState(() {
      _suggestions = [];
      _showSuggestions = false;
    });
    widget.onSelected(item.name);
  }

  void _submitCustom() {
    final text = _controller.text.trim();
    if (text.isNotEmpty) {
      setState(() {
        _suggestions = [];
        _showSuggestions = false;
      });
      widget.onSelected(text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(
          controller: _controller,
          focusNode: _focusNode,
          decoration: InputDecoration(
            labelText: widget.label,
            suffixIcon: _loading
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
          onSubmitted: (_) {
            _selectedFromCatalog = false;
            _submitCustom();
          },
          textInputAction: TextInputAction.done,
        ),
        if (_showSuggestions)
          Material(
            elevation: 2,
            borderRadius: AppRadii.brMd,
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.zero,
              itemCount: _suggestions.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final item = _suggestions[index];
                return ListTile(
                  title: Text(item.name),
                  onTap: () => _selectItem(item),
                  dense: true,
                );
              },
            ),
          ),
      ],
    );
  }
}
