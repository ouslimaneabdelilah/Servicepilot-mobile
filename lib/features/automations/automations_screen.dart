import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../../core/api_client.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_header.dart';

class AutomationsScreen extends StatefulWidget {
  const AutomationsScreen({super.key});

  @override
  State<AutomationsScreen> createState() => _AutomationsScreenState();
}

class _AutomationsScreenState extends State<AutomationsScreen> {
  bool _loading = true;
  String? _error;
  List<dynamic> _rules = [];
  List<dynamic> _recentLogs = [];

  @override
  void initState() {
    super.initState();
    loadAutomations();
  }

  Future<void> loadAutomations() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final res = await ApiClient.instance.dio.get('/automations');
      setState(() {
        _rules = List.from(res.data['data']['rules'] ?? []);
        _recentLogs = List.from(res.data['data']['recent_executions'] ?? []);
      });
    } on DioException catch (e) {
      setState(() {
        _error = e.response?.data?['message']?.toString() ?? 'Unable to load automation rules.';
      });
    } catch (_) {
      setState(() => _error = 'Failed to load automations.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _toggleRule(String key) async {
    try {
      final res = await ApiClient.instance.dio.post('/automations/$key/toggle');
      if (res.data != null && res.data['data'] is Map) {
        setState(() {
          _rules = List.from(res.data['data']['rules'] ?? []);
        });
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update automation rule.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppHeader(
        title: 'Business Automations',
        subtitle: 'Auto-pilot operations & triggers',
        showBack: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: loadAutomations,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : ListView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  children: [
                    // Information Banner
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.primarySurface,
                        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                        border: Border.all(color: AppColors.primary.withAlpha(40)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.auto_mode_rounded, color: AppColors.primary, size: 28),
                          const SizedBox(width: 14),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Automated Business Workflows',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 14,
                                    color: AppColors.primaryDark,
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'ServicePilot automates repetitive daily contractor tasks like converting estimates, generating invoices, and customer reminders.',
                                  style: TextStyle(fontSize: 12, color: AppColors.textSecondaryLight),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Active Rules List
                    _sectionLabel('ACTIVE AUTOMATION RULES'),
                    const SizedBox(height: 10),
                    ..._rules.map((rule) {
                      final key = rule['key']?.toString() ?? '';
                      final name = rule['name']?.toString() ?? 'Rule';
                      final desc = rule['description']?.toString() ?? '';
                      final cat = rule['category']?.toString() ?? 'Operations';
                      final enabled = rule['enabled'] == true;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: AppCard(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: enabled ? AppColors.successSurface : const Color(0xFFF1F5F9),
                                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                                ),
                                child: Icon(
                                  enabled ? Icons.bolt_rounded : Icons.pause_circle_outline_rounded,
                                  color: enabled ? AppColors.success : AppColors.textMutedLight,
                                  size: 22,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFF1F5F9),
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            cat.toUpperCase(),
                                            style: const TextStyle(
                                              fontSize: 9.5,
                                              fontWeight: FontWeight.w800,
                                              color: Color(0xFF475569),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      name,
                                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      desc,
                                      style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondaryLight),
                                    ),
                                  ],
                                ),
                              ),
                              Switch.adaptive(
                                value: enabled,
                                activeTrackColor: AppColors.primary,
                                onChanged: (_) => _toggleRule(key),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                    const SizedBox(height: 20),

                    // Execution Logs
                    _sectionLabel('RECENT AUTOMATION EXECUTIONS'),
                    const SizedBox(height: 10),
                    if (_recentLogs.isEmpty)
                      AppCard(
                        padding: const EdgeInsets.all(16),
                        child: const Center(
                          child: Text(
                            'No automation triggers executed yet.',
                            style: TextStyle(color: AppColors.textMutedLight, fontSize: 13),
                          ),
                        ),
                      )
                    else
                      AppCard(
                        padding: EdgeInsets.zero,
                        child: Column(
                          children: _recentLogs.map((log) {
                            final action = log['action']?.toString() ?? 'Trigger';
                            final time = log['created_at']?.toString() ?? '';

                            return ListTile(
                              dense: true,
                              leading: const Icon(Icons.check_circle_outline_rounded, color: AppColors.success, size: 18),
                              title: Text(action, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                              trailing: Text(
                                time.length >= 16 ? time.substring(0, 16) : time,
                                style: const TextStyle(fontSize: 11, color: AppColors.textMutedLight),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    const SizedBox(height: 32),
                  ],
                ),
    );
  }

  Widget _sectionLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.8,
        color: AppColors.textMutedLight,
      ),
    );
  }
}
