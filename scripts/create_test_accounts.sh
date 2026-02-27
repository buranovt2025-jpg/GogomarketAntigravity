#!/bin/bash
API_URL="http://localhost:3000/api/auth/register"

echo "Creating BUYER..."
curl -X POST $API_URL \
  -H "Content-Type: application/json" \
  -d '{
    "phone": "+998901234567",
    "password": "password",
    "role": "buyer",
    "name": "Buyer Test"
  }'
echo "\n"

echo "Creating SELLER..."
curl -X POST $API_URL \
  -H "Content-Type: application/json" \
  -d '{
    "phone": "+998911234567",
    "password": "password",
    "role": "seller",
    "storeName": "Seller Test Store",
    "cabinetType": "full"
  }'
echo "\n"

echo "Creating COURIER..."
curl -X POST $API_URL \
  -H "Content-Type: application/json" \
  -d '{
    "phone": "+998921234567",
    "password": "password",
    "role": "courier",
    "name": "Courier Test"
  }'
echo "\n"

echo "Creating ADMIN..."
curl -X POST $API_URL \
  -H "Content-Type: application/json" \
  -d '{
    "phone": "+998931234567",
    "password": "password",
    "role": "admin",
    "name": "Admin Test"
  }'
echo "\n"
