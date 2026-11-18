import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../../core/api_client.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/app_avatar.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_dropdown.dart';
import '../../core/widgets/app_empty_state.dart';
import '../../core/widgets/app_header.dart';
import '../../core/widgets/app_loading_button.dart';
import '../../core/widgets/app_status_badge.dart';

class TeamScreen extends StatefulWidget {
  const TeamScreen({super.key});

  @override
  State<TeamScreen> createState() => _TeamScreenState();
}

class _TeamScreenState extends State<TeamScreen> {
  bool _loading = true;
  String? _error;
  List<dynamic> _members = [];

  @override
  void initState() {
    super.initState();
    loadTeam();
  }

  Future<void> loadTeam() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final res = await ApiClient.instance.dio.get('/team');
      setState(() {
        _members = List.from(res.data['data'] ?? []);
      });
    } on DioException catch (e) {
      setState(() {
        _error = e.response?.data?['message']?.toString() ?? 'Unable to load team members.';
      });
    } catch (_) {
      setState(() => _error = 'Failed to load team.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _openInviteDialog() {
    final emailCtrl = TextEditingController();
    String role = 'technician';
    bool isSaving = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppSpacing.radiusXl)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          final mediaQuery = MediaQuery.of(context);
          return SafeArea(
            top: false,
            child: Padding(
              padding: EdgeInsets.only(
                bottom: mediaQuery.viewInsets.bottom + 16,
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
                        Text('Invite Staff Member', style: AppTypography.cardTitle.copyWith(fontSize: 18)),
                        IconButton(
                          icon: const Icon(Icons.close_rounded),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Staff Email Address *',
                        hintText: 'technician@company.com',
                        prefixIcon: Icon(Icons.mail_outline_rounded, size: 20),
                      ),
                    ),
                    const SizedBox(height: 14),
                    AppDropdown<String>(
                      label: 'Company Role *',
                      value: role,
                      prefixIcon: Icons.badge_outlined,
                      options: const [
                        AppDropdownOption(value: 'technician', label: 'Field Technician', subtitle: 'Executes jobs, fills checklists & logs hours'),
                        AppDropdownOption(value: 'dispatcher', label: 'Dispatcher / Coordinator', subtitle: 'Schedules calls, assigns jobs & dispatches techs'),
                        AppDropdownOption(value: 'admin', label: 'Administrator', subtitle: 'Full administrative access to financial records & team'),
                      ],
                      onChanged: (val) => setModalState(() => role = val ?? 'technician'),
                    ),
                  const SizedBox(height: 22),
                  AppLoadingButton(
                    onPressed: isSaving
                        ? null
                        : () async {
                            if (emailCtrl.text.trim().isEmpty) return;

                            setModalState(() => isSaving = true);
                            try {
                              await ApiClient.instance.dio.post('/team/invite', data: {
                                'email': emailCtrl.text.trim().toLowerCase(),
                                'role': role,
                              });

                              if (context.mounted) {
                                Navigator.of(context).pop();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Staff invitation dispatched successfully!')),
                                );
                                loadTeam();
                              }
                            } catch (_) {
                              setModalState(() => isSaving = false);
                            }
                          },
                    loading: isSaving,
                    label: 'Send Workspace Invitation',
                    icon: Icons.send_rounded,
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        );
      },
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppHeader(
        title: 'Team & Staff',
        subtitle: '${_members.length} active members',
        showBack: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: loadTeam,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openInviteDialog,
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.person_add_alt_1_rounded, color: Colors.white),
        label: const Text('Invite Staff', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : _members.isEmpty
                  ? AppEmptyState(
                      icon: Icons.badge_outlined,
                      title: 'No Team Members Found',
                      message: 'Invite your dispatchers and field technicians to collaborate.',
                      actionLabel: 'Invite Staff',
                      onAction: _openInviteDialog,
                    )
                  : RefreshIndicator(
                      onRefresh: loadTeam,
                      child: ListView.separated(
                        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                        padding: const EdgeInsets.all(16),
                        itemCount: _members.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (ctx, idx) {
                          final m = _members[idx];
                          final name = m['name']?.toString() ?? 'Team Member';
                          final email = m['email']?.toString() ?? '';
                          final phone = m['phone']?.toString();
                          final role = (m['role'] ?? 'technician').toString();

                          return AppCard(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                AppAvatar(
                                  name: name,
                                  size: 44,
                                  backgroundColor: AppColors.primarySurface,
                                  textColor: AppColors.primary,
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        name,
                                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        email,
                                        style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondaryLight),
                                      ),
                                      if (phone != null && phone.isNotEmpty) ...[
                                        const SizedBox(height: 2),
                                        Text(
                                          phone,
                                          style: const TextStyle(fontSize: 11.5, color: AppColors.textMutedLight),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                AppStatusBadge.fromStatus(role),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
    );
  }
}
