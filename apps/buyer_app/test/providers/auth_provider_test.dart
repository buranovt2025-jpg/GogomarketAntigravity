import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:network/network.dart';
import 'package:core/core.dart';
import 'package:buyer_app/providers/auth_provider.dart';
import 'package:buyer_app/providers/api_client_provider.dart';

class MockApiClient extends Mock implements ApiClient {}

void main() {
  late MockApiClient mockApiClient;
  late ProviderContainer container;

  setUp(() {
    mockApiClient = MockApiClient();
    container = ProviderContainer(
      overrides: [
        apiClientProvider.overrideWithValue(mockApiClient),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('AuthNotifier Tests', () {
    test('Initial state is unauthenticated', () {
      final state = container.read(authProvider);
      expect(state.user, isNull);
      expect(state.isLoading, isFalse);
      expect(state.isAuthenticated, isFalse);
    });

    test('login success updates state with user', () async {
      final userData = {
        'id': '1',
        'phone': '+998901234567',
        'role': 'BUYER',
        'buyerProfile': {'name': 'Test User'}
      };

      when(() => mockApiClient.login(
            phone: any(named: 'phone'),
            password: any(named: 'password'),
          )).thenAnswer((_) async => {'accessToken': 'test_token'});

      when(() => mockApiClient.getMe()).thenAnswer((_) async => userData);

      final notifier = container.read(authProvider.notifier);
      final result = await notifier.login(phone: '+998901234567', password: 'password');

      expect(result, isTrue);
      final state = container.read(authProvider);
      expect(state.user, isNotNull);
      expect(state.user!.name, 'Test User');
      expect(state.isAuthenticated, isTrue);
      expect(state.isLoading, isFalse);
    });

    test('login failure sets error message', () async {
      when(() => mockApiClient.login(
            phone: any(named: 'phone'),
            password: any(named: 'password'),
          )).thenThrow(Exception('401 Unauthorized'));

      final notifier = container.read(authProvider.notifier);
      final result = await notifier.login(phone: '+998901234567', password: 'password');

      expect(result, isFalse);
      final state = container.read(authProvider);
      expect(state.user, isNull);
      expect(state.error, contains('Неверный телефон или пароль'));
      expect(state.isLoading, isFalse);
    });

    test('logout clears user state', () async {
      when(() => mockApiClient.logout()).thenAnswer((_) async => {});

      final notifier = container.read(authProvider.notifier);
      await notifier.logout();

      final state = container.read(authProvider);
      expect(state.user, isNull);
      expect(state.isAuthenticated, isFalse);
    });
  });
}
