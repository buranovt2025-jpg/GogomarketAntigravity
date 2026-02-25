import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:network/network.dart';

final socketServiceProvider = Provider<SocketService>((ref) {
  const baseUrl = 'http://146.190.24.241';
  final service = SocketService(baseUrl: baseUrl);
  
  service.connect();
  
  ref.onDispose(() {
    service.dispose();
  });
  
  return service;
});

final notificationStreamProvider = StreamProvider<Map<String, dynamic>>((ref) {
  return ref.watch(socketServiceProvider).notifications;
});
