# 🚀 DEPLOY AUTOMÁTICO - VERCEL

## ✅ Código Enviado!

Seu código foi enviado para o GitHub. Agora siga estes passos:

---

## 📋 PASSO 1: Criar Projeto na Vercel

### 1.1 Acesse a Vercel
```
https://vercel.com/new
```

### 1.2 Faça Login
- Clique em **"Continue with GitHub"**
- Autorize a Vercel

### 1.3 Importe o Repositório
- Clique em **"Add New Project"**
- Em **"Import Git Repository"**, selecione: `aquiacai-02`
- Clique em **"Import"**

---

## 📋 PASSO 2: Configurar Projeto

### 2.1 Nome do Projeto
Em **"Project Name"**, digite:
```
acaiaqui
```

### 2.2 Configurações de Build
Deixe como está (Vercel detecta Vite automaticamente):
- **Framework Preset:** Vite
- **Build Command:** `npm run build`
- **Output Directory:** `dist`
- **Install Command:** `npm install`

---

## 📋 PASSO 3: Variáveis de Ambiente (IMPORTANTE!)

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
   - **Project URL** → Cole em `VITE_SUPABASE_URL`
   - **anon/public key** → Cole em `VITE_SUPABASE_PUBLISHABLE_KEY`

**Exemplo:**
```
VITE_SUPABASE_URL=https://abcdefghij.supabase.co
VITE_SUPABASE_PUBLISHABLE_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFiY2RlZmdoaWoiLCJyb2xlIjoiYW5vbiIsImlhdCI6MTYx...
```

---

## 📋 PASSO 4: Deploy!

### 4.1 Clique em **"Deploy"**

### 4.2 Aguarde
- O deploy leva ~2-3 minutos
- Você verá o progresso na tela

### 4.3 Pronto!
Quando terminar, você verá:
- ✅ **"Congratulations!"**
- 🌐 **URL do seu site:** `https://acaiaqui.vercel.app`

---

## 📋 PASSO 5: Configurar Banco de Dados

### 5.1 Acesse o Supabase
```
https://app.supabase.com
```

### 5.2 Vá em SQL Editor
- Clique em **"SQL Editor"** no menu lateral
- Clique em **"New Query"**

### 5.3 Execute o Script de Lojas
1. Copie o conteúdo do arquivo `supabase-lojas.sql`
2. Cole no editor do Supabase
3. Clique em **"Run"** (ou Ctrl+Enter)

### 5.4 Execute o Script Principal
1. Copie o conteúdo do arquivo `supabase-schema.sql`
2. Cole no editor do Supabase
3. Clique em **"Run"**

---

## 📋 PASSO 6: Testar o Site

### 6.1 Acesse o Site
```
https://acaiaqui.vercel.app
```

### 6.2 Teste o Admin
```
https://acaiaqui.vercel.app/admin/login
```
- **Email:** `admin@acaiaqui.com`
- **Senha:** `admin123`

### 6.3 Teste o Super Admin
```
https://acaiaqui.vercel.app/super-admin/login
```
- **Email:** `super@acaiaqui.com`
- **Senha:** `super123`

---

## 🔧 Problemas Comuns

### ❌ Página em branco
**Solução:** Configure as variáveis de ambiente na Vercel!

1. Vá em **Settings** → **Environment Variables**
2. Adicione `VITE_SUPABASE_URL` e `VITE_SUPABASE_PUBLISHABLE_KEY`
3. Clique em **"Redeploy"** em **Deployments**

### ❌ Erro ao carregar dados
**Solução:** Execute os scripts SQL no Supabase!

1. Vá em **SQL Editor** no Supabase
2. Execute `supabase-lojas.sql`
3. Execute `supabase-schema.sql`

### ❌ Login não funciona
**Solução:** Verifique se os scripts SQL foram executados corretamente!

Os scripts criam:
- Tabela `lojas`
- Usuário `super@acaiaqui.com`
- Usuário `admin@acaiaqui.com`

---

## 📱 URLs do Seu Site

| Página | URL |
|--------|-----|
| **Site** | `https://acaiaqui.vercel.app` |
| **Admin** | `https://acaiaqui.vercel.app/admin/login` |
| **Super Admin** | `https://acaiaqui.vercel.app/super-admin/login` |

---

## 🎉 Pronto!

Seu site está no ar! 🚀

**Próximos passos:**
1. ✅ Configure as variáveis de ambiente na Vercel
2. ✅ Execute os scripts SQL no Supabase
3. ✅ Teste o site
4. ✅ Altere as senhas padrão
5. ✅ Cadastre seus produtos

---

## 📞 Precisa de Ajuda?

Se tiver problemas, verifique:
- ✅ Variáveis de ambiente configuradas na Vercel
- ✅ Scripts SQL executados no Supabase
- ✅ Console do navegador (F12) para erros

**Boas vendas! 🍇**
