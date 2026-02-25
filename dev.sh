#!/bin/bash
# Development Helper Script for GOGOMARKET

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

function show_menu() {
    clear
    echo -e "${BLUE}╔════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║   GOGOMARKET Development Menu     ║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════╝${NC}"
    echo ""
    echo "1. Start Backend (dev mode)"
    echo "2. Start Backend (Docker)"
    echo "3. Run Backend Tests"
    echo "4. Start Mobile Seller App"
    echo "5. Start Mobile Buyer App"
    echo "6. View Backend Logs"
    echo "7. Database Console"
    echo "8. Reset Database"
    echo "9. Check System Status"
    echo "0. Exit"
    echo ""
    read -p "Choose option: " choice
}

function start_backend_dev() {
    echo -e "${BLUE}Starting backend in development mode...${NC}"
    cd backend
    npm run start:dev
}

function start_backend_docker() {
    echo -e "${BLUE}Starting backend with Docker...${NC}"
    cd backend
    docker-compose up -d
    echo -e "${GREEN}✓ Backend started${NC}"
    echo "API: http://localhost:3000"
    echo "Swagger: http://localhost:3000/api"
}

function run_tests() {
    echo -e "${BLUE}Running backend tests...${NC}"
    cd backend
    npm run test
}

function start_mobile_seller() {
    echo -e "${BLUE}Starting Seller mobile app...${NC}"
    cd mobile/seller
    flutter run
}

function start_mobile_buyer() {
    echo -e "${BLUE}Starting Buyer mobile app...${NC}"
    cd mobile/buyer
    flutter run
}

function view_logs() {
    echo -e "${BLUE}Viewing backend logs...${NC}"
    cd backend
    docker-compose logs -f backend
}

function db_console() {
    echo -e "${BLUE}Opening PostgreSQL console...${NC}"
    cd backend
    docker-compose exec postgres psql -U postgres -d gogomarket
}

function reset_db() {
    echo -e "${YELLOW}WARNING: This will delete all data!${NC}"
    read -p "Are you sure? (yes/no): " confirm
    if [ "$confirm" == "yes" ]; then
        echo -e "${BLUE}Resetting database...${NC}"
        cd backend
        docker-compose down -v
        docker-compose up -d postgres
        sleep 3
        npm run migration:run
        echo -e "${GREEN}✓ Database reset complete${NC}"
    fi
}

function check_status() {
    echo -e "${BLUE}System Status:${NC}"
    echo ""
    
    # Check Node.js
    if command -v node &> /dev/null; then
        echo -e "${GREEN}✓${NC} Node.js: $(node --version)"
    else
        echo -e "${RED}✗${NC} Node.js: Not installed"
    fi
    
    # Check PostgreSQL
    if command -v psql &> /dev/null; then
        echo -e "${GREEN}✓${NC} PostgreSQL: Installed"
    else
        echo -e "${RED}✗${NC} PostgreSQL: Not installed"
    fi
    
    # Check Flutter
    if command -v flutter &> /dev/null; then
        echo -e "${GREEN}✓${NC} Flutter: $(flutter --version | head -n 1)"
    else
        echo -e "${RED}✗${NC} Flutter: Not installed"
    fi
    
    # Check Docker
    if command -v docker &> /dev/null; then
        echo -e "${GREEN}✓${NC} Docker: $(docker --version)"
    else
        echo -e "${RED}✗${NC} Docker: Not installed"
    fi
    
    echo ""
    read -p "Press Enter to continue..."
}

# Main loop
while true; do
    show_menu
    case $choice in
        1) start_backend_dev ;;
        2) start_backend_docker ;;
        3) run_tests ;;
        4) start_mobile_seller ;;
        5) start_mobile_buyer ;;
        6) view_logs ;;
        7) db_console ;;
        8) reset_db ;;
        9) check_status ;;
        0) echo "Goodbye!"; exit 0 ;;
        *) echo -e "${RED}Invalid option${NC}"; sleep 1 ;;
    esac
done
