import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/auth_controller.dart';
import '../features/auth/login_screen.dart';
import '../features/auth/register_screen.dart';
import '../features/customers/customer_detail_screen.dart';
import '../features/customers/customer_form_screen.dart';
import '../features/customers/customers_screen.dart';
import '../features/dashboard/dashboard_screen.dart';
import '../features/estimates/estimate_detail_screen.dart';
import '../features/estimates/estimate_form_screen.dart';
import '../features/estimates/estimates_screen.dart';
import '../features/invoices/invoice_detail_screen.dart';
import '../features/invoices/invoices_screen.dart';
import '../features/service_requests/service_request_form_screen.dart';
import '../features/service_requests/service_requests_screen.dart';
import '../features/work_orders/work_order_detail_screen.dart';
import '../features/work_orders/work_orders_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      final isAuthRoute = state.matchedLocation == '/login' || state.matchedLocation == '/register';

      if (!authState.loggedIn && !isAuthRoute) {
        return '/login';
      }

      if (authState.loggedIn && isAuthRoute) {
        return '/dashboard';
      }

      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),
      GoRoute(path: '/dashboard', builder: (_, __) => const DashboardScreen()),

      // Customers
      GoRoute(path: '/customers', builder: (_, __) => const CustomersScreen()),
      GoRoute(
        path: '/customers/new',
        builder: (_, state) => CustomerFormScreen(initialCustomer: state.extra as Map<String, dynamic>?),
      ),
      GoRoute(
        path: '/customers/:id',
        builder: (_, state) {
          final id = int.tryParse(state.pathParameters['id'] ?? '0') ?? 0;
          return CustomerDetailScreen(customerId: id);
        },
      ),

      // Service Requests
      GoRoute(path: '/service-requests', builder: (_, __) => const ServiceRequestsScreen()),
      GoRoute(path: '/service-requests/new', builder: (_, __) => const ServiceRequestFormScreen()),

      // Estimates
      GoRoute(path: '/estimates', builder: (_, __) => const EstimatesScreen()),
      GoRoute(path: '/estimates/new', builder: (_, __) => const EstimateFormScreen()),
      GoRoute(
        path: '/estimates/:id',
        builder: (_, state) {
          final id = int.tryParse(state.pathParameters['id'] ?? '0') ?? 0;
          return EstimateDetailScreen(estimateId: id);
        },
      ),

      // Work Orders
      GoRoute(path: '/work-orders', builder: (_, __) => const WorkOrdersScreen()),
      GoRoute(
        path: '/work-orders/:id',
        builder: (_, state) {
          final id = int.tryParse(state.pathParameters['id'] ?? '0') ?? 0;
          return WorkOrderDetailScreen(workOrderId: id);
        },
      ),

      // Invoices
      GoRoute(path: '/invoices', builder: (_, __) => const InvoicesScreen()),
      GoRoute(
        path: '/invoices/:id',
        builder: (_, state) {
          final id = int.tryParse(state.pathParameters['id'] ?? '0') ?? 0;
          return InvoiceDetailScreen(invoiceId: id);
        },
      ),
    ],
  );
});
