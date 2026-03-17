# 🍇 AÇAÍ EXPRESS - SISTEMA MULTI-LOJAS

Sistema de delivery de açaí com suporte para múltiplas lojas.

---

## 🚀 URLs

| Página | URL |
|--------|-----|
| **Site** | https://sobralacai.vercel.app |
| **Admin** | https://sobralacai.vercel.app/admin/login |
| **Super Admin** | https://sobralacai.vercel.app/super-admin/login |

---

## 🔐 Credenciais

### Super Admin
- **Email:** `super@acaiaqui.com`
- **Senha:** `super123`

### Admin Loja (exemplo)
- **Email:** `admin@acaiaqui.com`
- **Senha:** `admin123`

---

## 📋 CONFIGURAÇÃO INICIAL

### 1. Variáveis de Ambiente na Vercel

Acesse: https://vercel.com/jjmidiaindoors-projects/sobralacai/settings/environment-variables

Adicione:
- `VITE_SUPABASE_URL` → URL do seu projeto Supabase
- `VITE_SUPABASE_PUBLISHABLE_KEY` → Chave anon do Supabase

### 2. Banco de Dados (Supabase)

1. Acesse: https://app.supabase.com
2. Entre no seu projeto
3. Vá em **SQL Editor** → **New Query**
4. Copie e cole o arquivo `SCRIPT_COMPLETO.sql`
5. Clique em **Run**

---

## 🏪 COMO FUNCIONA

### Super Admin
- Cria, edita e exclui lojas
- Cada loja tem seu próprio admin
- Acesso: `/super-admin/login`

### Admin da Loja
- Gerencia produtos, categorias e pedidos
- Vê apenas dados da sua loja (isolamento total)
- Acesso: `/admin/login`

---

## 🛠️ Tecnologias

- **Frontend:** React + Vite + TypeScript
- **UI:** shadcn/ui + Tailwind CSS
- **Backend:** Supabase (PostgreSQL + Auth + Storage)
- **Deploy:** Vercel

---

## 📁 Estrutura

```
├── src/
│   ├── components/     # Componentes UI
│   ├── contexts/       # Contextos React
│   ├── hooks/          # Hooks personalizados
│   ├── pages/          # Páginas do sistema
│   └── integrations/   # Integração Supabase
├── public/             # Arquivos estáticos
├── SCRIPT_COMPLETO.sql # Script do banco de dados
└── vercel.json         # Configuração Vercel
```

---

## 📝 Comandos

```bash
npm run dev      # Desenvolvimento
npm run build    # Build produção
npm run preview  # Preview local
```

---

## 🎯 Funcionalidades

- ✅ Multi-lojas com isolamento de dados
- ✅ Painel administrativo por loja
- ✅ Gestão de produtos e categorias
- ✅ Pedidos em tempo real
- ✅ Configurações personalizadas por loja
- ✅ Upload de fotos de produtos
- ✅ Responsivo (mobile-first)

---

**Criado com ❤️ para Açaí Express**
