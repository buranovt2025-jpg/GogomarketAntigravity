import 'dart:async';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SocketService {
  final String baseUrl;
  final FlutterSecureStorage _storage;
  
  io.Socket? _notificationsSocket;
  io.Socket? _chatSocket;

  final _notificationController = StreamController<Map<String, dynamic>>.broadcast();
  final _messageController = StreamController<Map<String, dynamic>>.broadcast();

  Stream<Map<String, dynamic>> get notifications => _notificationController.stream;
  Stream<Map<String, dynamic>> get messages => _messageController.stream;

  SocketService({
    required this.baseUrl,
    FlutterSecureStorage? storage,
  }) : _storage = storage ?? const FlutterSecureStorage();

  Future<void> connect() async {
    final token = await _storage.read(key: 'access_token');
    if (token == null) return;

    // 1. Notifications Socket (Root namespace)
    _notificationsSocket = io.io(baseUrl, 
      io.OptionBuilder()
        .setTransports(['websocket'])
        .setQuery({'token': token})
        .enableAutoConnect()
        .build()
    );

    _notificationsSocket?.onConnect((_) {
      print('Connected to Notifications Socket');
    });

    _notificationsSocket?.on('new-order', (data) => _notificationController.add(data as Map<String, dynamic>));
    _notificationsSocket?.on('order-status', (data) => _notificationController.add(data as Map<String, dynamic>));

    // 2. Chat Socket (/chat namespace)
    _chatSocket = io.io('$baseUrl/chat', 
      io.OptionBuilder()
        .setTransports(['websocket'])
        .setQuery({'token': token})
        .enableAutoConnect()
        .build()
    );

    _chatSocket?.onConnect((_) {
      print('Connected to Chat Socket');
    });

    _chatSocket?.on('new-message', (data) => _messageController.add(data as Map<String, dynamic>));
  }

  void sendMessage(String recipientId, String content, String senderId) {
    _chatSocket?.emit('send-message', {
      'recipientId': recipientId,
      'senderId': senderId,
      'content': content,
    });
  }

  void joinChat(String userId) {
    _chatSocket?.emit('join', {'userId': userId});
  }

  void disconnect() {
    _notificationsSocket?.disconnect();
    _chatSocket?.disconnect();
    _notificationsSocket = null;
    _chatSocket = null;
  }

  void dispose() {
    disconnect();
    _notificationController.close();
    _messageController.close();
  }
}
