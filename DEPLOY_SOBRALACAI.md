# 🚀 DEPLOY SOBRALACAÍ - VERCEL

## ✅ Código Enviado com Sucesso!

Seu projeto está agora em:
- **GitHub:** https://github.com/jjmidiaindoor-bit/sobralacai
- **Branch:** main
- **Último commit:** Correções do Super Admin

---

## 📋 PASSO 1: Criar Projeto na Vercel

### 1.1 Acesse a Vercel
```
https://vercel.com/new
```

### 1.2 Importe o Repositório
1. Faça login com GitHub
2. Clique em **"Add New Project"**
3. Em **"Import Git Repository"**, procure por: `sobralacai`
4. Selecione o repositório: `jjmidiaindoor-bit/sobralacai`
5. Clique em **"Import"**

---

## 📋 PASSO 2: Configurar Projeto

### 2.1 Nome do Projeto
Em **"Project Name"**, digite:
```
sobralacai
```

### 2.2 Root Directory
Deixe em branco (projeto está na raiz)

### 2.3 Framework Preset
A Vercel detecta automaticamente: **Vite**

### 2.4 Build Settings
- **Build Command:** `npm run build`
- **Output Directory:** `dist`
- **Install Command:** `npm install`

---

## 📋 PASSO 3: Variáveis de Ambiente (CRÍTICO!)

### 3.1 Clique em "Environment Variables"

### 3.2 Adicione estas variáveis:

| Nome | Valor |
|------|-------|
| `VITE_SUPABASE_URL` | `https://SEU_PROJETO.supabase.co` |
| `VITE_SUPABASE_PUBLISHABLE_KEY` | `SUA_CHAVE_ANON_AQUI` |

### 3.3 Como pegar as credenciais do Supabase:

1. **Acesse:** https://app.supabase.com
2. **Entre no seu projeto**
3. **Vá em:** Settings (engrenagem) → API
4. **Copie:**
   - **Project URL** → `VITE_SUPABASE_URL`
   - **anon/public key** → `VITE_SUPABASE_PUBLISHABLE_KEY`

**Exemplo:**
```env
VITE_SUPABASE_URL=https://abcdefghij.supabase.co
VITE_SUPABASE_PUBLISHABLE_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFiY2RlZmdoaWoiLCJyb2xlIjoiYW5vbiIsImlhdCI6MTYx...
```

---

## 📋 PASSO 4: Deploy!

### 4.1 Clique em **"Deploy"**

### 4.2 Aguarde
- Build leva ~2-3 minutos
- Você verá o progresso na tela

### 4.3 Pronto!
Quando terminar:
- ✅ **"Congratulations!"**
- 🌐 **URL:** `https://sobralacai.vercel.app`

---

## 🗄️ PASSO 5: Configurar Banco de Dados

### Execute os Scripts SQL no Supabase:

#### 5.1 Script 1 - Tabela de Lojas
1. Acesse: https://app.supabase.com
2. Vá em **SQL Editor** → **New Query**
3. Copie o conteúdo de `supabase-lojas.sql`
4. Execute o script

#### 5.2 Script 2 - Tabelas Principais
1. No mesmo SQL Editor
2. Copie o conteúdo de `supabase-schema.sql`
3. Execute o script

---

## 🌐 URLs do Seu Site

| Página | URL |
|--------|-----|
| **Site** | `https://sobralacai.vercel.app` |
| **Admin** | `https://sobralacai.vercel.app/admin/login` |
| **Super Admin** | `https://sobralacai.vercel.app/super-admin/login` |

---

## 🔐 Credenciais de Acesso

### Super Admin:
- **Email:** `super@acaiaqui.com`
- **Senha:** `super123`

### Admin da Loja:
- **Email:** `admin@acaiaqui.com`
- **Senha:** `admin123`

**⚠️ Altere as senhas após o primeiro acesso!**

---

## 🔄 Deploy Automático

A partir de agora, todo push na branch `main` faz deploy automático:

```bash
# Fazer alterações
git add .
git commit -m "Sua mensagem"
git push origin main
```

A Vercel detecta e faz deploy automaticamente! 🚀

---

## 📊 Acompanhar Deploy

- **Dashboard:** https://vercel.com/jjmidiaindoor-bit/sobralacai
- **Deployments:** https://vercel.com/jjmidiaindoor-bit/sobralacai/deployments
- **Logs:** https://vercel.com/jjmidiaindoor-bit/sobralacai/activity

---

## 🐛 Problemas Comuns

### ❌ Página em branco
**Solução:** Configure as variáveis de ambiente na Vercel!
- Settings → Environment Variables
- Adicione `VITE_SUPABASE_URL` e `VITE_SUPABASE_PUBLISHABLE_KEY`
- Redeploy

### ❌ Erro ao carregar dados
**Solução:** Execute os scripts SQL no Supabase!
- `supabase-lojas.sql`
- `supabase-schema.sql`

### ❌ Login não funciona
**Solução:** Verifique se os scripts SQL foram executados!
- Os scripts criam os usuários padrão

---

## ✅ Checklist Final

- [ ] Criar projeto na Vercel
- [ ] Configurar variáveis de ambiente
- [ ] Aguardar deploy
- [ ] Executar scripts SQL no Supabase
- [ ] Testar site
- [ ] Testar admin
- [ ] Testar super admin
- [ ] Alterar senhas padrão

---

**🎉 Seu site SobralAçaí está pronto!**

Boas vendas! 🍇
