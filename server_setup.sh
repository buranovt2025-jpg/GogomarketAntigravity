#!/bin/bash
# ==============================================================
# GOGOMARKET — Server Setup Script
# Запускать: bash server_setup.sh
# Сервер: Ubuntu 24.04 LTS
# ==============================================================

set -e  # Остановиться при ошибке

echo "============================================="
echo " GOGOMARKET Server Setup"
echo "============================================="

# === 1. Обновление системы ===
echo "📦 Updating system packages..."
apt-get update -y && apt-get upgrade -y

# === 2. Установка базовых пакетов ===
echo "🔧 Installing base packages..."
apt-get install -y \
  curl \
  wget \
  git \
  htop \
  ufw \
  nginx \
  certbot \
  python3-certbot-nginx

# === 3. Docker CE ===
echo "🐳 Installing Docker..."
if ! command -v docker &> /dev/null; then
  curl -fsSL https://get.docker.com | bash
  systemctl enable docker
  systemctl start docker
  echo "✅ Docker installed"
else
  echo "✅ Docker already installed: $(docker --version)"
fi

# === 4. Docker Compose v2 ===
echo "🐳 Installing Docker Compose v2..."
if ! docker compose version &> /dev/null; then
  COMPOSE_VERSION="v2.24.5"
  curl -SL "https://github.com/docker/compose/releases/download/${COMPOSE_VERSION}/docker-compose-linux-x86_64" \
    -o /usr/local/bin/docker-compose
  chmod +x /usr/local/bin/docker-compose
  ln -sf /usr/local/bin/docker-compose /usr/bin/docker-compose
  echo "✅ Docker Compose installed"
else
  echo "✅ Docker Compose already installed: $(docker-compose --version)"
fi

# === 5. Клонирование репозитория ===
echo "📥 Cloning GOGOMARKET repository..."
if [ ! -d /root/gogomarket ]; then
  git clone https://github.com/buranovt2025-jpg/GogomarketAntigravity.git /root/gogomarket
  echo "✅ Repository cloned to /root/gogomarket"
else
  echo "✅ Repository already exists, pulling latest..."
  cd /root/gogomarket && git pull origin master
fi

# === 6. .env файл backend ===
echo "⚙️  Setting up .env for backend..."
if [ ! -f /root/gogomarket/backend/.env ]; then
  cp /root/gogomarket/backend/.env.production.example /root/gogomarket/backend/.env
  echo ""
  echo "⚠️  ВАЖНО: Отредактируй /root/gogomarket/backend/.env"
  echo "    nano /root/gogomarket/backend/.env"
  echo ""
fi

# === 7. Firewall (UFW) ===
echo "🔥 Configuring firewall..."
ufw allow ssh
ufw allow 80/tcp
ufw allow 443/tcp
ufw --force enable
echo "✅ Firewall configured"

# === 8. Nginx setup ===
echo "🌐 Configuring Nginx..."
cat > /etc/nginx/sites-available/gogomarket << 'EOF'
server {
    listen 80;
    server_name 146.190.24.241 _;

    # Увеличим размер загружаемых файлов
    client_max_body_size 50M;

    # Health check endpoint
    location /health {
        proxy_pass http://localhost:3000/health;
        proxy_http_version 1.1;
        proxy_set_header Host $host;
        access_log off;
    }

    # API
    location /api {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
        proxy_connect_timeout 60s;
        proxy_read_timeout 60s;
    }

    # WebSocket (Socket.IO)
    location /socket.io {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }

    # Все остальные запросы — тоже на API
    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
    }
}
EOF

# Активируем конфиг
ln -sf /etc/nginx/sites-available/gogomarket /etc/nginx/sites-enabled/
rm -f /etc/nginx/sites-enabled/default
nginx -t && systemctl reload nginx
echo "✅ Nginx configured"

# === 9. SSH ключ для GitHub Actions ===
echo "🔑 Adding deploy SSH public key..."
mkdir -p /root/.ssh
chmod 700 /root/.ssh

DEPLOY_KEY="ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJYohm0k1cmGD6dilw7IVyP0Zlx9gc/k5Oh8oBkrIgty gogomarket-deploy"

if ! grep -qF "$DEPLOY_KEY" /root/.ssh/authorized_keys 2>/dev/null; then
  echo "$DEPLOY_KEY" >> /root/.ssh/authorized_keys
  chmod 600 /root/.ssh/authorized_keys
  echo "✅ Deploy SSH key added"
else
  echo "✅ Deploy SSH key already exists"
fi

# === 10. Первый запуск backend ===
echo "🚀 Starting GOGOMARKET backend for the first time..."
echo ""
echo "⚠️  Сначала отредактируйте .env файл!"
echo "   nano /root/gogomarket/backend/.env"
echo ""
read -p "Нажмите Enter после редактирования .env чтобы запустить backend..."

cd /root/gogomarket/backend
docker-compose up -d --build
echo "🏥 Checking health..."
sleep 20
curl -sf http://localhost:3000/health && echo "✅ Backend is UP!" || echo "⏳ Backend still starting, check: docker-compose logs"

echo ""
echo "============================================="
echo " ✅ SETUP COMPLETE!"
echo "============================================="
echo " API:     http://146.190.24.241"
echo " Swagger: http://146.190.24.241/api"
echo " Health:  http://146.190.24.241/health"
echo ""
echo " Logs:    cd /root/gogomarket/backend && docker-compose logs -f"
echo " Restart: cd /root/gogomarket/backend && docker-compose restart"
echo "============================================="
