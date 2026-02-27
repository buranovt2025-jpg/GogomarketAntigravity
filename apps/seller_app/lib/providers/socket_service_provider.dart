import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:network/network.dart';

final socketServiceProvider = Provider<SocketService>((ref) {
  // Базовый URL без /api в конце, так как Socket.io сам добавляет путь если нужно
  // Но наш бэкенд на NestJS обычно слушает на корневом пути или через namespace
  const baseUrl = 'http://146.190.24.241';
  
  final service = SocketService(baseUrl: baseUrl);
  
  // Авто-коннект при создании провайдера
  service.connect();
  
  ref.onDispose(() {
    service.dispose();
  });
  
  return service;
});

final notificationStreamProvider = StreamProvider<Map<String, dynamic>>((ref) {
  return ref.watch(socketServiceProvider).notifications;
});
