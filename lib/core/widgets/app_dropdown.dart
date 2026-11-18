import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

/// Representation of an option in a mobile bottom-sheet selector.
class AppDropdownOption<T> {
  final T value;
  final String label;
  final String? subtitle;
  final IconData? icon;

  const AppDropdownOption({
    required this.value,
    required this.label,
    this.subtitle,
    this.icon,
  });
}

/// Premium native mobile selector component.
/// Instead of a crude desktop dropdown popup menu, this renders an elegant
/// form tile that opens a polished iOS/Android bottom sheet modal with
/// checkmarks, descriptions, and tactile feedback.
class AppDropdown<T> extends StatelessWidget {
  final String label;
  final T? value;
  final List<DropdownMenuItem<T>>? items;
  final List<AppDropdownOption<T>>? options;
  final ValueChanged<T?> onChanged;
  final IconData? prefixIcon;
  final String? hint;

  const AppDropdown({
    super.key,
    required this.label,
    required this.value,
    this.items,
    this.options,
    required this.onChanged,
    this.prefixIcon,
    this.hint,
  });

  List<AppDropdownOption<T>> _resolveOptions() {
    if (options != null && options!.isNotEmpty) {
      return options!;
    }

    if (items != null && items!.isNotEmpty) {
      return items!.map((it) {
        String labelText = '';
        if (it.child is Text) {
          labelText = (it.child as Text).data ?? '';
        } else {
          labelText = it.value?.toString() ?? '';
        }

        return AppDropdownOption<T>(
          value: it.value as T,
          label: labelText,
        );
      }).toList();
    }

    return [];
  }

  void _showPicker(BuildContext context) {
    final allOptions = _resolveOptions();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppSpacing.radiusXl)),
      ),
      builder: (ctx) {
        final mediaQuery = MediaQuery.of(ctx);

        return SafeArea(
          top: false,
          child: Padding(
            padding: EdgeInsets.only(
              bottom: mediaQuery.viewInsets.bottom + 16,
              left: 20,
              right: 20,
              top: 14,
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: mediaQuery.size.height * 0.75,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Handle Bar
                  Center(
                    child: Container(
                      width: 40,
                      height: 4.5,
                      decoration: BoxDecoration(
                        color: const Color(0xFFCBD5E1),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Select $label',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimaryLight,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded, size: 22, color: Color(0xFF64748B)),
                        onPressed: () => Navigator.of(ctx).pop(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Options List
                  Flexible(
                    child: ListView.separated(
                      shrinkWrap: true,
                      physics: const BouncingScrollPhysics(),
                      itemCount: allOptions.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (ctx, index) {
                        final opt = allOptions[index];
                        final isSelected = opt.value == value;

                        return InkWell(
                          onTap: () {
                            Navigator.of(ctx).pop();
                            onChanged(opt.value);
                          },
                          borderRadius: BorderRadius.circular(14),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            decoration: BoxDecoration(
                              color: isSelected ? const Color(0xFFEFF6FF) : const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: isSelected ? AppColors.primary : const Color(0xFFE2E8F0),
                                width: isSelected ? 1.5 : 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                if (opt.icon != null) ...[
                                  Icon(
                                    opt.icon,
                                    size: 20,
                                    color: isSelected ? AppColors.primary : const Color(0xFF64748B),
                                  ),
                                  const SizedBox(width: 12),
                                ],
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        opt.label,
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                          color: isSelected ? AppColors.primary : AppColors.textPrimaryLight,
                                        ),
                                      ),
                                      if (opt.subtitle != null && opt.subtitle!.isNotEmpty) ...[
                                        const SizedBox(height: 2),
                                        Text(
                                          opt.subtitle!,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: AppColors.textSecondaryLight,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Icon(
                                  isSelected ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                                  color: isSelected ? AppColors.primary : const Color(0xFFCBD5E1),
                                  size: 22,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final allOptions = _resolveOptions();
    final selectedOption = allOptions.cast<AppDropdownOption<T>?>().firstWhere(
          (o) => o?.value == value,
          orElse: () => null,
        );

    final displayLabel = selectedOption?.label ?? hint ?? 'Tap to select...';
    final hasValue = selectedOption != null;

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Upper Label
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Color(0xFF475569),
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 6),

          // Clickable Mobile Selection Tile
          Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            child: InkWell(
              onTap: () => _showPicker(context),
              borderRadius: BorderRadius.circular(14),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  children: [
                    if (prefixIcon != null) ...[
                      Icon(prefixIcon, size: 20, color: const Color(0xFF64748B)),
                      const SizedBox(width: 12),
                    ],
                    Expanded(
                      child: Text(
                        displayLabel,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: hasValue ? FontWeight.w600 : FontWeight.w400,
                          color: hasValue ? AppColors.textPrimaryLight : const Color(0xFF94A3B8),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 22,
                      color: Color(0xFF64748B),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
