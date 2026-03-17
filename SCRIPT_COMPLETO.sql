-- ============================================
-- SCRIPT COMPLETO - AÇAÍ EXPRESS
-- ============================================
-- Execute este script no SQL Editor do Supabase
-- https://app.supabase.com

-- ============================================
-- 1. FUNÇÃO PARA DEFINIR EMAIL DA LOJA (RLS)
-- ============================================

CREATE OR REPLACE FUNCTION public.set_loja_email(loja_email TEXT)
RETURNS void AS $$
BEGIN
  PERFORM set_config('app.settings.loja_email', loja_email, false);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;


-- ============================================
-- 2. TABELA DE LOJAS
-- ============================================

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

CREATE POLICY "Lojas são visíveis para login" ON lojas FOR SELECT USING (true);
CREATE POLICY "Inserção de lojas" ON lojas FOR INSERT WITH CHECK (true);
CREATE POLICY "Atualização de lojas" ON lojas FOR UPDATE USING (true);
CREATE POLICY "Exclusão de lojas" ON lojas FOR DELETE USING (true);

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


-- ============================================
-- 3. TABELA DE CATEGORIAS
-- ============================================

CREATE TABLE IF NOT EXISTS categorias (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  loja_id UUID NOT NULL REFERENCES lojas(id) ON DELETE CASCADE,
  nome TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

ALTER TABLE categorias ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Loja pode ver suas categorias" ON categorias FOR SELECT 
  USING (EXISTS (SELECT 1 FROM lojas WHERE lojas.id = categorias.loja_id AND lojas.email_admin = current_setting('app.settings.loja_email', TRUE)));

CREATE POLICY "Loja pode criar categorias" ON categorias FOR INSERT 
  WITH CHECK (EXISTS (SELECT 1 FROM lojas WHERE lojas.id = categorias.loja_id AND lojas.email_admin = current_setting('app.settings.loja_email', TRUE) AND lojas.ativa = true));

CREATE POLICY "Loja pode atualizar categorias" ON categorias FOR UPDATE 
  USING (EXISTS (SELECT 1 FROM lojas WHERE lojas.id = categorias.loja_id AND lojas.email_admin = current_setting('app.settings.loja_email', TRUE) AND lojas.ativa = true));

CREATE POLICY "Loja pode excluir categorias" ON categorias FOR DELETE 
  USING (EXISTS (SELECT 1 FROM lojas WHERE lojas.id = categorias.loja_id AND lojas.email_admin = current_setting('app.settings.loja_email', TRUE) AND lojas.ativa = true));

CREATE TRIGGER update_categorias_updated_at BEFORE UPDATE ON categorias 
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();


-- ============================================
-- 4. TABELA DE PRODUTOS
-- ============================================

CREATE TABLE IF NOT EXISTS produtos (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  loja_id UUID NOT NULL REFERENCES lojas(id) ON DELETE CASCADE,
  nome TEXT NOT NULL,
  descricao TEXT,
  preco NUMERIC(10, 2) NOT NULL DEFAULT 0,
  foto_url TEXT,
  categoria_id UUID REFERENCES categorias(id) ON DELETE SET NULL,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

ALTER TABLE produtos ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Loja pode ver seus produtos" ON produtos FOR SELECT 
  USING (EXISTS (SELECT 1 FROM lojas WHERE lojas.id = produtos.loja_id AND lojas.email_admin = current_setting('app.settings.loja_email', TRUE)));

CREATE POLICY "Loja pode criar produtos" ON produtos FOR INSERT 
  WITH CHECK (EXISTS (SELECT 1 FROM lojas WHERE lojas.id = produtos.loja_id AND lojas.email_admin = current_setting('app.settings.loja_email', TRUE) AND lojas.ativa = true));

CREATE POLICY "Loja pode atualizar produtos" ON produtos FOR UPDATE 
  USING (EXISTS (SELECT 1 FROM lojas WHERE lojas.id = produtos.loja_id AND lojas.email_admin = current_setting('app.settings.loja_email', TRUE) AND lojas.ativa = true));

CREATE POLICY "Loja pode excluir produtos" ON produtos FOR DELETE 
  USING (EXISTS (SELECT 1 FROM lojas WHERE lojas.id = produtos.loja_id AND lojas.email_admin = current_setting('app.settings.loja_email', TRUE) AND lojas.ativa = true));

CREATE TRIGGER update_produtos_updated_at BEFORE UPDATE ON produtos 
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();


-- ============================================
-- 5. TABELA DE PEDIDOS
-- ============================================

CREATE TABLE IF NOT EXISTS pedidos (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  loja_id UUID NOT NULL REFERENCES lojas(id) ON DELETE CASCADE,
  nome_cliente TEXT NOT NULL,
  telefone TEXT NOT NULL,
  endereco TEXT,
  observacao TEXT,
  detalhes_pedido TEXT NOT NULL,
  total NUMERIC(10, 2) NOT NULL DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

ALTER TABLE pedidos ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Clientes podem criar pedidos" ON pedidos FOR INSERT WITH CHECK (true);
CREATE POLICY "Loja pode ver seus pedidos" ON pedidos FOR SELECT 
  USING (EXISTS (SELECT 1 FROM lojas WHERE lojas.id = pedidos.loja_id AND lojas.email_admin = current_setting('app.settings.loja_email', TRUE)) OR loja_id IS NULL);


-- ============================================
-- 6. TABELA DE CONFIGURACOES
-- ============================================

CREATE TABLE IF NOT EXISTS configuracoes (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  loja_id UUID NOT NULL REFERENCES lojas(id) ON DELETE CASCADE,
  nome_loja TEXT NOT NULL DEFAULT 'Açaí Express',
  telefone_whatsapp TEXT NOT NULL DEFAULT '',
  endereco TEXT,
  logo_url TEXT,
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

ALTER TABLE configuracoes ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Qualquer um pode ver configuracoes" ON configuracoes FOR SELECT USING (true);
CREATE POLICY "Loja pode atualizar configuracoes" ON configuracoes FOR UPDATE 
  USING (EXISTS (SELECT 1 FROM lojas WHERE lojas.id = configuracoes.loja_id AND lojas.email_admin = current_setting('app.settings.loja_email', TRUE) AND lojas.ativa = true));

CREATE TRIGGER update_configuracoes_updated_at BEFORE UPDATE ON configuracoes 
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();


-- ============================================
-- 7. ÍNDICES DE PERFORMANCE
-- ============================================

CREATE INDEX IF NOT EXISTS idx_categorias_loja_id ON categorias(loja_id);
CREATE INDEX IF NOT EXISTS idx_produtos_loja_id ON produtos(loja_id);
CREATE INDEX IF NOT EXISTS idx_pedidos_loja_id ON pedidos(loja_id);
CREATE INDEX IF NOT EXISTS idx_configuracoes_loja_id ON configuracoes(loja_id);


-- ============================================
-- 8. FUNÇÃO PARA CRIAR DADOS DA LOJA
-- ============================================

CREATE OR REPLACE FUNCTION public.criar_dados_ao_criar_loja() RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO configuracoes (loja_id, nome_loja, telefone_whatsapp, endereco) 
  VALUES (NEW.id, NEW.nome_loja, NEW.telefone_whatsapp, NEW.endereco);
  
  INSERT INTO categorias (loja_id, nome) 
  VALUES (NEW.id, 'AÇAÍS'), (NEW.id, 'CREMES'), (NEW.id, 'ADICIONAIS');
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS trigger_criar_dados_loja ON lojas;
CREATE TRIGGER trigger_criar_dados_loja AFTER INSERT ON lojas 
  FOR EACH ROW EXECUTE FUNCTION public.criar_dados_ao_criar_loja();


-- ============================================
-- 9. BUCKET DE STORAGE PARA FOTOS
-- ============================================

INSERT INTO storage.buckets (id, name, public) 
VALUES ('produtos', 'produtos', true)
ON CONFLICT (id) DO NOTHING;

CREATE POLICY "Anyone can view product images"
ON storage.objects FOR SELECT TO public
USING (bucket_id = 'produtos');

CREATE POLICY "Loja pode upload product images"
ON storage.objects FOR INSERT TO authenticated
WITH CHECK (
  bucket_id = 'produtos' AND
  EXISTS (SELECT 1 FROM lojas WHERE lojas.email_admin = current_setting('app.settings.loja_email', TRUE) AND lojas.ativa = true)
);

CREATE POLICY "Loja pode update product images"
ON storage.objects FOR UPDATE TO authenticated
USING (
  bucket_id = 'produtos' AND
  EXISTS (SELECT 1 FROM lojas WHERE lojas.email_admin = current_setting('app.settings.loja_email', TRUE) AND lojas.ativa = true)
);

CREATE POLICY "Loja pode delete product images"
ON storage.objects FOR DELETE TO authenticated
USING (
  bucket_id = 'produtos' AND
  EXISTS (SELECT 1 FROM lojas WHERE lojas.email_admin = current_setting('app.settings.loja_email', TRUE) AND lojas.ativa = true)
);


-- ============================================
-- FIM DO SCRIPT
-- ============================================
