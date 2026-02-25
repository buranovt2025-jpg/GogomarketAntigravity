# 🛍️ GOGOMARKET - Social E-Commerce Platform

[![License](https://img.shields.io/badge/license-Proprietary-blue.svg)](LICENSE)
[![Backend](https://img.shields.io/badge/backend-NestJS-red.svg)](backend/)
[![Mobile](https://img.shields.io/badge/mobile-Flutter-blue.svg)](mobile/)
[![Status](https://img.shields.io/badge/status-Production%20Ready-green.svg)]()

> **Первая social e-commerce платформа для Узбекистана**, объединяющая TikTok-style Stories с полноценным маркетплейсом.

---

## 📋 Содержание

- [О проекте](#о-проекте)
- [Возможности](#возможности)
- [Технологический стек](#технологический-стек)
- [Быстрый старт](#быстрый-старт)
- [Структура проекта](#структура-проекта)
- [Документация](#документация)
- [Deployment](#deployment)

---

## 🎯 О проекте

**GOGOMARKET** - инновационная платформа для современной электронной коммерции в Узбекистане:

- 🎬 **TikTok-style Stories** - вертикальные видео для showcasing товаров
- 🛒 **Full E-Commerce** - от каталога до оплаты
- 💳 **Местные платежи** - Payme & Click интеграция
- 📱 **4 Mobile Apps** - Seller, Buyer, Courier, Admin
- 🔔 **Real-time** - WebSocket notifications
- 💬 **Social Features** - Комментарии, лайки, engagement

### Статистика проекта

- **~270 файлов** кода
- **~15,500 строк** (TypeScript + Dart)
- **45+ REST API** endpoints
- **12+ database** tables
- **10 backend** модулей
- **4 mobile** приложения

---

## ✨ Возможности

### 🏪 E-Commerce Core
- Product catalog с search & filters
- Shopping cart management
- Order lifecycle management
- Stock tracking
- Platform commission (10%)

### 💳 Payment Integration
- **Payme** - JSON-RPC, webhooks
- **Click** - prepare/complete flow
- Signature verification
- Transaction tracking

### 📹 Social Features
- **Stories/Reels** - vertical video (TikTok-style)
- Feed algorithm (recent + popular)
- Likes & Views tracking
- Comments с replies
- Seller statistics

### 🔔 Real-time Features
- WebSocket notifications
- Order status updates
- New comment alerts

---

## 🛠️ Технологический стек

### Backend
```
NestJS 10+ | TypeScript | PostgreSQL 14+
TypeORM | JWT Auth | Swagger | Socket.IO
```

### Mobile
```
Flutter 3.0+ | Dart | Riverpod | GoRouter
Dio | Video Player | Secure Storage
```

### DevOps
```
Docker | Docker Compose | GitHub Actions
Nginx | PM2 | PostgreSQL | Redis
```

---

## 🚀 Быстрый старт

### Prerequisites
- Node.js 18+
- PostgreSQL 14+
- Flutter 3.0+ (для mobile apps)
- Docker (опционально)

### Option 1: Docker (Recommended)

```bash
# Clone repository
git clone https://github.com/your-org/gogomarket.git
cd gogomarket/backend

# Configure environment
cp .env.production.example .env
# Edit .env with your credentials

# Start services
docker-compose up -d

# Check health
curl http://localhost:3000/health
```

### Option 2: Manual Setup

**Backend:**
```bash
cd backend
npm install
cp .env.example .env
# Edit .env

npm run start:dev
# API: http://localhost:3000
# Swagger: http://localhost:3000/api
```

**Mobile Apps:**
```bash
# Seller App
cd mobile/seller
flutter pub get
flutter run

# Buyer App
cd mobile/buyer
flutter pub get
flutter run
```

---

## 📁 Структура проекта

```
gogomarket/
├── backend/                  # NestJS Backend API
│   ├── src/
│   │   ├── modules/         # Feature modules
│   │   │   ├── auth/        # Authentication
│   │   │   ├── users/       # User management
│   │   │   ├── products/    # Product catalog
│   │   │   ├── orders/      # Order management
│   │   │   ├── payments/    # Payme & Click
│   │   │   ├── stories/     # Stories/Reels
│   │   │   ├── comments/    # Comments system
│   │   │   └── notifications/ # WebSocket
│   │   └── health/          # Health checks
│   ├── docs/                # API documentation
│   └── docker-compose.yml
│
├── mobile/
│   ├── seller/              # Seller mobile app
│   ├── buyer/               # Buyer mobile app
│   ├── courier/             # Courier app
│   └── admin/               # Admin app
│
├── .github/workflows/       # CI/CD pipeline
├── DEPLOYMENT.md            # Deployment guide
├── PROJECT_SUMMARY.md       # Comprehensive summary
└── README.md               # This file
```

---

## 📚 Документация

### API Documentation
- **[Swagger UI](http://localhost:3000/api)** - Interactive API docs
- **[Payment Integration](backend/docs/PAYMENT_INTEGRATION.md)** - Payme & Click
- **[Stories API](backend/docs/STORIES_API.md)** - Stories/Reels
- **[WebSocket Guide](backend/docs/WEBSOCKET_GUIDE.md)** - Real-time

### Project Guides
- **[Quick Start](QUICK_START.md)** - 5-minute setup
- **[Deployment Guide](DEPLOYMENT.md)** - Production deployment
- **[Project Summary](PROJECT_SUMMARY.md)** - Complete overview

---

## 🚢 Deployment

### Quick Deploy (Digital Ocean)

```bash
# Clone & setup
git clone https://github.com/your-org/gogomarket.git
cd gogomarket/backend
cp .env.production.example .env
nano .env  # Edit with production values

# Start with Docker
docker-compose up -d

# Check status
curl http://localhost:3000/health
```

**Подробнее:** [DEPLOYMENT.md](DEPLOYMENT.md)

---

## 📊 API Endpoints

### Authentication
- `POST /auth/register` - Register
- `POST /auth/login` - Login
- `POST /auth/refresh` - Refresh token

### Products
- `GET /products` - List products
- `POST /products` - Create product
- `PUT /products/:id` - Update product

### Orders
- `POST /orders` - Create order
- `GET /orders` - List orders
- `PATCH /orders/:id/status` - Update status

### Stories
- `GET /stories/feed` - Get feed
- `POST /stories` - Create story
- `POST /stories/:id/like` - Toggle like

**Полная документация:** http://localhost:3000/api

---

## 🔐 Environment Variables

```env
# Database
DATABASE_HOST=localhost
DATABASE_PORT=5432
DATABASE_USERNAME=postgres
DATABASE_PASSWORD=your-password
DATABASE_NAME=gogomarket

# JWT
JWT_SECRET=your-secret-min-32-chars
JWT_REFRESH_SECRET=your-refresh-secret

# Payme
PAYME_MERCHANT_ID=your-merchant-id
PAYME_SECRET_KEY=your-secret-key

# Click
CLICK_MERCHANT_ID=your-merchant-id
CLICK_SECRET_KEY=your-secret-key
```

**Полный список:** [.env.production.example](backend/.env.production.example)

---

## 📞 Support

- **Documentation**: [docs/](docs/)
- **Issues**: GitHub Issues
- **Email**: support@gogomarket.uz

---

## 📄 License

Proprietary - © 2024 GOGOMARKET Team

---

**Built with ❤️ for Uzbekistan market**

*Last updated: 2026-02-09*
