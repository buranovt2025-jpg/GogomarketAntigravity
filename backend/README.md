# GOGOMARKET Backend

Production-ready NestJS backend for GOGOMARKET social e-commerce platform.

## 🚀 Quick Start

### Prerequisites
- Node.js 18+ 
- Docker & Docker Compose
- PostgreSQL 15+
- Redis 7+

### Installation

```bash
# 1. Install dependencies
npm install

# 2. Copy environment file
cp .env.example .env

# 3. Start PostgreSQL and Redis
docker-compose up -d

# 4. Start development server
npm run start:dev
```

The API will be available at:
- **API**: http://localhost:3000/api
- **Swagger Docs**: http://localhost:3000/api/docs

## 📂 Project Structure

```
backend/
├── src/
│   ├── modules/
│   │   ├── auth/              # Authentication (JWT, Register, Login)
│   │   ├── users/             # User management (Seller/Buyer profiles)
│   │   ├── products/          # Products & Categories
│   │   └── media/             # File uploads (S3)
│   ├── main.ts                # Application entry point
│   └── app.module.ts          # Root module
├── docker-compose.yml         # Local dev environment
└── package.json
```

## ✅ Implemented Features

### 🔐 Authentication
- ✅ Registration (all roles: seller, buyer, courier, admin)
- ✅ Login with JWT tokens
- ✅ Refresh tokens
- ✅ Role-based access control
- ✅ Password hashing (bcrypt)

### 👥 Users
- ✅ User profiles (all roles)
- ✅ Seller profiles (full & simplified cabinets)
- ✅ Buyer profiles
- ✅ Profile management

### 📦 Products
- ✅ CRUD operations
- ✅ Search & filters
- ✅ Pagination & sorting
- ✅ Categories (multilingual)
- ✅ Stock management
- ✅ Seller-only access

### 🛒 Orders
- ✅ Create order with multiple items
- ✅ Order status management (pending → delivered)
- ✅ Payment status tracking
- ✅ Delivery address management
- ✅ Stock deduction on order
- ✅ Order statistics for sellers
- ✅ Courier assignment
- ✅ Order cancellation with stock restoration

### 💳 Payments
- ✅ Payment link generation (Payme, Click)
- ✅ Payme integration (JSON-RPC callbacks)
- ✅ Click integration (prepare/complete)
- ✅ Transaction tracking
- ✅ Signature verification
- ✅ Automatic order status updates on payment
- ✅ Payment webhooks

### 📹 Stories/Reels
- ✅ Vertical video stories (TikTok-style)
- ✅ Feed algorithm (recent + popular)
- ✅ Likes and views tracking
- ✅ Product linking in stories
- ✅ Watch duration analytics
- ✅ Seller statistics

### 📸 Media
- ✅ Image upload with compression
- ✅ Thumbnail generation
- ✅ S3/Local storage support
- ✅ Video upload supportad
- ✅ S3-compatible storage (Digital Ocean Spaces)
- ✅ File deletion

## 🔐 API Examples

### Register Seller

```bash
POST /api/auth/register
Content-Type: application/json

{
  "phone": "+998901234567",
  "password": "Password123!",
  "role": "seller",
  "storeName": "My Store",
  "cabinetType": "full"
}
```

### Create Product

```bash
POST /api/products
Authorization: Bearer YOUR_ACCESS_TOKEN
Content-Type: application/json

{
  "name": "iPhone 15 Pro",
  "description": "Latest iPhone",
  "price": 1299.99,
  "categoryId": "category-uuid",
  "stockQuantity": 10,
  "images": ["url1.jpg", "url2.jpg"]
}
```

### Upload Image

```bash
POST /api/media/upload/image
Authorization: Bearer YOUR_ACCESS_TOKEN
Content-Type: multipart/form-data

file: (binary)
```

### Search Products

```bash
GET /api/products/search?q=iphone&minPrice=1000&maxPrice=2000&page=1&limit=20
```

## 🗂️ Database Entities

### User
- UUID primary key
- Phone number (unique)
- Email (optional, unique)
- Password hash
- Role (enum)
- Verification & block status

### SellerProfile
- Cabinet type (full/simplified)
- Store name & description
- Category (for simplified)
- Verification status
- Balance & total sales
- Rating system
- Followers count

### Product
- Name, description, price
- Old price (for discounts)
- Category relation
- Images (array)
- Video URL (optional)
- Stock quantity
- Rating & reviews
- Views & orders count
- Active status

### Category
- Multilingual names (RU, UZ, EN)
- Slug (unique)
- Parent category support
- Icon & order

## 🛠️ Available Scripts

```bash
npm run start:dev      # Start development server with watch
npm run build          # Build for production
npm run start:prod     # Start production server
npm run test           # Run unit tests
npm run test:e2e       # Run E2E tests
```

## 🔧 Environment Variables

See `.env.example` for all configuration options including:
- Database connection
- JWT secrets
- S3/Spaces credentials
- Payment systems (Payme, Click)
- SMS service (Eskiz.uz)

## 🐛 Testing with Swagger

Visit http://localhost:3000/api/docs for interactive API documentation.

All endpoints are documented with:
- Request/response schemas
- Authentication requirements
- Example values
- Error responses

## 📝 TODO (Next Steps)

- [x] Product management endpoints
- [x] Order system
- [ ] Payment integration (Payme, Click)
- [ ] Stories & Reels
- [ ] Chat (WebSocket)
- [ ] Courier module
- [ ] Admin panel
- [ ] SMS verification
- [ ] Push notifications

## 📄 License

Proprietary - GOGOMARKET
