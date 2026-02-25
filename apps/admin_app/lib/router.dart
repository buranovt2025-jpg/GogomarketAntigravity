import 'package:go_router/go_router.dart';
import 'features/auth/login_screen.dart';
import 'features/dashboard/admin_dashboard_screen.dart';
import 'features/users/users_screen.dart';
import 'features/moderation/moderation_screen.dart';

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
    GoRoute(
      path: '/users',
      builder: (context, state) => const UsersScreen(),
    ),
    GoRoute(
      path: '/moderation',
      builder: (context, state) => const ModerationScreen(),
    ),
  ],
);
