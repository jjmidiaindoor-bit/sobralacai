# 🚀 IMPLANTAR NOVA INSTÂNCIA SUPABASE - SOBRALACAÍ

## ⚠️ INSTRUÇÕES MANUAIS

A configuração automática encontrou problemas com o Traefik/SSL. Siga estes passos manualmente:

---

## **PASSO 1: Acessar o Servidor**

```bash
ssh root@147.93.3.69
# Senha: tenderbr0
```

---

## **PASSO 2: Criar Diretório**

```bash
mkdir -p /root/sobralacai-simple
cd /root/sobralacai-simple
```

---

## **PASSO 3: Criar Docker-Compose**

Crie o arquivo `docker-compose.yml`:

```yaml
version: "3.7"

services:
  db:
    image: supabase/postgres:15.8.1.085
    volumes:
      - db_data:/var/lib/postgresql/data
    environment:
      POSTGRES_PASSWORD: sobralacai2_password
      POSTGRES_DB: postgres
    networks:
      - sobralacai_net

  auth:
    image: supabase/gotrue:v2.182.1
    environment:
      GOTRUE_DB_DRIVER: postgres
      GOTRUE_DB_DATABASE_URL: postgres://postgres:sobralacai2_password@db:5432/postgres
      GOTRUE_SITE_URL: https://supab2.zedarede.org
      GOTRUE_JWT_SECRET: sobralacai2_secret
    networks:
      - sobralacai_net

  rest:
    image: postgrest/postgrest:v13.0.7
    environment:
      PGRST_DB_URI: postgres://postgres:sobralacai2_password@db:5432/postgres
      PGRST_JWT_SECRET: sobralacai2_secret
    networks:
      - sobralacai_net

volumes:
  db_data:

networks:
  sobralacai_net:
    external: true
```

---

## **PASSO 4: Iniciar**

```bash
docker stack deploy sobralacai -c docker-compose.yml
```

---

## **PASSO 5: Verificar**

```bash
docker service ls --filter name=sobralacai
```

---

## **URLs Após Configurar:**

- **API:** `https://supab2.zedarede.org/rest/v1/`
- **Auth:** `https://supab2.zedarede.org/auth/v1/`
- **Studio:** `https://supab2.zedarede.org/project/default`

---

## **Credenciais:**

- **Anon Key:** `eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNvYnJhbGFjYWkyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MTUwNTA4MDAsImV4cCI6MTg3MjgxNzIwMH0.sobralacai2_anon_key`

---

## ⚠️ **NOTA IMPORTANTE:**

O domínio `supab2.zedarede.org` já está configurado no Cloudflare, mas o SSL/TLS precisa ser configurado manualmente no Traefik.

**Alternativa mais simples:** Use a instância default que já está funcionando em `https://supab.zedarede.org`.
