import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'seller_auth_provider.dart';
import 'seller_api_client_provider.dart';
import 'socket_service_provider.dart';

class ChatMessage {
  final String id;
  final String senderId;
  final String recipientId;
  final String content;
  final DateTime createdAt;

  ChatMessage({
    required this.id,
    required this.senderId,
    required this.recipientId,
    required this.content,
    required this.createdAt,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id']?.toString() ?? '',
      senderId: json['senderId']?.toString() ?? '',
      recipientId: json['recipientId']?.toString() ?? '',
      content: json['content']?.toString() ?? '',
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

class ChatState {
  final List<ChatMessage> messages;
  final bool isLoading;
  final String? error;

  ChatState({
    this.messages = const [],
    this.isLoading = false,
    this.error,
  });

  ChatState copyWith({
    List<ChatMessage>? messages,
    bool? isLoading,
    String? error,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class ChatNotifier extends StateNotifier<ChatState> {
  final Ref _ref;
  final String otherId;

  ChatNotifier(this._ref, this.otherId) : super(ChatState()) {
    _init();
  }

  void _init() {
    // 1. Load history
    loadHistory();

    // 2. Join socket chat
    final user = _ref.read(sellerAuthProvider).user;
    if (user != null) {
      _ref.read(socketServiceProvider).joinChat(user.id);
    }

    // 3. Listen for live messages
    _ref.listen(socketServiceProvider, (prev, next) {
      // Handle socket service changes if needed
    });

    _ref.read(socketServiceProvider).messages.listen((data) {
      final msg = ChatMessage.fromJson(data);
      // Add message if it's from the person we are chatting with
      if (msg.senderId == otherId || msg.recipientId == otherId) {
        state = state.copyWith(messages: [...state.messages, msg]);
      }
    });
  }

  Future<void> loadHistory() async {
    state = state.copyWith(isLoading: true);
    try {
      final api = _ref.read(sellerApiClientProvider);
      final res = await api.dio.get('/chat/history/$otherId');
      final list = (res.data as List).map((e) => ChatMessage.fromJson(e)).toList();
      state = state.copyWith(messages: list, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void sendMessage(String content) {
    final user = _ref.read(sellerAuthProvider).user;
    if (user == null) return;

    _ref.read(socketServiceProvider).sendMessage(otherId, content, user.id);
    
    // Optimistic UI update (or wait for socket back-emit)
    // Here we wait for back-emit from socket to ensure synchronization
  }
}

// Провайдер для конкретного чата (id собеседника передается как параметр)
final chatProvider = StateNotifierProvider.family<ChatNotifier, ChatState, String>((ref, otherId) {
  return ChatNotifier(ref, otherId);
});
