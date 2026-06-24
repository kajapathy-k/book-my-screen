#!/bin/bash

# Update packages
apt update -y

# Install Docker, Redis, AWS CLI, jq
apt install -y docker.io redis-server 

# Enable and start Docker
systemctl enable docker
systemctl start docker

# Configure Redis to accept connections
sed -i 's/^bind .*/bind 0.0.0.0/' /etc/redis/redis.conf
sed -i 's/^protected-mode yes/protected-mode no/' /etc/redis/redis.conf

# Enable and start Redis
systemctl enable redis-server
systemctl restart redis-server

# Verify Redis
redis-cli ping

# Pull backend image
docker pull kajapathy/backend:latest

# Run backend container
docker run -d \
    --name backend \
    --restart unless-stopped \
    -e PORT=9000 \
    -e MONGO_CONNECTION_STRING="mongodb://${db_private_ip}:27017/bookmyscreen" \
    -e MONGO_REPLICA_STRING="mongodb://${db_private_ip}:27017/bookmyscreen" \
    -e EMAIL_USERNAME="kajapathy07@gmail.com" \
    -e EMAIL_PASSWORD="ulusaecbuxawvqkq" \
    -e HASH_SECRET="kajapathy_hash_secret" \
    -e ACCESS_TOKEN_SECRET="kajapathy_access_token" \
    -e REFRESH_TOKEN_SECRET="kajapathy_refresh_token" \
    -e FRONTEND_URL="http://localhost:5173" \
    -e REDIS_HOST="172.17.0.1" \
    -e REDIS_PORT="6379" \
    -p 9000:9000 \
    kajapathy/backend:latest