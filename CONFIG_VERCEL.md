# ⚙️ CONFIGURAÇÃO VERCEL - SOBRALACAÍ

## ✅ Configurações do Supabase (Self-Hosted)

Seu Supabase está rodando em: **https://supab.zedarede.org**

---

## 📋 PASSO 1: Configurar Variáveis na Vercel

### Acesse:
```
https://vercel.com/jjmidiaindoor-bit/sobralacai/settings/environment-variables
```

### Adicione estas variáveis:

#### Variável 1:
```
Name: VITE_SUPABASE_URL
Value: https://supab.zedarede.org
```

#### Variável 2:
```
Name: VITE_SUPABASE_PUBLISHABLE_KEY
Value: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.ewogICJyb2xlIjogImFub24iLAogICJpc3MiOiAic3VwYWJhc2UiLAogICJpYXQiOiAxNzE1MDUwODAwLAogICJleHAiOiAxODcyODE3MjAwCn0.d00VUGDTqOaAs7YqFKi1Y0eqP0-AiIgxy5A-hid93bQ
```

---

## 📋 PASSO 2: Redeploy

Após adicionar as variáveis:

1. Acesse: https://vercel.com/jjmidiaindoor-bit/sobralacai/deployments
2. Clique nos **3 pontinhos (⋮)** do último deploy
3. Clique em **"Redeploy"**
4. Aguarde ~2 minutos

---

## 🗄️ PASSO 3: Executar Scripts SQL

Acesse o SQL Editor do seu Supabase:
```
https://supab.zedarede.org/project/default/sql/new
```

### Execute nest ordem:

#### 1. Script de Lojas
Copie o conteúdo de `supabase-lojas.sql` e execute no SQL Editor

#### 2. Script Principal
Copie o conteúdo de `supabase-schema.sql` e execute no SQL Editor

---

## 🌐 URLs Após Configuração

| Serviço | URL |
|---------|-----|
| **Site** | `https://sobralacai.vercel.app` |
| **Supabase** | `https://supab.zedarede.org` |
| **Supabase Studio** | `https://supab.zedarede.org/project/default` |

---

## 🔐 Credenciais de Acesso

### Super Admin:
- **Email:** `super@acaiaqui.com`
- **Senha:** `super123`

### Admin:
- **Email:** `admin@acaiaqui.com`
- **Senha:** `admin123`

---

## ✅ Checklist

- [ ] Configurar variáveis na Vercel
- [ ] Fazer Redeploy
- [ ] Executar `supabase-lojas.sql` no Supabase
- [ ] Executar `supabase-schema.sql` no Supabase
- [ ] Testar site: https://sobralacai.vercel.app
- [ ] Testar admin: https://sobralacai.vercel.app/admin/login
- [ ] Testar super admin: https://sobralacai.vercel.app/super-admin/login

---

## 🐛 Debug

Se ainda estiver em branco:

1. **Abra o Console (F12)**
2. **Verifique os erros:**
   - ❌ "Invalid API key" → Chave errada
   - ❌ "Network error" → Supabase fora do ar
   - ❌ "relation does not exist" → Scripts SQL não executados

3. **Teste o Supabase:**
   ```
   https://supab.zedarede.org/rest/v1/lojas
   ```
   Deve retornar JSON com as lojas (ou array vazio)

---

**🎉 Seu site está pronto!**
