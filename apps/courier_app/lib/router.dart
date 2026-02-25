import 'package:go_router/go_router.dart';
import 'features/auth/login_screen.dart';
import 'features/deliveries/deliveries_screen.dart';
import 'features/chat/chat_screen.dart';

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
    GoRoute(
      path: '/chat/:id',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        final name = state.uri.queryParameters['name'] ?? 'Контакт';
        return ChatScreen(otherId: id, otherName: name);
      },
    ),
  ],
);
