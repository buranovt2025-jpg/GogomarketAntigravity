# GOGOMARKET Mobile Applications

Flutter applications for all user roles.

## Applications

### 1. Seller App (`seller/`)
For merchants managing their stores.
- **Features**: Product management, order tracking, sales analytics, Stories/Reels creation
- **Color**: Purple (#6C5CE7)

### 2. Buyer App (`buyer/`)
For customers shopping on the platform.
- **Features**: Product browsing, shopping cart, Reels feed, order tracking
- **Color**: Purple (#6C5CE7)

### 3. Courier App (`courier/`)
For delivery personnel.
- **Features**: Order assignments, GPS navigation, earnings tracking
- **Color**: Green (#00B894)

### 4. Admin App (`admin/`)
For platform administrators.
- **Features**: Dashboard, user management, content moderation, analytics
- **Color**: Red (#E74C3C)

## Quick Start

Each app can be run independently:

```bash
# Seller App
cd seller
flutter pub get
flutter run

# Buyer App
cd buyer
flutter pub get
flutter run

# Courier App
cd courier
flutter pub get
flutter run

# Admin App
cd admin
flutter pub get
flutter run
```

## Architecture

All apps share similar architecture:
- **State Management**: Riverpod
- **Routing**: GoRouter
- **HTTP**: Dio
- **UI**: Material 3

## Configuration

Update API endpoint in each app:
`lib/core/constants/api_endpoints.dart` (where applicable)

## Platform Support

- ✅ Android
- ✅ iOS
- 🚧 Web (coming soon)

## License

Proprietary - GOGOMARKET
