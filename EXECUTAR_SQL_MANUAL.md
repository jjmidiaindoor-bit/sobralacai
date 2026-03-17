# 📝 EXECUTAR SQL NO SUPABASE - MANUAL

## ⚠️ A API do Supabase Self-Hosted requer configuração especial

Siga estes passos para executar os scripts SQL:

---

## **PASSO 1: Acesse o Supabase Studio**

```
https://supab.zedarede.org/project/default
```

**Login:**
- **Username:** `jjmidia`
- **Password:** `Tenderbr0`

---

## **PASSO 2: Vá para o SQL Editor**

1. No menu lateral, clique em **"SQL Editor"**
2. Clique em **"New Query"**

---

## **PASSO 3: Execute o Script de Lojas**

Copie e cole este SQL:

```sql
-- Tabela de Lojas
CREATE TABLE IF NOT EXISTS lojas (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  nome_loja TEXT NOT NULL,
  nome_admin TEXT NOT NULL,
  email_admin TEXT NOT NULL UNIQUE,
  senha_admin TEXT NOT NULL,
  telefone_whatsapp TEXT,
  endereco TEXT,
  ativa BOOLEAN DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- RLS
ALTER TABLE lojas ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Lojas select" ON lojas FOR SELECT USING (true);
CREATE POLICY "Lojas insert" ON lojas FOR INSERT WITH CHECK (true);
CREATE POLICY "Lojas update" ON lojas FOR UPDATE USING (true);
CREATE POLICY "Lojas delete" ON lojas FOR DELETE USING (true);

-- Trigger
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_lojas_updated_at BEFORE UPDATE ON lojas
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Dados iniciais
INSERT INTO lojas (nome_loja, nome_admin, email_admin, senha_admin, ativa)
VALUES ('Super Admin', 'Super Administrador', 'super@acaiaqui.com', 'super123', true)
ON CONFLICT (email_admin) DO NOTHING;

INSERT INTO lojas (nome_loja, nome_admin, email_admin, senha_admin, telefone_whatsapp, endereco, ativa)
VALUES ('Açaí Express', 'Administrador', 'admin@acaiaqui.com', 'admin123', '(85) 99999-9999', 'Rua Exemplo, 123', true)
ON CONFLICT (email_admin) DO NOTHING;
```

**Clique em "Run"** (ou Ctrl+Enter)

---

## **PASSO 4: Execute o Schema Principal**

Copie e cole este SQL:

```sql
-- Categorias
CREATE TABLE IF NOT EXISTS categorias (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  loja_id UUID REFERENCES lojas(id) ON DELETE CASCADE,
  nome TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

ALTER TABLE categorias ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Categorias select" ON categorias FOR SELECT USING (true);

-- Produtos
CREATE TABLE IF NOT EXISTS produtos (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  loja_id UUID REFERENCES lojas(id) ON DELETE CASCADE,
  categoria_id UUID REFERENCES categorias(id) ON DELETE SET NULL,
  nome TEXT NOT NULL,
  descricao TEXT,
  preco DECIMAL(10,2) NOT NULL DEFAULT 0,
  foto_url TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

ALTER TABLE produtos ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Produtos select" ON produtos FOR SELECT USING (true);

-- Configurações
CREATE TABLE IF NOT EXISTS configuracoes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  loja_id UUID REFERENCES lojas(id) ON DELETE CASCADE,
  nome_loja TEXT NOT NULL,
  telefone_whatsapp TEXT NOT NULL,
  endereco TEXT,
  logo_url TEXT,
  banner_url TEXT,
  slogan TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

ALTER TABLE configuracoes ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Configuracoes select" ON configuracoes FOR SELECT USING (true);

-- Pedidos
CREATE TABLE IF NOT EXISTS pedidos (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  loja_id UUID REFERENCES lojas(id) ON DELETE CASCADE,
  nome_cliente TEXT NOT NULL,
  telefone TEXT NOT NULL,
  endereco TEXT,
  observacao TEXT,
  detalhes_pedido TEXT NOT NULL,
  total DECIMAL(10,2) NOT NULL DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Entregadores
CREATE TABLE IF NOT EXISTS entregadores (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  loja_id UUID REFERENCES lojas(id) ON DELETE CASCADE,
  nome TEXT NOT NULL,
  email TEXT NOT NULL UNIQUE,
  senha_hash TEXT NOT NULL,
  telefone TEXT,
  placa_veiculo TEXT,
  modelo_veiculo TEXT,
  cor_veiculo TEXT,
  ativo BOOLEAN DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Entregas
CREATE TABLE IF NOT EXISTS entregas (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  pedido_id UUID REFERENCES pedidos(id) ON DELETE SET NULL,
  loja_id UUID REFERENCES lojas(id) ON DELETE CASCADE,
  entregador_id UUID REFERENCES entregadores(id) ON DELETE SET NULL,
  status TEXT DEFAULT 'pendente',
  endereco_entrega TEXT,
  telefone_cliente TEXT,
  observacoes TEXT,
  valor_entrega DECIMAL(10,2),
  aceita_em TIMESTAMP WITH TIME ZONE,
  entregue_em TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Dados iniciais
INSERT INTO configuracoes (nome_loja, telefone_whatsapp, endereco, slogan)
VALUES ('Açaí Express', '(85) 99999-9999', 'Rua Exemplo, 123', 'O melhor açaí da cidade')
ON CONFLICT DO NOTHING;

INSERT INTO categorias (nome) VALUES ('AÇAÍ') ON CONFLICT DO NOTHING;
INSERT INTO categorias (nome) VALUES ('CREMES') ON CONFLICT DO NOTHING;
INSERT INTO categorias (nome) VALUES ('ACOMPANHAMENTOS') ON CONFLICT DO NOTHING;
```

**Clique em "Run"**

---

## **PASSO 5: Verificar Tabelas**

1. Vá em **"Table Editor"** no menu lateral
2. Você deve ver estas tabelas:
   - ✅ lojas
   - ✅ categorias
   - ✅ produtos
   - ✅ configuracoes
   - ✅ pedidos
   - ✅ entregadores
   - ✅ entregas

---

## **PASSO 6: Testar o Site**

1. Acesse: `https://sobralacai.vercel.app`
2. Vá em: `/admin/login`
3. Login: `admin@acaiaqui.com` / `admin123`

---

## 🎉 **Pronto!**

Seu site está completo e funcionando!
