#!/bin/bash

apt update -y
apt install -y docker.io nginx 

systemctl start docker
systemctl enable docker

systemctl start nginx
systemctl enable nginx

docker pull kajapathy/frontend:latest

docker run -d \
    --name frontend \
    --restart unless-stopped \
    -p 3000:80 \
    -e VITE_API_URL="/api" \
    kajapathy/frontend:latest

cat > /etc/nginx/sites-available/default <<'NGINXCONF'
server {
    listen 80;

    client_max_body_size 100M;

    location / {
        proxy_pass http://localhost:3000;

        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    location /api/ {
        proxy_pass `http://${backend_private_ip}:9000`;

        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
NGINXCONF

nginx -t

systemctl restart nginx