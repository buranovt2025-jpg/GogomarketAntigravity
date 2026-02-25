import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:network/network.dart';

/// Singleton ApiClient — один экземпляр для всего приложения
final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient();
});
