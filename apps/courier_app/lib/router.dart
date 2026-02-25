import 'package:go_router/go_router.dart';
import 'features/auth/login_screen.dart';
import 'features/deliveries/deliveries_screen.dart';

final GoRouter courierRouter = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(
      path: '/login',
      builder: (context, state) => const CourierLoginScreen(),
    ),
    GoRoute(
      path: '/deliveries',
      builder: (context, state) => const DeliveriesScreen(),
    ),
  ],
);
