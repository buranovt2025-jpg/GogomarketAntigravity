# GOGOMARKET Seller App

Flutter application for sellers on GOGOMARKET platform.

## Features

✅ **Authentication**
- Login with phone & password
- Registration for sellers
- JWT token management
- Auto token refresh

✅ **Dashboard**
- Sales statistics
- Orders overview
- Products count
- Balance display

✅ **Navigation**
- Bottom navigation (Dashboard, Products, Orders, Profile)
- Protected routes
- Deep linking support

## Architecture

- **State Management**: Riverpod
- **Routing**: GoRouter
- **HTTP Client**: Dio with interceptors
- **Storage**: Secure storage for tokens
- **UI**: Material 3 design

## Setup

```bash
# Install dependencies
flutter pub get

# Run the app
flutter run
```

## Configuration

Update `lib/core/constants/api_endpoints.dart` with your backend URL:

```dart
static const String baseUrl = 'http://YOUR_IP:3000/api';
```

## Project Structure

```
lib/
├── core/
│   ├── constants/          # API endpoints, constants
│   ├── router/             # GoRouter configuration
│   ├── services/           # API client, auth, storage
│   └── theme/              # App theme
├── features/
│   ├── auth/               # Login, register screens
│   ├── home/               # Dashboard with tabs
│   └── products/           # Product management
└── main.dart
```

## TODO

- [ ] Products CRUD
- [ ] Order management
- [ ] Image upload
- [ ] Stories creation
- [ ] Reels creation
- [ ] Chat
- [ ] Push notifications

## License

Proprietary - GOGOMARKET
