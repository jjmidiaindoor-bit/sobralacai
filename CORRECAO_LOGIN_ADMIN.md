# Correção do Login de Admin das Lojas

## Problema Identificado

O sistema possuía **dois sistemas de autenticação separados**:

1. **SuperAdmin** - usa o **Supabase Auth** (`auth.users`)
2. **Admin das Lojas** - usa a tabela **`lojas`** com `email_admin` e `senha_admin`

Quando um novo usuário admin era criado no SuperAdmin, ele era salvo **apenas na tabela `lojas`**, mas o `AdminLogin.tsx` estava tentando autenticar usando o `useAuth` (Supabase Auth), o que causava a falha no login.

## Solução Implementada

### 1. Modificação do `AdminLogin.tsx`

O login de admin agora autentica diretamente contra a tabela `lojas`:

```typescript
const { data: loja, error } = await supabase
  .from("lojas")
  .select("*")
  .eq("email_admin", email)
  .eq("senha_admin", password)
  .eq("ativa", true)
  .single();
```

Se autenticado, os dados da loja são armazenados no `localStorage`.

### 2. Modificação do `AdminLayout.tsx`

Agora verifica se o usuário está autenticado lendo o `localStorage`:

```typescript
useEffect(() => {
  const lojaData = localStorage.getItem("admin_loja");
  if (!lojaData) {
    navigate("/admin/login");
    return;
  }
  setLoja(JSON.parse(lojaData));
}, [navigate]);
```

### 3. Atualização do `App.tsx`

- Removida a proteção `ProtectedRoute` para rotas de `/admin` (agora gerenciada pelo `AdminLayout`)
- Mantida a proteção `ProtectedSuperAdminRoute` para rotas de `/super-admin` (usa Supabase Auth)

### 4. Atualização dos Tipos do Supabase (`types.ts`)

Adicionada a tabela `lojas` aos tipos TypeScript para permitir o acesso correto via Supabase client.

## Como Funciona Agora

### Fluxo de Login do Admin:
1. Admin acessa `/admin/login`
2. Insere email e senha (cadastrados na tabela `lojas`)
3. Sistema verifica na tabela `lojas`:
   - Email corresponde
   - Senha corresponde
   - Loja está ativa (`ativa = true`)
4. Se sucesso, salva dados no `localStorage` e redireciona para `/admin`
5. `AdminLayout` verifica se há dados no `localStorage`
6. Se não houver, redireciona para login

### Fluxo de Criação de Nova Loja (SuperAdmin):
1. SuperAdmin acessa `/super-admin/lojas`
2. Clica em "NOVA LOJA"
3. Preenche:
   - Nome da Loja
   - Nome do Admin
   - Email do Admin
   - Senha do Admin
   - Telefone/WhatsApp (opcional)
   - Endereço (opcional)
4. Ao salvar, a loja é criada na tabela `lojas`
5. O admin já pode fazer login com as credenciais cadastradas

## Credenciais de Exemplo

### SuperAdmin
- Email: `super@acaiaqui.com`
- Senha: `super123`
- Acesso: `/super-admin/login`

### Admin de Loja (padrão)
- Email: `admin@acaiaqui.com`
- Senha: `admin123`
- Acesso: `/admin/login`

## Testando a Correção

1. Acesse `/super-admin/login` com as credenciais de SuperAdmin
2. Crie uma nova loja com email e senha
3. Faça logout
4. Acesse `/admin/login` com as credenciais da loja criada
5. Deve conseguir acessar o painel administrativo normalmente

## Notas de Segurança

⚠️ **Importante**: As senhas estão armazenadas em texto puro na tabela `lojas`. Para produção, considere:

1. Implementar hash de senha (bcrypt, argon2)
2. Migrar para o Supabase Auth para todos os usuários
3. Adicionar RLS (Row Level Security) mais restritivo
4. Implementar refresh de token e sessão segura

## Arquivos Modificados

- `src/pages/AdminLogin.tsx` - Nova lógica de autenticação
- `src/pages/AdminLayout.tsx` - Verificação de sessão via localStorage
- `src/App.tsx` - Rotas protegidas atualizadas
- `src/integrations/supabase/types.ts` - Tipos da tabela `lojas` adicionados
