#!/bin/bash

# Script para executar SQL no Supabase self-hosted
# Servidor: 147.93.3.69
# Usuário: root
# Senha: tenderbr0

# SQL completo
SQL='
-- LOJAS
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

ALTER TABLE lojas ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Lojas select" ON lojas FOR SELECT USING (true);
CREATE POLICY "Lojas insert" ON lojas FOR INSERT WITH CHECK (true);
CREATE POLICY "Lojas update" ON lojas FOR UPDATE USING (true);
CREATE POLICY "Lojas delete" ON lojas FOR DELETE USING (true);

CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_lojas_updated_at BEFORE UPDATE ON lojas
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

INSERT INTO lojas (nome_loja, nome_admin, email_admin, senha_admin, ativa)
VALUES ('"'"'Super Admin'"'"', '"'"'Super Administrador'"'"', '"'"'super@acaiaqui.com'"'"', '"'"'super123'"'"', true)
ON CONFLICT (email_admin) DO NOTHING;

INSERT INTO lojas (nome_loja, nome_admin, email_admin, senha_admin, telefone_whatsapp, endereco, ativa)
VALUES ('"'"'Açaí Express'"'"', '"'"'Administrador'"'"', '"'"'admin@acaiaqui.com'"'"', '"'"'admin123'"'"', '"'"'(85) 99999-9999'"'"', '"'"'Rua Exemplo, 123'"'"', true)
ON CONFLICT (email_admin) DO NOTHING;

-- CATEGORIAS
CREATE TABLE IF NOT EXISTS categorias (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  loja_id UUID REFERENCES lojas(id) ON DELETE CASCADE,
  nome TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

ALTER TABLE categorias ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Categorias select" ON categorias FOR SELECT USING (true);

-- PRODUTOS
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

-- CONFIGURAÇÕES
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

-- PEDIDOS
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

-- ENTREGADORES
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

-- ENTREGAS
CREATE TABLE IF NOT EXISTS entregas (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  pedido_id UUID REFERENCES pedidos(id) ON DELETE SET NULL,
  loja_id UUID REFERENCES lojas(id) ON DELETE CASCADE,
  entregador_id UUID REFERENCES entregadores(id) ON DELETE SET NULL,
  status TEXT DEFAULT '"'"'pendente'"'"',
  endereco_entrega TEXT,
  telefone_cliente TEXT,
  observacoes TEXT,
  valor_entrega DECIMAL(10,2),
  aceita_em TIMESTAMP WITH TIME ZONE,
  entregue_em TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- DADOS INICIAIS
INSERT INTO configuracoes (nome_loja, telefone_whatsapp, endereco, slogan)
VALUES ('"'"'Açaí Express'"'"', '"'"'(85) 99999-9999'"'"', '"'"'Rua Exemplo, 123'"'"', '"'"'O melhor açaí da cidade'"'"')
ON CONFLICT DO NOTHING;

INSERT INTO categorias (nome) VALUES ('"'"'AÇAÍ'"'"') ON CONFLICT DO NOTHING;
INSERT INTO categorias (nome) VALUES ('"'"'CREMES'"'"') ON CONFLICT DO NOTHING;
INSERT INTO categorias (nome) VALUES ('"'"'ACOMPANHAMENTOS'"'"') ON CONFLICT DO NOTHING;
'

echo "🚀 Executando SQL no Supabase..."
echo "Servidor: 147.93.3.69"
echo ""

# Executar SQL via SSH
sshpass -p 'tenderbr0' ssh -o StrictHostKeyChecking=no root@147.93.3.69 "docker exec -i supabase_db psql -U postgres -d postgres -c \"$SQL\""

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ SQL executado com sucesso!"
    echo ""
    echo "🌐 Site: https://sobralacai.vercel.app"
    echo "📊 Supabase: https://supab.zedarede.org"
else
    echo ""
    echo "❌ Erro ao executar SQL"
    echo "Tente executar manualmente:"
    echo "ssh root@147.93.3.69"
    echo "docker exec -it supabase_db psql -U postgres -d postgres"
fi
