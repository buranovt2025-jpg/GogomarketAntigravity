import 'package:go_router/go_router.dart';
import 'features/auth/login_screen.dart';
import 'features/dashboard/admin_dashboard_screen.dart';

final GoRouter adminRouter = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(
      path: '/login',
      builder: (context, state) => const AdminLoginScreen(),
    ),
    GoRoute(
      path: '/dashboard',
      builder: (context, state) => const AdminDashboardScreen(),
    ),
  ],
);
