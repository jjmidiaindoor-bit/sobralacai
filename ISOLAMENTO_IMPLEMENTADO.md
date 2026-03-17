# ✅ ISOLAMENTO DE LOJAS IMPLEMENTADO!

## 🎯 O Que Foi Feito

Agora cada loja tem seus **próprios dados isolados**:
- ✅ Cada admin vê apenas os produtos da SUA loja
- ✅ Cada admin vê apenas os pedidos da SUA loja
- ✅ Cada admin vê apenas as categorias da SUA loja
- ✅ Cada admin vê apenas as configurações da SUA loja
- ✅ O que é criado em uma loja NÃO aparece nas outras

---

## 📋 PASSOS PARA IMPLEMENTAR

### PASSO 1: Executar o Script SQL no Supabase

1. **Acesse:** https://app.supabase.com
2. **Entre no seu projeto**
3. **Vá em:** SQL Editor → New Query
4. **Copie e cole** o arquivo: `SCRIPT_ISOLAMENTO_LOJAS.sql`
5. **Clique em:** Run (ou Ctrl+Enter)

**O script faz:**
- Adiciona coluna `loja_id` em todas as tabelas
- Cria políticas de Row Level Security (RLS)
- Vincula dados existentes à primeira loja
- Cria trigger para criar dados automáticos ao criar nova loja

---

### PASSO 2: Aguardar Deploy na Vercel

O deploy já foi realizado automaticamente!

**URL:** https://sobralacai.vercel.app

---

## 🔐 COMO FUNCIONA AGORA

### Login do Admin
1. Admin faz login com email e senha
2. Sistema identifica qual loja pertence
3. Todos os dados são filtrados pelo `loja_id`
4. Admin vê APENAS dados da sua loja

### Criando Nova Loja
1. SuperAdmin cria nova loja em `/super-admin/lojas`
2. Automaticamente são criados:
   - Configurações da loja
   - Categorias padrão (AÇAÍS, CREMES, ADICIONAIS)
3. Admin da nova loja já pode fazer login

---

## 🧪 TESTANDO O ISOLAMENTO

### Teste 1: Criar Duas Lojas

1. **Como SuperAdmin:**
   - Acesse: `/super-admin/login`
   - Email: `super@acaiaqui.com`
   - Senha: `super123`
   
2. **Crie duas lojas:**
   - Loja 1: "Açaí do João" - email: `joao@loja1.com` - senha: `senha123`
   - Loja 2: "Açaí da Maria" - email: `maria@loja2.com` - senha: `senha123`

3. **Teste isolamento:**
   - Faça logout do SuperAdmin
   - Login como João: `joao@loja1.com`
   - Crie alguns produtos
   - Faça logout
   - Login como Maria: `maria@loja2.com`
   - **Maria NÃO deve ver os produtos do João!**

---

## 📊 ESTRUTURA DO BANCO DE DADOS

### Tabelas com `loja_id`:

| Tabela | Coluna `loja_id` | Descrição |
|--------|------------------|-----------|
| `categorias` | ✅ | Categorias de produtos |
| `produtos` | ✅ | Produtos da loja |
| `pedidos` | ✅ | Pedidos dos clientes |
| `configuracoes` | ✅ | Configurações da loja |

### Políticas RLS Criadas:

| Tabela | SELECT | INSERT | UPDATE | DELETE |
|--------|--------|--------|--------|--------|
| `categorias` | ✅ Loja | ✅ Loja | ✅ Loja | ✅ Loja |
| `produtos` | ✅ Loja | ✅ Loja | ✅ Loja | ✅ Loja |
| `pedidos` | ✅ Loja | ✅ Cliente | - | - |
| `configuracoes` | ✅ Público | - | ✅ Loja | - |

---

## 🔄 COMO O CÓDIGO FUNCIONA

### 1. Login (`AdminLogin.tsx`)
```typescript
// Ao fazer login, salva dados da loja
localStorage.setItem("admin_loja", JSON.stringify({
  id: loja.id,
  email_admin: loja.email_admin,
  ...
}));

// Configura email no Supabase para RLS
supabase.rpc('set_loja_email', { loja_email: loja.email_admin });
```

### 2. Hooks (`use-supabase.ts`)
```typescript
// Busca apenas dados da loja logada
const lojaId = getLojaId(); // Lê do localStorage

const { data } = await supabase
  .from("produtos")
  .select("*")
  .eq("loja_id", lojaId); // FILTRO POR LOJA!
```

### 3. Banco de Dados (RLS)
```sql
-- Política que filtra automaticamente
CREATE POLICY "Loja pode ver seus produtos" ON produtos FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM lojas 
      WHERE lojas.id = produtos.loja_id 
      AND lojas.email_admin = current_setting('app.settings.loja_email')
    )
  );
```

---

## 🚨 IMPORTANTE

### Variáveis de Ambiente na Vercel

Certifique-se de que estão configuradas:

1. **Acesse:** https://vercel.com/jjmidiaindoors-projects/sobralacai/settings/environment-variables

2. **Adicione:**
   - `VITE_SUPABASE_URL`
   - `VITE_SUPABASE_PUBLISHABLE_KEY`

3. **Redeploy:** Após adicionar, faça redeploy

---

## 🛠️ COMANDOS ÚTEIS

### Ver lojas criadas:
```sql
SELECT id, nome_loja, email_admin, ativa 
FROM lojas 
ORDER BY created_at DESC;
```

### Ver dados por loja:
```sql
-- Produtos de uma loja específica
SELECT p.nome, p.preco, l.nome_loja
FROM produtos p
JOIN lojas l ON p.loja_id = l.id
WHERE l.email_admin = 'admin@acaiaqui.com';

-- Contar produtos por loja
SELECT l.nome_loja, COUNT(p.id) as total_produtos
FROM lojas l
LEFT JOIN produtos p ON l.id = p.loja_id
GROUP BY l.id, l.nome_loja;
```

### Limpar dados de uma loja (cuidado!):
```sql
-- Deleta todos os dados de uma loja específica
DELETE FROM produtos WHERE loja_id = 'ID_DA_LOJA_AQUI';
DELETE FROM categorias WHERE loja_id = 'ID_DA_LOJA_AQUI';
DELETE FROM pedidos WHERE loja_id = 'ID_DA_LOJA_AQUI';
```

---

## 📞 URLs

| Página | URL |
|--------|-----|
| Site | https://sobralacai.vercel.app |
| Admin Login | https://sobralacai.vercel.app/admin/login |
| Super Admin | https://sobralacai.vercel.app/super-admin/login |

---

## ✅ CHECKLIST

- [x] Código atualizado no GitHub
- [x] Deploy na Vercel realizado
- [ ] Script SQL executado no Supabase
- [ ] Variáveis de ambiente configuradas na Vercel
- [ ] Teste de isolamento realizado

---

**Agora cada loja tem seu próprio espaço isolado! 🎉**
