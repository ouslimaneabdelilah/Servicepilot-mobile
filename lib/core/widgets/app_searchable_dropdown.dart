import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

/// Searchable selector component that opens a clean modal sheet with live filtering.
class AppSearchableDropdown<T> extends StatelessWidget {
  final String label;
  final String hint;
  final T? selectedItem;
  final List<T> items;
  final String Function(T) itemLabel;
  final String? Function(T)? itemSubtitle;
  final ValueChanged<T?> onChanged;
  final IconData prefixIcon;
  final bool isRequired;
  final String? errorText;

  const AppSearchableDropdown({
    super.key,
    required this.label,
    required this.hint,
    required this.items,
    required this.itemLabel,
    this.itemSubtitle,
    required this.onChanged,
    this.selectedItem,
    this.prefixIcon = Icons.search_rounded,
    this.isRequired = false,
    this.errorText,
  });

  void _showPicker(BuildContext context) {
    showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppSpacing.radiusXl)),
      ),
      builder: (ctx) => _SearchPickerSheet<T>(
        title: label,
        items: items,
        itemLabel: itemLabel,
        itemSubtitle: itemSubtitle,
        selectedItem: selectedItem,
      ),
    ).then((val) {
      if (val != null) {
        onChanged(val);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final displayText = selectedItem != null ? itemLabel(selectedItem as T) : null;

    return InkWell(
      onTap: () => _showPicker(context),
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: isRequired ? '$label *' : label,
          hintText: hint,
          prefixIcon: Icon(prefixIcon, size: 20),
          suffixIcon: const Icon(Icons.keyboard_arrow_down_rounded, size: 20),
          errorText: errorText,
        ),
        child: Text(
          displayText ?? hint,
          style: displayText != null
              ? AppTypography.input
              : AppTypography.caption.copyWith(color: AppColors.textMutedLight, fontSize: 14),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}

class _SearchPickerSheet<T> extends StatefulWidget {
  final String title;
  final List<T> items;
  final String Function(T) itemLabel;
  final String? Function(T)? itemSubtitle;
  final T? selectedItem;

  const _SearchPickerSheet({
    required this.title,
    required this.items,
    required this.itemLabel,
    this.itemSubtitle,
    this.selectedItem,
  });

  @override
  State<_SearchPickerSheet<T>> createState() => _SearchPickerSheetState<T>();
}

class _SearchPickerSheetState<T> extends State<_SearchPickerSheet<T>> {
  final TextEditingController _searchCtrl = TextEditingController();
  List<T> _filtered = [];

  @override
  void initState() {
    super.initState();
    _filtered = widget.items;
  }

  void _onSearch(String query) {
    setState(() {
      if (query.trim().isEmpty) {
        _filtered = widget.items;
      } else {
        final q = query.toLowerCase().trim();
        _filtered = widget.items.where((item) {
          final label = widget.itemLabel(item).toLowerCase();
          final sub = widget.itemSubtitle?.call(item)?.toLowerCase() ?? '';
          return label.contains(q) || sub.contains(q);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      expand: false,
      builder: (ctx, scrollCtrl) {
        return Column(
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 38,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFCBD5E1),
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Select ${widget.title}', style: AppTypography.cardTitle.copyWith(fontSize: 18)),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            // Search Bar
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 6, 20, 14),
              child: TextField(
                controller: _searchCtrl,
                onChanged: _onSearch,
                decoration: InputDecoration(
                  hintText: 'Search...',
                  prefixIcon: const Icon(Icons.search_rounded, size: 20),
                  suffixIcon: _searchCtrl.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 18),
                          onPressed: () {
                            _searchCtrl.clear();
                            _onSearch('');
                          },
                        )
                      : null,
                ),
              ),
            ),
            const Divider(height: 1),

            // Item List
            Expanded(
              child: _filtered.isEmpty
                  ? Center(
                      child: Text(
                        'No matches found for "${_searchCtrl.text}"',
                        style: const TextStyle(color: AppColors.textMutedLight),
                      ),
                    )
                  : ListView.separated(
                      controller: scrollCtrl,
                      itemCount: _filtered.length,
                      separatorBuilder: (_, __) => const Divider(height: 1, indent: 20, endIndent: 20),
                      itemBuilder: (ctx, idx) {
                        final item = _filtered[idx];
                        final isSelected = item == widget.selectedItem;
                        final label = widget.itemLabel(item);
                        final subtitle = widget.itemSubtitle?.call(item);

                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                          title: Text(
                            label,
                            style: TextStyle(
                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                              color: isSelected ? AppColors.primary : AppColors.textPrimaryLight,
                            ),
                          ),
                          subtitle: subtitle != null ? Text(subtitle, style: AppTypography.caption) : null,
                          trailing: isSelected
                              ? const Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 20)
                              : null,
                          onTap: () => Navigator.of(context).pop(item),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }
}
