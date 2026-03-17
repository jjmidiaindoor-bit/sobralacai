#!/bin/bash

# ============================================
# SCRIPT DE IMPLANTAÇÃO - SOBRALACAÍ
# Nova instância separada do Supabase
# URL: https://supab2.zedarede.org
# ============================================

echo "============================================"
echo "  IMPLANTAR SOBRALACAÍ - NOVA INSTÂNCIA"
echo "============================================"
echo ""

# Criar diretórios
echo "Criando diretórios..."
mkdir -p /root/supabase-sobralacai/docker/volumes/api
mkdir -p /root/supabase-sobralacai/docker/volumes/db

# Criar volumes
echo "Criando volumes..."
docker volume create sobralacai_db_config 2>/dev/null || echo "Volume já existe"
docker volume create sobralacai_storage 2>/dev/null || echo "Volume já existe"
docker network create -d overlay sobralacai_net 2>/dev/null || echo "Rede já existe"

# Copiar docker-compose
echo "Copiando docker-compose..."
cat > /root/supabase-sobralacai/docker-compose.yml << 'EOF'
version: "3.7"
services:
  supabase_studio:
    image: supabase/studio:2025.11.10-sha-5291fe3
    networks:
      - sobralacai_net
    environment:
      - HOSTNAME=0.0.0.0
      - SUPABASE_URL=http://sobralacai_kong:8000
      - SUPABASE_PUBLIC_URL=https://supab2.zedarede.org
      - SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNvYnJhbGFjYWkyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MTUwNTA4MDAsImV4cCI6MTg3MjgxNzIwMH0.sobralacai2_anon_key
      - SUPABASE_SERVICE_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNvYnJhbGFjYWkyIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTcxNTA1MDgwMCwiZXhwIjoxODcyODE3MjAwfQ.sobralacai2_service_key
      - AUTH_JWT_SECRET=sobralacai2_jwt_secret_key_very_secure_2026
      - DEFAULT_ORGANIZATION_NAME=SobralAçaí
      - DEFAULT_PROJECT_NAME=SobralAçaí
      - POSTGRES_DB=postgres
      - POSTGRES_HOST=sobralacai_db
      - POSTGRES_PORT=5432
      - POSTGRES_PASSWORD=sobralacai2_db_password_secure_2026
      - PG_META_CRYPTO_KEY=sobralacai2_crypto_key_very_secure_2026
      - STUDIO_PG_META_URL=http://sobralacai_meta:8080
    deploy:
      mode: replicated
      replicas: 1
      placement:
        constraints:
          - node.role == manager

  sobralacai_kong:
    image: kong:2.8.1
    entrypoint: bash -c 'eval "echo \"$$(cat ~/temp.yml)\"" > ~/kong.yml && /docker-entrypoint.sh kong docker-start'
    volumes:
      - /root/supabase-sobralacai/docker/volumes/api/kong.yml:/home/kong/temp.yml:ro
    networks:
      - sobralacai_net
    environment:
      - DASHBOARD_USERNAME=sobralacai
      - DASHBOARD_PASSWORD=SobralAcai2026!
      - JWT_SECRET=sobralacai2_jwt_secret_key_very_secure_2026
      - SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNvYnJhbGFjYWkyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MTUwNTA4MDAsImV4cCI6MTg3MjgxNzIwMH0.sobralacai2_anon_key
      - SUPABASE_SERVICE_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNvYnJhbGFjYWkyIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTcxNTA1MDgwMCwiZXhwIjoxODcyODE3MjAwfQ.sobralacai2_service_key
      - KONG_DATABASE=off
      - KONG_DECLARATIVE_CONFIG=/home/kong/kong.yml
      - KONG_DNS_ORDER=LAST,A,CNAME
      - KONG_PLUGINS=request-transformer,cors,key-auth,acl,basic-auth,request-termination,ip-restriction
      - KONG_NGINX_PROXY_PROXY_BUFFER_SIZE=160k
      - KONG_NGINX_PROXY_PROXY_BUFFERS=64 160k
    deploy:
      mode: replicated
      replicas: 1
      placement:
        constraints:
          - node.role == manager
      labels:
        - traefik.enable=true
        - traefik.http.routers.sobralacai_kong.rule=Host(`supab2.zedarede.org`) && PathPrefix(`/`)
        - traefik.http.services.sobralacai_kong.loadbalancer.server.port=8000
        - traefik.http.routers.sobralacai_kong.service=sobralacai_kong
        - traefik.http.routers.sobralacai_kong.entrypoints=websecure
        - traefik.http.routers.sobralacai_kong.tls.certresolver=letsencryptresolver
        - traefik.http.routers.sobralacai_kong.tls=true

  sobralacai_auth:
    image: supabase/gotrue:v2.182.1
    networks:
      - sobralacai_net
    environment:
      - GOTRUE_API_HOST=0.0.0.0
      - GOTRUE_API_PORT=9999
      - API_EXTERNAL_URL=https://supab2.zedarede.org
      - GOTRUE_DB_DRIVER=postgres
      - GOTRUE_DB_DATABASE_URL=postgres://supabase_auth_admin:sobralacai2_db_password_secure_2026@sobralacai_db:5432/postgres
      - GOTRUE_SITE_URL=https://supab2.zedarede.org
      - GOTRUE_DISABLE_SIGNUP=false
      - GOTRUE_JWT_ADMIN_ROLES=service_role
      - GOTRUE_JWT_AUD=authenticated
      - GOTRUE_JWT_DEFAULT_GROUP_NAME=authenticated
      - GOTRUE_JWT_EXP=31536000
      - GOTRUE_JWT_SECRET=sobralacai2_jwt_secret_key_very_secure_2026
      - GOTRUE_MAILER_AUTOCONFIRM=true
      - GOTRUE_EXTERNAL_SKIP_NONCE_CHECK=true
    deploy:
      mode: replicated
      replicas: 1
      placement:
        constraints:
          - node.role == manager

  sobralacai_rest:
    image: postgrest/postgrest:v13.0.7
    command: ["postgrest"]
    networks:
      - sobralacai_net
    environment:
      - PGRST_DB_URI=postgres://authenticator:sobralacai2_db_password_secure_2026@sobralacai_db:5432/postgres
      - PGRST_DB_SCHEMAS=public,storage,graphql_public
      - PGRST_DB_ANON_ROLE=anon
      - PGRST_JWT_SECRET=sobralacai2_jwt_secret_key_very_secure_2026
      - PGRST_APP_SETTINGS_JWT_SECRET=sobralacai2_jwt_secret_key_very_secure_2026
      - PGRST_APP_SETTINGS_JWT_EXP=31536000
    deploy:
      mode: replicated
      replicas: 1
      placement:
        constraints:
          - node.role == manager

  sobralacai_realtime:
    image: supabase/realtime:v2.63.0
    networks:
      - sobralacai_net
    environment:
      - PORT=4000
      - API_JWT_SECRET=sobralacai2_jwt_secret_key_very_secure_2026
      - SECRET_KEY_BASE=e6a62963be6c0ec95812fa188dba98b9c01ea3a911acaab2216f737622971f02
      - APP_NAME=realtime
      - DB_HOST=sobralacai_db
      - DB_PORT=5432
      - DB_USER=sobralacai_admin
      - DB_PASSWORD=sobralacai2_db_password_secure_2026
      - DB_NAME=postgres
      - DB_AFTER_CONNECT_QUERY=SET search_path TO _realtime
      - DB_ENC_KEY=sobralacai2realtime
    deploy:
      mode: replicated
      replicas: 1
      placement:
        constraints:
          - node.role == manager

  sobralacai_storage:
    image: supabase/storage-api:v1.29.0
    volumes:
      - sobralacai_storage:/var/lib/storage:z
    networks:
      - sobralacai_net
    environment:
      - ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNvYnJhbGFjYWkyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MTUwNTA4MDAsImV4cCI6MTg3MjgxNzIwMH0.sobralacai2_anon_key
      - SERVICE_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNvYnJhbGFjYWkyIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTcxNTA1MDgwMCwiZXhwIjoxODcyODE3MjAwfQ.sobralacai2_service_key
      - POSTGREST_URL=http://sobralacai_rest:3000
      - PGRST_JWT_SECRET=sobralacai2_jwt_secret_key_very_secure_2026
      - DATABASE_URL=postgres://supabase_storage_admin:sobralacai2_db_password_secure_2026@sobralacai_db:5432/postgres
      - FILE_SIZE_LIMIT=52428800
      - STORAGE_BACKEND=file
      - FILE_STORAGE_BACKEND_PATH=/var/lib/storage
      - REGION=local
      - TENANT_ID=sobralacai
      - ENABLE_IMAGE_TRANSFORMATION=true
      - IMGPROXY_URL=http://sobralacai_imgproxy:5001
    deploy:
      mode: replicated
      replicas: 1
      placement:
        constraints:
          - node.role == manager

  sobralacai_imgproxy:
    image: darthsim/imgproxy:v3.8.0
    volumes:
      - sobralacai_storage:/var/lib/storage:z
    networks:
      - sobralacai_net
    environment:
      - IMGPROXY_BIND=:5001
      - IMGPROXY_LOCAL_FILESYSTEM_ROOT=/
      - IMGPROXY_USE_ETAG=true
      - IMGPROXY_ENABLE_WEBP_DETECTION=true
    deploy:
      mode: replicated
      replicas: 1
      placement:
        constraints:
          - node.role == manager

  sobralacai_meta:
    image: supabase/postgres-meta:v0.93.1
    networks:
      - sobralacai_net
    environment:
      - PG_META_PORT=8080
      - PG_META_DB_HOST=sobralacai_db
      - PG_META_DB_PORT=5432
      - PG_META_DB_NAME=postgres
      - PG_META_DB_USER=sobralacai_admin
      - PG_META_DB_PASSWORD=sobralacai2_db_password_secure_2026
      - CRYPTO_KEY=sobralacai2_crypto_key_very_secure_2026
    deploy:
      mode: replicated
      replicas: 1
      placement:
        constraints:
          - node.role == manager

  sobralacai_db:
    image: supabase/postgres:15.8.1.085
    command: ["postgres", "-c", "config_file=/etc/postgresql/postgresql.conf", "-c", "log_min_messages=fatal"]
    volumes:
      - /root/supabase-sobralacai/docker/volumes/db/data:/var/lib/postgresql/data:z
      - sobralacai_db_config:/etc/postgresql-custom
    networks:
      - sobralacai_net
    environment:
      - POSTGRES_HOST=/var/run/postgresql
      - PGPORT=5432
      - POSTGRES_PORT=5432
      - PGPASSWORD=sobralacai2_db_password_secure_2026
      - POSTGRES_PASSWORD=sobralacai2_db_password_secure_2026
      - POSTGRES_DB=postgres
      - PGDATABASE=postgres
      - JWT_SECRET=sobralacai2_jwt_secret_key_very_secure_2026
      - JWT_EXP=31536000
    deploy:
      mode: replicated
      replicas: 1
      placement:
        constraints:
          - node.role == manager

volumes:
  sobralacai_db_config:
    external: true
    name: sobralacai_db_config
  sobralacai_storage:
    external: true
    name: sobralacai_storage

networks:
  sobralacai_net:
    external: true
    name: sobralacai_net
EOF

# Iniciar stack
echo "Iniciando stack SobralAçaí..."
cd /root/supabase-sobralacai
docker stack deploy sobralacai -c docker-compose.yml

echo ""
echo "============================================"
echo "  IMPLANTAÇÃO INICIADA!"
echo "============================================"
echo ""
echo "Aguardando serviços subirem (~2-3 minutos)..."
echo ""

# Aguardar
sleep 30

# Verificar status
echo "Verificando status dos serviços..."
docker service ls --filter name=sobralacai

echo ""
echo "============================================"
echo "  PRÓXIMOS PASSOS:"
echo "============================================"
echo ""
echo "1. Aguarde 2-3 minutos para todos os serviços subirem"
echo "2. Acesse: https://supab2.zedarede.org"
echo "3. Login Studio: sobralacai / SobralAcai2026!"
echo "4. Execute o SQL de criação das tabelas"
echo ""
echo "============================================"
