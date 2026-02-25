import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:network/socket_service.dart';

class MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {}

void main() {
  late MockFlutterSecureStorage mockStorage;
  late SocketService socketService;
  const baseUrl = 'http://test.com';

  setUp(() {
    mockStorage = MockFlutterSecureStorage();
    socketService = SocketService(baseUrl: baseUrl, storage: mockStorage);
  });

  group('SocketService Tests', () {
    test('connect() does nothing if token is missing', () async {
      when(() => mockStorage.read(key: 'access_token')).thenAnswer((_) async => null);

      await socketService.connect();

      // Should not attempt to connect if token is null
      verify(() => mockStorage.read(key: 'access_token')).called(1);
    });

    test('notifications stream is broadcast', () {
      expect(socketService.notifications.isBroadcast, isTrue);
    });

    test('messages stream is broadcast', () {
      expect(socketService.messages.isBroadcast, isTrue);
    });
  });
}
