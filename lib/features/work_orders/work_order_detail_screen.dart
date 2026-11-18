import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/api_client.dart';
import '../../core/widgets/app_loading_button.dart';

class WorkOrderDetailScreen extends StatefulWidget {
  final int workOrderId;

  const WorkOrderDetailScreen({super.key, required this.workOrderId});

  @override
  State<WorkOrderDetailScreen> createState() => _WorkOrderDetailScreenState();
}

class _WorkOrderDetailScreenState extends State<WorkOrderDetailScreen> {
  Map<String, dynamic>? workOrder;
  bool loading = true;
  String? error;
  bool actionLoading = false;

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    setState(() {
      loading = true;
      error = null;
    });

    try {
      final res = await ApiClient.instance.dio.get('/work-orders/${widget.workOrderId}');
      setState(() {
        workOrder = res.data['data'];
      });
    } on DioException catch (e) {
      setState(() {
        error = e.response?.data?['message']?.toString() ?? 'Failed to load work order.';
      });
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> startJob() async {
    setState(() => actionLoading = true);
    try {
      await ApiClient.instance.dio.post('/work-orders/${widget.workOrderId}/start');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Job started! Clock-in recorded.')));
        load();
      }
    } catch (_) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not start job.')));
    } finally {
      if (mounted) setState(() => actionLoading = false);
    }
  }

  Future<void> completeJob() async {
    final notesController = TextEditingController();
    final signerController = TextEditingController();

    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Complete Work Order'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: notesController,
              decoration: const InputDecoration(labelText: 'Technician Work Summary', hintText: 'Repairs performed, parts tested...'),
              maxLines: 3,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: signerController,
              decoration: const InputDecoration(labelText: 'Customer Signer Name', hintText: 'Customer name who confirmed work'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancel')),
          FilledButton(
            onPressed: () => Navigator.pop(c, true),
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFF16A34A)),
            child: const Text('Complete Job'),
          ),
        ],
      ),
    );

    if (ok == true) {
      setState(() => actionLoading = true);
      try {
        await ApiClient.instance.dio.post('/work-orders/${widget.workOrderId}/complete', data: {
          'completion_notes': notesController.text.trim(),
          'customer_signature_name': signerController.text.trim().isNotEmpty ? signerController.text.trim() : null,
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Work order marked as completed!')));
          load();
        }
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to complete work order.')));
      } finally {
        if (mounted) setState(() => actionLoading = false);
      }
    }
  }

  Future<void> toggleChecklist(int checklistId) async {
    try {
      await ApiClient.instance.dio.put('/work-orders/${widget.workOrderId}/checklists/$checklistId');
      load();
    } catch (_) {}
  }

  Future<void> addChecklistTask() async {
    final taskController = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Add Checklist Task'),
        content: TextField(
          controller: taskController,
          decoration: const InputDecoration(labelText: 'Task description', hintText: 'e.g. Test thermostat connectivity'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(c, true), child: const Text('Add')),
        ],
      ),
    );

    if (ok == true && taskController.text.trim().isNotEmpty) {
      try {
        await ApiClient.instance.dio.post('/work-orders/${widget.workOrderId}/checklists', data: {
          'task': taskController.text.trim(),
        });
        load();
      } catch (_) {}
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Work Order Details')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (error != null || workOrder == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Work Order Details')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(error ?? 'Work order not found', style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 12),
              ElevatedButton(onPressed: load, child: const Text('Retry')),
            ],
          ),
        ),
      );
    }

    final status = (workOrder!['status'] ?? 'assigned').toString().toLowerCase();
    final req = workOrder!['service_request'] ?? {};
    final customer = req['customer'] ?? {};
    final checklists = workOrder!['checklists'] as List<dynamic>? ?? [];
    final items = workOrder!['items'] as List<dynamic>? ?? [];
    final notes = workOrder!['completion_notes'] ?? '';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text("Work Order #${workOrder!['id']}", style: const TextStyle(fontWeight: FontWeight.w800)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      bottomNavigationBar: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(16),
        child: status == 'assigned'
            ? AppLoadingButton(
                onPressed: startJob,
                loading: actionLoading,
                label: 'Start Job (Clock In)',
                icon: Icons.play_arrow,
                backgroundColor: const Color(0xFF2563EB),
              )
            : status == 'in_progress'
                ? AppLoadingButton(
                    onPressed: completeJob,
                    loading: actionLoading,
                    label: 'Complete Work Order',
                    icon: Icons.check_circle_outline,
                    backgroundColor: const Color(0xFF16A34A),
                  )
                : Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDEF7EC),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle, color: Color(0xFF03543F)),
                        SizedBox(width: 8),
                        Text('Job Completed & Verified', style: TextStyle(color: Color(0xFF03543F), fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      req['title'] ?? 'Field Service Job',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: status == 'completed' ? const Color(0xFFDEF7EC) : const Color(0xFFEFF4FF),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        status.toUpperCase(),
                        style: TextStyle(
                          color: status == 'completed' ? const Color(0xFF03543F) : const Color(0xFF2457D6),
                          fontWeight: FontWeight.w800,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text("Customer: ${customer['name'] ?? 'Unknown'}", style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF334155))),
                if (req['service_address'] != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, size: 14, color: Color(0xFF94A3B8)),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(req['service_address'], style: const TextStyle(color: Color(0xFF64748B), fontSize: 13)),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Checklist
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('JOB CHECKLIST', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF64748B))),
                    if (status != 'completed')
                      TextButton.icon(
                        onPressed: addChecklistTask,
                        icon: const Icon(Icons.add, size: 16),
                        label: const Text('Add Task'),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                if (checklists.isEmpty)
                  const Text('No checklist items yet.', style: TextStyle(color: Color(0xFF94A3B8)))
                else
                  ...checklists.map((chk) {
                    final done = chk['is_completed'] == true;
                    return CheckboxListTile(
                      value: done,
                      onChanged: status == 'completed' ? null : (_) => toggleChecklist(chk['id']),
                      title: Text(
                        chk['task'] ?? '',
                        style: TextStyle(
                          decoration: done ? TextDecoration.lineThrough : null,
                          color: done ? const Color(0xFF94A3B8) : const Color(0xFF0F172A),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                    );
                  }),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Completion notes
          if (notes.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('TECHNICIAN COMPLETION NOTES', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF64748B))),
                  const SizedBox(height: 8),
                  Text(notes, style: const TextStyle(fontSize: 14, color: Color(0xFF334155))),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

