# Deployment Guide - GOGOMARKET Platform

## 🚀 Quick Deployment Steps

### Option 1: Docker Compose (Recommended for development/staging)

```bash
# 1. Clone repository
git clone https://github.com/your-org/gogomarket.git
cd gogomarket/backend

# 2. Configure environment
cp .env.production.example .env
# Edit .env with your credentials

# 3. Start services
docker-compose up -d

# 4. Check health
curl http://localhost:3000/health

# 5. View logs
docker-compose logs -f backend
```

### Option 2: Manual Deployment (Production)

#### Prerequisites
- Node.js 18+
- PostgreSQL 14+
- Redis 7+ (optional)
- Nginx (reverse proxy)

#### Backend Deployment

```bash
# 1. Install dependencies
cd backend
npm ci --only=production

# 2. Build application
npm run build

# 3. Run migrations
npm run migration:run

# 4. Start with PM2
npm install -g pm2
pm2 start dist/main.js --name gogomarket-api
pm2 save
pm2 startup
```

#### Mobile Apps Deployment

```bash
# Build Android APKs
cd mobile/seller
flutter build apk --release

cd ../buyer
flutter build apk --release

# Build iOS (on macOS)
flutter build ios --release
```

---

## 🔧 Production Configuration

### Nginx Configuration

```nginx
server {
    listen 80;
    server_name api.gogomarket.uz;
    
    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }
    
    # File upload size limit
    client_max_body_size 50M;
}
```

### SSL Certificate (Let's Encrypt)

```bash
sudo apt update
sudo apt install certbot python3-certbot-nginx
sudo certbot --nginx -d api.gogomarket.uz
```

---

## 📊 Database Setup

### PostgreSQL Production Setup

```sql
-- Create database
CREATE DATABASE gogomarket_prod;

-- Create user
CREATE USER gogomarket_user WITH ENCRYPTED PASSWORD 'your-password';

-- Grant privileges
GRANT ALL PRIVILEGES ON DATABASE gogomarket_prod TO gogomarket_user;

-- Enable extensions
\c gogomarket_prod
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
```

### Database Backups

```bash
# Daily backup script
#!/bin/bash
BACKUP_DIR="/var/backups/postgres"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
pg_dump -U gogomarket_user gogomarket_prod > $BACKUP_DIR/gogomarket_$TIMESTAMP.sql
gzip $BACKUP_DIR/gogomarket_$TIMESTAMP.sql

# Keep only last 7 days
find $BACKUP_DIR -name "*.sql.gz" -mtime +7 -delete
```

Add to crontab:
```bash
0 2 * * * /path/to/backup-script.sh
```

---

## 🔐 Security Checklist

- [ ] Change all default passwords
- [ ] Generate strong JWT secrets (min 32 characters)
- [ ] Enable HTTPS (SSL certificates)
- [ ] Configure firewall (UFW/iptables)
- [ ] Set up rate limiting
- [ ] Enable CORS for specific domains only
- [ ] Regular security updates
- [ ] Database backups configured
- [ ] Environment variables secured
- [ ] API keys rotated regularly

---

## 📈 Monitoring Setup

### PM2 Monitoring

```bash
# Install PM2+
pm2 install pm2-server-monit

# Monitor CPU/Memory
pm2 monit

# View metrics
pm2 web
```

### Log Aggregation (Optional)

```bash
# Winston + Papertrail/Sentry integration
npm install winston winston-papertrail
```

---

## 🌍 Digital Ocean Deployment

### 1. Create Droplet
- Ubuntu 22.04 LTS
- 2GB RAM / 2 vCPUs (minimum)
- Choose closest data center

### 2. Initial Server Setup

```bash
# SSH into droplet
ssh root@your-droplet-ip

# Update system
apt update && apt upgrade -y

# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh

# Install Docker Compose
apt install docker-compose -y

# Create deploy user
adduser deploy
usermod -aG sudo deploy
usermod -aG docker deploy
```

### 3. Deploy Application

```bash
# Switch to deploy user
su - deploy

# Clone repository
git clone https://github.com/your-org/gogomarket.git
cd gogomarket/backend

# Setup environment
cp .env.production.example .env
nano .env  # Edit with production values

# Start services
docker-compose up -d

# Check status
docker-compose ps
docker-compose logs -f
```

---

## 📱 Mobile App Distribution

### Google Play Store

1. **Prepare Release**
   ```bash
   cd mobile/buyer
   flutter build appbundle --release
   ```

2. **Sign APK** (keystore setup required)
   ```bash
   keytool -genkey -v -keystore ~/gogomarket.jks -keyalg RSA -keysize 2048 -validity 10000 -alias gogomarket
   ```

3. **Upload to Play Console**
   - Create app listing
   - Upload app bundle
   - Fill store listing details
   - Submit for review

### Apple App Store (iOS)

1. **Build for iOS**
   ```bash
   cd mobile/buyer
   flutter build ios --release
   ```

2. **Archive in Xcode**
   - Open `ios/Runner.xcworkspace`
   - Product → Archive
   - Distribute App → App Store Connect

---

## 🔄 CI/CD with GitHub Actions

Pipeline automatically:
- ✅ Runs tests on push
- ✅ Builds Docker images
- ✅ Deploys to staging (develop branch)
- ✅ Deploys to production (main branch)

**Required GitHub Secrets:**
```
DOCKER_USERNAME
DOCKER_PASSWORD
STAGING_HOST
STAGING_USER
STAGING_SSH_KEY
PRODUCTION_HOST
PRODUCTION_USER
PRODUCTION_SSH_KEY
```

---

## 🐛 Troubleshooting

### Backend won't start
```bash
# Check logs
docker-compose logs backend

# Verify database connection
docker-compose exec postgres psql -U gogomarket_user -d gogomarket_prod

# Restart services
docker-compose restart backend
```

### Database migration fails
```bash
# Manually run migrations
docker-compose exec backend npm run migration:run

# Revert last migration
docker-compose exec backend npm run migration:revert
```

### Mobile app build errors
```bash
# Clean build
flutter clean
flutter pub get
flutter build apk --release
```

---

## 📞 Support

For deployment issues:
- Check logs: `docker-compose logs`
- Review environment variables
- Verify database connectivity
- Check firewall rules

---

**Deployment guide v1.0 - GOGOMARKET Platform**
