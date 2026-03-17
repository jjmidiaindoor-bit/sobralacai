-- ============================================
-- CRIAR NOVO PROJETO SOBRALACAI
-- ============================================
-- Este script cria um schema separado para isolar os dados
-- ============================================

-- 1. Criar schema sobralacai
CREATE SCHEMA IF NOT EXISTS sobralacai;

-- 2. Configurar permissões
GRANT ALL ON SCHEMA sobralacai TO postgres;
GRANT ALL ON SCHEMA sobralacai TO supabase_admin;
GRANT ALL ON SCHEMA sobralacai TO anon;
GRANT ALL ON SCHEMA sobralacai TO authenticated;

-- 3. Criar tabela de lojas no schema sobralacai
CREATE TABLE IF NOT EXISTS sobralacai.lojas (
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

-- 4. Criar categorias
CREATE TABLE IF NOT EXISTS sobralacai.categorias (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  loja_id UUID REFERENCES sobralacai.lojas(id) ON DELETE CASCADE,
  nome TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 5. Criar produtos
CREATE TABLE IF NOT EXISTS sobralacai.produtos (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  loja_id UUID REFERENCES sobralacai.lojas(id) ON DELETE CASCADE,
  categoria_id UUID REFERENCES sobralacai.categorias(id) ON DELETE SET NULL,
  nome TEXT NOT NULL,
  descricao TEXT,
  preco DECIMAL(10,2) NOT NULL DEFAULT 0,
  foto_url TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 6. Criar configuracoes
CREATE TABLE IF NOT EXISTS sobralacai.configuracoes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  loja_id UUID REFERENCES sobralacai.lojas(id) ON DELETE CASCADE,
  nome_loja TEXT NOT NULL,
  telefone_whatsapp TEXT NOT NULL,
  endereco TEXT,
  logo_url TEXT,
  banner_url TEXT,
  slogan TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 7. Criar pedidos
CREATE TABLE IF NOT EXISTS sobralacai.pedidos (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  loja_id UUID REFERENCES sobralacai.lojas(id) ON DELETE CASCADE,
  nome_cliente TEXT NOT NULL,
  telefone TEXT NOT NULL,
  endereco TEXT,
  observacao TEXT,
  detalhes_pedido TEXT NOT NULL,
  total DECIMAL(10,2) NOT NULL DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 8. Criar entregadores
CREATE TABLE IF NOT EXISTS sobralacai.entregadores (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  loja_id UUID REFERENCES sobralacai.lojas(id) ON DELETE CASCADE,
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

-- 9. Criar entregas
CREATE TABLE IF NOT EXISTS sobralacai.entregas (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  pedido_id UUID REFERENCES sobralacai.pedidos(id) ON DELETE SET NULL,
  loja_id UUID REFERENCES sobralacai.lojas(id) ON DELETE CASCADE,
  entregador_id UUID REFERENCES sobralacai.entregadores(id) ON DELETE SET NULL,
  status TEXT DEFAULT 'pendente',
  endereco_entrega TEXT,
  telefone_cliente TEXT,
  observacoes TEXT,
  valor_entrega DECIMAL(10,2),
  aceita_em TIMESTAMP WITH TIME ZONE,
  entregue_em TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 10. Habilitar RLS
ALTER TABLE sobralacai.lojas ENABLE ROW LEVEL SECURITY;
ALTER TABLE sobralacai.categorias ENABLE ROW LEVEL SECURITY;
ALTER TABLE sobralacai.produtos ENABLE ROW LEVEL SECURITY;
ALTER TABLE sobralacai.configuracoes ENABLE ROW LEVEL SECURITY;
ALTER TABLE sobralacai.pedidos ENABLE ROW LEVEL SECURITY;
ALTER TABLE sobralacai.entregadores ENABLE ROW LEVEL SECURITY;
ALTER TABLE sobralacai.entregas ENABLE ROW LEVEL SECURITY;

-- 11. Criar políticas de acesso
CREATE POLICY "Lojas select" ON sobralacai.lojas FOR SELECT USING (true);
CREATE POLICY "Lojas insert" ON sobralacai.lojas FOR INSERT WITH CHECK (true);
CREATE POLICY "Lojas update" ON sobralacai.lojas FOR UPDATE USING (true);
CREATE POLICY "Lojas delete" ON sobralacai.lojas FOR DELETE USING (true);

CREATE POLICY "Categorias select" ON sobralacai.categorias FOR SELECT USING (true);
CREATE POLICY "Produtos select" ON sobralacai.produtos FOR SELECT USING (true);
CREATE POLICY "Configuracoes select" ON sobralacai.configuracoes FOR SELECT USING (true);

-- 12. Criar função update_updated_at
CREATE OR REPLACE FUNCTION sobralacai.update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 13. Criar triggers
CREATE TRIGGER update_lojas_updated_at BEFORE UPDATE ON sobralacai.lojas
  FOR EACH ROW EXECUTE FUNCTION sobralacai.update_updated_at_column();

CREATE TRIGGER update_categorias_updated_at BEFORE UPDATE ON sobralacai.categorias
  FOR EACH ROW EXECUTE FUNCTION sobralacai.update_updated_at_column();

CREATE TRIGGER update_produtos_updated_at BEFORE UPDATE ON sobralacai.produtos
  FOR EACH ROW EXECUTE FUNCTION sobralacai.update_updated_at_column();

CREATE TRIGGER update_configuracoes_updated_at BEFORE UPDATE ON sobralacai.configuracoes
  FOR EACH ROW EXECUTE FUNCTION sobralacai.update_updated_at_column();

-- 14. Inserir dados iniciais
INSERT INTO sobralacai.lojas (nome_loja, nome_admin, email_admin, senha_admin, ativa)
VALUES ('Super Admin', 'Super Administrador', 'super@acaiaqui.com', 'super123', true)
ON CONFLICT (email_admin) DO NOTHING;

INSERT INTO sobralacai.lojas (nome_loja, nome_admin, email_admin, senha_admin, telefone_whatsapp, endereco, ativa)
VALUES ('SobralAçaí', 'Administrador', 'admin@sobralacai.com', 'admin123', '(88) 99999-9999', 'Rua da Matriz, 100 - Sobral', true)
ON CONFLICT (email_admin) DO NOTHING;

INSERT INTO sobralacai.configuracoes (nome_loja, telefone_whatsapp, endereco, slogan)
VALUES ('SobralAçaí', '(88) 99999-9999', 'Rua da Matriz, 100 - Sobral', 'O melhor açaí de Sobral')
ON CONFLICT DO NOTHING;

INSERT INTO sobralacai.categorias (nome) VALUES ('AÇAÍS') ON CONFLICT DO NOTHING;
INSERT INTO sobralacai.categorias (nome) VALUES ('CREMES') ON CONFLICT DO NOTHING;
INSERT INTO sobralacai.categorias (nome) VALUES ('ACOMPANHAMENTOS') ON CONFLICT DO NOTHING;

-- 15. Verificar criação
SELECT 'Schema sobralacai criado com sucesso!' as status;
SELECT COUNT(*) as total_lojas FROM sobralacai.lojas;
SELECT COUNT(*) as total_categorias FROM sobralacai.categorias;
