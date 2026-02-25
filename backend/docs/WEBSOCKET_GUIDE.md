# WebSocket Integration Guide

## 🔌 Real-Time Features

GOGOMARKET использует WebSocket (Socket.IO) для real-time уведомлений.

---

## 📡 Backend Setup

### Dependencies
```bash
npm install @nestjs/websockets @nestjs/platform-socket.io socket.io
```

### Gateway Configuration

WebSocket сервер запущен на порту приложения (по умолчанию 3000).

**Events:**
- `new-order` - новый заказ для продавца
- `order-status` - обновление статуса заказа
- `new-comment` - новый комментарий к Story
- `new-like` - новый лайк на Story

---

## 📱 Mobile Integration (Flutter)

### Add Dependency
```yaml
dependencies:
  socket_io_client: ^2.0.0
```

### Connect to WebSocket

```dart
import 'package:socket_io_client/socket_io_client.dart' as IO;

class WebSocketService {
  IO.Socket? socket;
  
  void connect(String userId) {
    socket = IO.io('http://localhost:3000', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': true,
    });

    socket?.onConnect((_) {
      print('Connected to WebSocket');
      
      // Register user
      socket?.emit('register', userId);
    });

    socket?.onDisconnect((_) => print('Disconnected'));

    // Listen for notifications
    socket?.on('new-order', (data) {
      print('New order: $data');
      // Show notification
    });

    socket?.on('order-status', (data) {
      print('Order status updated: $data');
      // Update UI
    });

    socket?.on('new-comment', (data) {
      print('New comment: $data');
      // Show notification
    });

    socket?.on('new-like', (data) {
      print('New like: $data');
      // Update UI
    });
  }

  void disconnect() {
    socket?.disconnect();
    socket = null;
  }
}
```

### Usage in App

```dart
class MyApp extends ConsumerWidget {
  final webSocketService = WebSocketService();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userId = ref.watch(authProvider)?.userId;

    useEffect(() {
      if (userId != null) {
        webSocketService.connect(userId);
      }
      
      return () => webSocketService.disconnect();
    }, [userId]);

    return MaterialApp(/* ... */);
  }
}
```

---

## 🔔 Notification Types

### 1. New Order Notification
**Event:** `new-order`

Payload:
```json
{
  "orderId": "uuid",
  "message": "You have a new order!",
  "timestamp": "2024-02-09T00:00:00Z"
}
```

### 2. Order Status Update
**Event:** `order-status`

Payload:
```json
{
  "orderId": "uuid",
  "status": "confirmed",
  "timestamp": "2024-02-09T00:00:00Z"
}
```

### 3. New Comment
**Event:** `new-comment`

Payload:
```json
{
  "storyId": "uuid",
  "commentId": "uuid",
  "message": "Someone commented on your story!",
  "timestamp": "2024-02-09T00:00:00Z"
}
```

### 4. New Like
**Event:** `new-like`

Payload:
```json
{
  "storyId": "uuid",
  "message": "Someone liked your story!",
  "timestamp": "2024-02-09T00:00:00Z"
}
```

---

## 🧪 Testing WebSocket

### Using Socket.IO Client (Browser)
```html
<script src="https://cdn.socket.io/4.5.4/socket.io.min.js"></script>
<script>
  const socket = io('http://localhost:3000');
  
  socket.on('connect', () => {
    console.log('Connected');
    socket.emit('register', 'test-user-id');
  });
  
  socket.on('new-order', (data) => {
    console.log('New order:', data);
  });
</script>
```

### Using curl (not recommended for WS, but for testing HTTP endpoint)
```bash
curl http://localhost:3000/health
```

---

## 🔐 Security Considerations

### Production Recommendations:
1. **Authentication**: Add JWT verification to WebSocket connection
2. **CORS**: Limit origins in production
3. **Rate Limiting**: Prevent spam
4. **Data Validation**: Validate all incoming events

### Enhanced Gateway with Auth:
```typescript
@WebSocketGateway({
  cors: {
    origin: process.env.CORS_ORIGIN?.split(',') || ['http://localhost'],
    credentials: true,
  },
})
export class NotificationsGateway {
  @UseGuards(WsJwtGuard)
  @SubscribeMessage('register')
  handleRegister(client: Socket, userId: string) {
    // Verify JWT before registering
  }
}
```

---

## 📊 Monitoring

### Health Check
```bash
# Check if WebSocket server is running
curl http://localhost:3000/health
```

Response:
```json
{
  "status": "ok",
  "timestamp": "2024-02-09T00:00:00Z",
  "uptime": 12345,
  "environment": "production",
  "version": "1.0.0"
}
```

---

## 🚀 Production Deployment

### Nginx WebSocket Proxy
```nginx
location /socket.io/ {
    proxy_pass http://localhost:3000;
    proxy_http_version 1.1;
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection "upgrade";
    proxy_set_header Host $host;
    proxy_cache_bypass $http_upgrade;
}
```

### Load Balancing (Redis Adapter)
```bash
npm install @socket.io/redis-adapter redis
```

```typescript
import { createAdapter } from '@socket.io/redis-adapter';
import { createClient } from 'redis';

const pubClient = createClient({ url: 'redis://localhost:6379' });
const subClient = pubClient.duplicate();

await Promise.all([pubClient.connect(), subClient.connect()]);

io.adapter(createAdapter(pubClient, subClient));
```

---

**WebSocket Integration v1.0 - GOGOMARKET Platform**
