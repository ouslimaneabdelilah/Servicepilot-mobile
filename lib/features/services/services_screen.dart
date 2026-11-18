import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../../core/api_client.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_empty_state.dart';
import '../../core/widgets/app_header.dart';
import '../../core/widgets/app_loading_button.dart';

class ServicesScreen extends StatefulWidget {
  const ServicesScreen({super.key});

  @override
  State<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen> {
  bool _loading = true;
  String? _error;
  List<dynamic> _services = [];
  List<dynamic> _categories = [];
  int? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    loadCatalog();
  }

  Future<void> loadCatalog() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final resServices = await ApiClient.instance.dio.get('/services');
      final resCats = await ApiClient.instance.dio.get('/service-categories');

      setState(() {
        _services = List.from(resServices.data['data'] ?? []);
        _categories = List.from(resCats.data['data'] ?? []);
      });
    } on DioException catch (e) {
      setState(() {
        _error = e.response?.data?['message']?.toString() ?? 'Unable to load service catalog.';
      });
    } catch (_) {
      setState(() => _error = 'Failed to load services.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  List<dynamic> get _filteredServices {
    if (_selectedCategoryId == null) return _services;
    return _services.where((s) => s['service_category_id'] == _selectedCategoryId).toList();
  }

  void _openAddServiceDialog() {
    final nameCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final priceCtrl = TextEditingController();
    final durationCtrl = TextEditingController(text: '60');
    String pricingType = 'flat_rate';
    int? categoryId = _categories.isNotEmpty ? _categories.first['id'] : null;
    bool isSaving = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppSpacing.radiusXl)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: 20,
              right: 20,
              top: 20,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Add New Service', style: AppTypography.cardTitle.copyWith(fontSize: 18)),
                      IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (_categories.isNotEmpty) ...[
                    DropdownButtonFormField<int>(
                      value: categoryId,
                      decoration: const InputDecoration(labelText: 'Trade Category *'),
                      items: _categories.map<DropdownMenuItem<int>>((c) {
                        return DropdownMenuItem<int>(
                          value: c['id'] as int,
                          child: Text(c['name']?.toString() ?? ''),
                        );
                      }).toList(),
                      onChanged: (val) => setModalState(() => categoryId = val),
                    ),
                    const SizedBox(height: 12),
                  ],
                  TextFormField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Service Name *',
                      hintText: 'e.g. AC Seasonal Tune-Up',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: descCtrl,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      hintText: 'Includes coil cleaning, filter check, refrigerant check',
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: pricingType,
                          decoration: const InputDecoration(labelText: 'Pricing Type'),
                          items: const [
                            DropdownMenuItem(value: 'flat_rate', child: Text('Flat Rate')),
                            DropdownMenuItem(value: 'hourly', child: Text('Hourly Rate')),
                          ],
                          onChanged: (val) => setModalState(() => pricingType = val ?? 'flat_rate'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: priceCtrl,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: const InputDecoration(
                            labelText: 'Base Price (\$)',
                            prefixText: '\$ ',
                            hintText: '150.00',
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: durationCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Estimated Duration (Minutes)',
                      hintText: '60',
                      suffixText: 'mins',
                    ),
                  ),
                  const SizedBox(height: 20),
                  AppLoadingButton(
                    onPressed: isSaving
                        ? null
                        : () async {
                            if (nameCtrl.text.trim().isEmpty) return;

                            setModalState(() => isSaving = true);
                            try {
                              await ApiClient.instance.dio.post('/services', data: {
                                'name': nameCtrl.text.trim(),
                                'description': descCtrl.text.trim(),
                                'pricing_type': pricingType,
                                'base_price': double.tryParse(priceCtrl.text.trim()) ?? 0.0,
                                'estimated_duration_minutes': int.tryParse(durationCtrl.text.trim()) ?? 60,
                                'service_category_id': categoryId,
                                'is_taxable': true,
                                'is_active': true,
                              });

                              if (context.mounted) {
                                Navigator.of(context).pop();
                                loadCatalog();
                              }
                            } catch (_) {
                              setModalState(() => isSaving = false);
                            }
                          },
                    loading: isSaving,
                    label: 'Save Service',
                    icon: Icons.check_circle_outline_rounded,
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredServices;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppHeader(
        title: 'Services & Pricing',
        subtitle: '${_services.length} catalog items',
        showBack: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: loadCatalog,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddServiceDialog,
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text('Add Service', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : Column(
                  children: [
                    // Category Chips
                    if (_categories.isNotEmpty)
                      Container(
                        height: 52,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: FilterChip(
                                label: const Text('All Trades'),
                                selected: _selectedCategoryId == null,
                                onSelected: (_) => setState(() => _selectedCategoryId = null),
                                selectedColor: AppColors.primarySurface,
                                checkmarkColor: AppColors.primary,
                                labelStyle: TextStyle(
                                  fontWeight: _selectedCategoryId == null ? FontWeight.w700 : FontWeight.w500,
                                  color: _selectedCategoryId == null ? AppColors.primary : AppColors.textSecondaryLight,
                                ),
                              ),
                            ),
                            ..._categories.map((c) {
                              final isSel = _selectedCategoryId == c['id'];
                              return Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: FilterChip(
                                  label: Text(c['name']?.toString() ?? ''),
                                  selected: isSel,
                                  onSelected: (_) => setState(() => _selectedCategoryId = c['id'] as int),
                                  selectedColor: AppColors.primarySurface,
                                  checkmarkColor: AppColors.primary,
                                  labelStyle: TextStyle(
                                    fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
                                    color: isSel ? AppColors.primary : AppColors.textSecondaryLight,
                                  ),
                                ),
                              );
                            }),
                          ],
                        ),
                      ),

                    // Services List
                    Expanded(
                      child: filtered.isEmpty
                          ? const AppEmptyState(
                              icon: Icons.category_rounded,
                              title: 'No Services in this Category',
                              message: 'Tap "Add Service" to populate your service price book.',
                            )
                          : ListView.separated(
                              physics: const BouncingScrollPhysics(),
                              padding: const EdgeInsets.all(16),
                              itemCount: filtered.length,
                              separatorBuilder: (_, __) => const SizedBox(height: 10),
                              itemBuilder: (ctx, idx) {
                                final s = filtered[idx];
                                final name = s['name']?.toString() ?? 'Service';
                                final desc = s['description']?.toString() ?? '';
                                final price = s['base_price']?.toString() ?? '0.00';
                                final type = (s['pricing_type'] ?? 'flat_rate').toString().replaceAll('_', ' ').toUpperCase();
                                final duration = s['estimated_duration_minutes']?.toString() ?? '60';

                                return AppCard(
                                  padding: const EdgeInsets.all(16),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: AppColors.primarySurface,
                                          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                                        ),
                                        child: const Icon(
                                          Icons.build_circle_outlined,
                                          color: AppColors.primary,
                                          size: 24,
                                        ),
                                      ),
                                      const SizedBox(width: 14),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              name,
                                              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                                            ),
                                            if (desc.isNotEmpty) ...[
                                              const SizedBox(height: 2),
                                              Text(
                                                desc,
                                                style: const TextStyle(fontSize: 12, color: AppColors.textSecondaryLight),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ],
                                            const SizedBox(height: 6),
                                            Row(
                                              children: [
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                  decoration: BoxDecoration(
                                                    color: const Color(0xFFF1F5F9),
                                                    borderRadius: BorderRadius.circular(4),
                                                  ),
                                                  child: Text(
                                                    type,
                                                    style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w700, color: Color(0xFF475569)),
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                Text(
                                                  '⏱ $duration mins',
                                                  style: const TextStyle(fontSize: 11, color: AppColors.textMutedLight),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        '\$$price',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w800,
                                          fontSize: 16,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
    );
  }
}
