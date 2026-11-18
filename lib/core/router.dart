import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/auth_controller.dart';
import '../features/auth/login_screen.dart';
import '../features/auth/register_screen.dart';
import '../features/automations/automations_screen.dart';
import '../features/customers/customer_detail_screen.dart';
import '../features/customers/customer_form_screen.dart';
import '../features/customers/customers_screen.dart';
import '../features/dashboard/dashboard_screen.dart';
import '../features/estimates/estimate_detail_screen.dart';
import '../features/estimates/estimate_form_screen.dart';
import '../features/estimates/estimates_screen.dart';
import '../features/invoices/invoice_detail_screen.dart';
import '../features/invoices/invoices_screen.dart';
import '../features/more/more_screen.dart';
import '../features/payments/payments_screen.dart';
import '../features/reports/reports_screen.dart';
import '../features/schedule/schedule_screen.dart';
import '../features/services/services_screen.dart';
import '../features/service_requests/service_request_form_screen.dart';
import '../features/service_requests/service_requests_screen.dart';
import '../features/team/team_screen.dart';
import '../features/work_orders/work_order_detail_screen.dart';
import '../features/work_orders/work_orders_screen.dart';
import '../features/splash/splash_screen.dart';
import 'widgets/app_scaffold.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/splash',
    redirect: (context, state) {
      final loc = state.matchedLocation;
      final isAuthRoute = loc == '/login' || loc == '/register';
      final isSplash = loc == '/splash';

      // 1. While stored credentials are being restored, stay on splash screen (NO login flash!)
      if (!authState.isInitialized) {
        return isSplash ? null : '/splash';
      }

      // 2. If session check completed and NOT logged in -> redirect to login
      if (!authState.loggedIn) {
        return isAuthRoute ? null : '/login';
      }

      // 3. If session check completed and logged in -> redirect straight to dashboard
      if (authState.loggedIn && (isAuthRoute || isSplash)) {
        return '/dashboard';
      }

      return null;
    },
    routes: [
      // Splash route (Startup & session restoration)
      GoRoute(
        path: '/splash',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, __) => const SplashScreen(),
      ),

      // Auth routes (Full screen outside shell)
      GoRoute(
        path: '/login',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, __) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, __) => const RegisterScreen(),
      ),

      // Main Navigation Shell (Responsive BottomNav / NavigationRail)
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) {
          final loc = state.matchedLocation;
          int index = 0;
          if (loc.startsWith('/customers')) {
            index = 1;
          } else if (loc.startsWith('/schedule')) {
            index = 2;
          } else if (loc.startsWith('/work-orders')) {
            index = 3;
          } else if (loc.startsWith('/more')) {
            index = 4;
          }

          return AppScaffold(
            currentIndex: index,
            child: child,
          );
        },
        routes: [
          GoRoute(path: '/dashboard', builder: (_, __) => const DashboardScreen()),
          GoRoute(path: '/customers', builder: (_, __) => const CustomersScreen()),
          GoRoute(path: '/schedule', builder: (_, __) => const ScheduleScreen()),
          GoRoute(path: '/work-orders', builder: (_, __) => const WorkOrdersScreen()),
          GoRoute(path: '/more', builder: (_, __) => const MoreScreen()),
        ],
      ),

      // Detail & Form Routes (Full Screen stack)
      GoRoute(
        path: '/customers/new',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, state) => CustomerFormScreen(initialCustomer: state.extra as Map<String, dynamic>?),
      ),
      GoRoute(
        path: '/customers/:id',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, state) {
          final id = int.tryParse(state.pathParameters['id'] ?? '0') ?? 0;
          return CustomerDetailScreen(customerId: id);
        },
      ),

      // Service Requests
      GoRoute(
        path: '/service-requests',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, __) => const ServiceRequestsScreen(),
      ),
      GoRoute(
        path: '/service-requests/new',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, __) => const ServiceRequestFormScreen(),
      ),

      // Estimates
      GoRoute(
        path: '/estimates',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, __) => const EstimatesScreen(),
      ),
      GoRoute(
        path: '/estimates/new',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, __) => const EstimateFormScreen(),
      ),
      GoRoute(
        path: '/estimates/:id',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, state) {
          final id = int.tryParse(state.pathParameters['id'] ?? '0') ?? 0;
          return EstimateDetailScreen(estimateId: id);
        },
      ),

      // Work Orders Details
      GoRoute(
        path: '/work-orders/:id',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, state) {
          final id = int.tryParse(state.pathParameters['id'] ?? '0') ?? 0;
          return WorkOrderDetailScreen(workOrderId: id);
        },
      ),

      // Invoices
      GoRoute(
        path: '/invoices',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, __) => const InvoicesScreen(),
      ),
      GoRoute(
        path: '/invoices/:id',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, state) {
          final id = int.tryParse(state.pathParameters['id'] ?? '0') ?? 0;
          return InvoiceDetailScreen(invoiceId: id);
        },
      ),

      // Payments
      GoRoute(
        path: '/payments',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, __) => const PaymentsScreen(),
      ),

      // Services Catalog
      GoRoute(
        path: '/services',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, __) => const ServicesScreen(),
      ),

      // Team
      GoRoute(
        path: '/team',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, __) => const TeamScreen(),
      ),

      // Automations
      GoRoute(
        path: '/automations',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, __) => const AutomationsScreen(),
      ),

      // Reports
      GoRoute(
        path: '/reports',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, __) => const ReportsScreen(),
      ),
    ],
  );
});
