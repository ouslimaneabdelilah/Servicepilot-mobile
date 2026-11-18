import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/api_client.dart';
import '../../core/widgets/app_empty_state.dart';

class CustomersScreen extends StatefulWidget {
  const CustomersScreen({super.key});

  @override
  State<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends State<CustomersScreen> {
  List<dynamic> items = [];
  bool loading = true;
  String? error;
  String searchQuery = '';
  final searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    load();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> load({String? search}) async {
    setState(() {
      loading = true;
      error = null;
    });

    try {
      final response = await ApiClient.instance.dio.get(
        '/customers',
        queryParameters: {
          if (search != null && search.isNotEmpty) 'search': search,
          'per_page': 30,
        },
      );
      setState(() {
        items = response.data['data'] ?? [];
      });
    } on DioException catch (e) {
      setState(() {
        error = e.response?.data?['message']?.toString() ?? 'Unable to load customer directory.';
      });
    } finally {
      if (mounted) {
        setState(() => loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Customers', style: TextStyle(fontWeight: FontWeight.w800)),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => load(search: searchQuery),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final created = await context.push<bool>('/customers/new');
          if (created == true) load();
        },
        backgroundColor: const Color(0xFF2457D6),
        icon: const Icon(Icons.person_add_alt_1, color: Colors.white),
        label: const Text('Add Customer', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
      ),
      body: Column(
        children: [
          // Search Header
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: TextField(
              controller: searchController,
              onChanged: (v) {
                searchQuery = v;
                load(search: v);
              },
              decoration: InputDecoration(
                hintText: 'Search by name, email, phone or ID...',
                prefixIcon: const Icon(Icons.search, size: 20),
                suffixIcon: searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          searchController.clear();
                          searchQuery = '';
                          load();
                        },
                      )
                    : null,
                filled: true,
                fillColor: const Color(0xFFF1F5F9),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const Divider(height: 1, color: Color(0xFFE2E8F0)),

          // List Body
          Expanded(
            child: loading
                ? const Center(child: CircularProgressIndicator())
                : error != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(error!, style: const TextStyle(color: Colors.red)),
                            const SizedBox(height: 12),
                            ElevatedButton(onPressed: () => load(), child: const Text('Retry')),
                          ],
                        ),
                      )
                    : items.isEmpty
                        ? AppEmptyState(
                            icon: Icons.people_outline,
                            title: 'No Customers Found',
                            message: searchQuery.isEmpty
                                ? 'Add your first customer to start dispatching jobs and sending quotes.'
                                : 'No customers match your search "$searchQuery".',
                            actionLabel: 'Add Customer',
                            onAction: () async {
                              final created = await context.push<bool>('/customers/new');
                              if (created == true) load();
                            },
                          )
                        : RefreshIndicator(
                            onRefresh: () => load(search: searchQuery),
                            child: ListView.separated(
                              padding: const EdgeInsets.all(16),
                              itemCount: items.length,
                              separatorBuilder: (_, __) => const SizedBox(height: 10),
                              itemBuilder: (context, index) {
                                final c = items[index];
                                final name = c['name'] ?? 'Unnamed Customer';
                                final initial = name.isNotEmpty ? name[0].toUpperCase() : 'C';
                                final phone = c['phone'] ?? '';
                                final email = c['email'] ?? '';
                                final custNum = c['customer_number'] ?? '';
                                final addresses = c['addresses'] as List<dynamic>? ?? [];
                                final addressStr = addresses.isNotEmpty
                                    ? "${addresses[0]['street_address']}, ${addresses[0]['city']}"
                                    : null;

                                return InkWell(
                                  borderRadius: BorderRadius.circular(14),
                                  onTap: () => context.push('/customers/${c['id']}'),
                                  child: Container(
                                    padding: const EdgeInsets.all(14),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(color: const Color(0xFFE2E8F0)),
                                    ),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        CircleAvatar(
                                          radius: 22,
                                          backgroundColor: const Color(0xFFE0E7FF),
                                          child: Text(
                                            initial,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w700,
                                              color: Color(0xFF2457D6),
                                              fontSize: 16,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 14),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      name,
                                                      style: const TextStyle(
                                                        fontSize: 16,
                                                        fontWeight: FontWeight.w700,
                                                        color: Color(0xFF0F172A),
                                                      ),
                                                      maxLines: 1,
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                  if (custNum.isNotEmpty)
                                                    Container(
                                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                                      decoration: BoxDecoration(
                                                        color: const Color(0xFFF1F5F9),
                                                        borderRadius: BorderRadius.circular(6),
                                                      ),
                                                      child: Text(
                                                        custNum,
                                                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF475569)),
                                                      ),
                                                    ),
                                                ],
                                              ),
                                              if (phone.isNotEmpty || email.isNotEmpty) ...[
                                                const SizedBox(height: 4),
                                                Text(
                                                  phone.isNotEmpty ? phone : email,
                                                  style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                                                ),
                                              ],
                                              if (addressStr != null) ...[
                                                const SizedBox(height: 6),
                                                Row(
                                                  children: [
                                                    const Icon(Icons.location_on_outlined, size: 14, color: Color(0xFF94A3B8)),
                                                    const SizedBox(width: 4),
                                                    Expanded(
                                                      child: Text(
                                                        addressStr,
                                                        style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                                                        maxLines: 1,
                                                        overflow: TextOverflow.ellipsis,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ],
                                          ),
                                        ),
                                        const Icon(Icons.chevron_right, color: Color(0xFFCBD5E1), size: 20),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }
}
