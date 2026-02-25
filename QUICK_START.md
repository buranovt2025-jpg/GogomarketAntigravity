# GOGOMARKET - Quick Start Guide

## 🚀 Быстрый старт за 5 минут

### 1️⃣ Prerequisites
```bash
# Установите:
- Node.js 18+ (Backend)
- PostgreSQL 14+ (Database)
- Flutter 3.0+ (Mobile)
```

### 2️⃣ Backend Setup
```bash
cd C:\Users\buran\.gemini\antigravity\scratch\gogomarket\backend

# Install
npm install

# Configure .env
cp .env.example .env
# Открыть .env и настроить:
# - DATABASE_HOST=localhost
# - DATABASE_PORT=5432
# - DATABASE_USERNAME=postgres
# - DATABASE_PASSWORD=your_password
# - DATABASE_NAME=gogomarket
# - JWT_SECRET=your-super-secret-key

# Create database
psql -U postgres -c "CREATE DATABASE gogomarket;"

# Start server
npm run start:dev

# ✅ API running on http://localhost:3000
# ✅ Swagger docs: http://localhost:3000/api
```

### 3️⃣ Mobile Apps Setup

**Seller App:**
```bash
cd C:\Users\buran\.gemini\antigravity\scratch\gogomarket\mobile\seller
flutter pub get
flutter run
```

**Buyer App:**
```bash
cd C:\Users\buran\.gemini\antigravity\scratch\gogomarket\mobile\buyer
flutter pub get
flutter run
```

### 4️⃣ Test the Platform

**Create a Seller:**
```bash
# POST http://localhost:3000/api/auth/register
{
  "phone": "+998901234567",
  "password": "password123",
  "role": "seller",
  "sellerProfile": {
    "cabinetType": "individual",
    "businessName": "My Store"
  }
}
```

**Create a Product:**
```bash
# POST http://localhost:3000/api/products
# Authorization: Bearer <token>
{
  "name": "iPhone 15 Pro",
  "description": "Latest model",
  "price": 15000000,
  "stockQuantity": 10
}
```

**Create a Story:**
```bash
# POST http://localhost:3000/api/stories
# Authorization: Bearer <token>
{
  "videoUrl": "https://example.com/video.mp4",
  "description": "Check this out!",
  "duration": 15
}
```

---

## 📱 Mobile Testing

### Seller App Flow:
1. **Register** → Choose "Individual" or "Company"
2. **Login** → Phone + Password
3. **Add Product** → Upload photos, set price
4. **View Orders** → Track customer orders

### Buyer App Flow:
1. **Browse Catalog** → Search products
2. **Add to Cart** → Tap "+" on product cards
3. **Checkout** → Fill delivery details
4. **Place Order** → Complete purchase

---

## 🔧 Common Issues

**Backend won't start:**
```bash
# Check PostgreSQL is running:
psql -U postgres -c "SELECT 1"

# Check .env configuration
cat .env
```

**Mobile build fails:**
```bash
# Clear cache
flutter clean
flutter pub get

# Update Flutter
flutter upgrade
```

**Payment webhooks testing:**
```bash
# Use ngrok for local testing
ngrok http 3000
# Update Payme/Click dashboard with ngrok URL
```

---

## 📚 Documentation

- [Full Walkthrough](file:///C:/Users/buran/.gemini/antigravity/brain/23ad6c1e-7f43-49b9-9c86-d1ecef8fcc3f/walkthrough.md) - Complete platform overview
- [Implementation Plan](file:///C:/Users/buran/.gemini/antigravity/brain/23ad6c1e-7f43-49b9-9c86-d1ecef8fcc3f/implementation_plan.md) - Technical details
- [Payment Integration](file:///C:/Users/buran/.gemini/antigravity/scratch/gogomarket/backend/docs/PAYMENT_INTEGRATION.md) - Payme & Click
- [Stories API](file:///C:/Users/buran/.gemini/antigravity/scratch/gogomarket/backend/docs/STORIES_API.md) - Reels endpoints

---

## 🎯 Next Steps

1. Configure payment gateways (Payme, Click)
2. Setup S3/Spaces for media storage
3. Customize UI theme colors
4. Add more products and test orders
5. Deploy to production (Digital Ocean)

---

**Platform ready to use! 🎉**
