#!/bin/bash
# GOGOMARKET Setup Script - Backend & Database

set -e  # Exit on error

echo "🚀 GOGOMARKET Setup Script"
echo "================================"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Check prerequisites
echo -e "${BLUE}Checking prerequisites...${NC}"

if ! command -v node &> /dev/null; then
    echo "❌ Node.js not found. Please install Node.js 18+"
    exit 1
fi

if ! command -v npm &> /dev/null; then
    echo "❌ npm not found. Please install npm"
    exit 1
fi

if ! command -v psql &> /dev/null; then
    echo "⚠️  PostgreSQL client not found. Make sure PostgreSQL is installed."
fi

echo -e "${GREEN}✓ Prerequisites OK${NC}"

# Navigate to backend
cd backend || exit

# Install dependencies
echo -e "${BLUE}Installing backend dependencies...${NC}"
npm install
echo -e "${GREEN}✓ Dependencies installed${NC}"

# Setup environment
if [ ! -f .env ]; then
    echo -e "${BLUE}Creating .env file...${NC}"
    cp .env.example .env
    echo -e "${GREEN}✓ .env created. Please edit with your credentials.${NC}"
    echo "⚠️  Don't forget to configure:"
    echo "   - Database credentials"
    echo "   - JWT secrets"
    echo "   - Payme keys"
    echo "   - Click keys"
else
    echo "✓ .env already exists"
fi

# Ask to start database
read -p "Start PostgreSQL with Docker? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${BLUE}Starting PostgreSQL...${NC}"
    docker-compose up -d postgres
    echo "Waiting for database to be ready..."
    sleep 5
    echo -e "${GREEN}✓ PostgreSQL started${NC}"
fi

# Build application
echo -e "${BLUE}Building application...${NC}"
npm run build
echo -e "${GREEN}✓ Build complete${NC}"

# Completion
echo ""
echo "================================"
echo -e "${GREEN}🎉 Setup Complete!${NC}"
echo ""
echo "Next steps:"
echo "1. Edit backend/.env with your credentials"
echo "2. Run: cd backend && npm run start:dev"
echo "3. Visit: http://localhost:3000/api (Swagger)"
echo ""
echo "For mobile apps:"
echo "  cd mobile/seller && flutter pub get && flutter run"
echo "  cd mobile/buyer && flutter pub get && flutter run"
