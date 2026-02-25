import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../features/deliveries/delivery_list_screen.dart';
import '../features/map/map_screen.dart';
import '../providers/auth_provider.dart';

// Заглушка для LoginScreen в courier_app
class CourierLoginScreen extends StatelessWidget {
  const CourierLoginScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('Courier Login (Use Buyer App UI logic)', style: TextStyle(color: Colors.white)),
      ),
    );
  }
}

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/deliveries',
    redirect: (context, state) {
      final isAuth = authState.isAuthenticated;
      final isLoggingIn = state.matchedLocation == '/login';

      if (!isAuth && !isLoggingIn) return '/login';
      if (isAuth && isLoggingIn) return '/deliveries';
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const CourierLoginScreen(),
      ),
      GoRoute(
        path: '/deliveries',
        builder: (context, state) => const DeliveryListScreen(),
      ),
      GoRoute(
        path: '/map/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          final address = state.uri.queryParameters['address'] ?? 'Адрес';
          return MapScreen(orderId: id, address: address);
        },
      ),
    ],
  );
});
