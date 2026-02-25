import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:network/network.dart';

/// Singleton ApiClient для seller_app (тот же backend)
final sellerApiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient();
});
