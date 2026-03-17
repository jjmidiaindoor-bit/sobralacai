-- ============================================
-- ISOLAMENTO DE LOJAS - ROW LEVEL SECURITY
-- ============================================
-- Este script adiciona isolamento entre lojas
-- Cada loja verá apenas seus próprios dados

-- ============================================
-- 0. FUNÇÃO RPC PARA DEFINIR EMAIL DA LOJA
-- ============================================
-- Esta função permite que o client defina o email da loja para RLS

CREATE OR REPLACE FUNCTION public.set_loja_email(loja_email TEXT)
RETURNS void AS $$
BEGIN
  PERFORM set_config('app.settings.loja_email', loja_email, false);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================
-- 1. ADICIONAR COLUNA loja_id NAS TABELAS
-- ============================================

-- Adicionar loja_id em categorias
ALTER TABLE categorias 
  ADD COLUMN IF NOT EXISTS loja_id UUID REFERENCES lojas(id) ON DELETE CASCADE;

-- Adicionar loja_id em produtos
ALTER TABLE produtos 
  ADD COLUMN IF NOT EXISTS loja_id UUID REFERENCES lojas(id) ON DELETE CASCADE;

-- Adicionar loja_id em pedidos
ALTER TABLE pedidos 
  ADD COLUMN IF NOT EXISTS loja_id UUID REFERENCES lojas(id) ON DELETE CASCADE;

-- Adicionar loja_id em configuracoes
ALTER TABLE configuracoes 
  ADD COLUMN IF NOT EXISTS loja_id UUID REFERENCES lojas(id) ON DELETE CASCADE;


-- ============================================
-- 2. ATUALIZAR DADOS EXISTENTES
-- ============================================
-- Vincula todos os dados existentes à loja "Açaí Express"

DO $$
DECLARE
  loja_id_uuid UUID;
BEGIN
  -- Pega o ID da loja "Açaí Express" ou "Super Admin"
  SELECT id INTO loja_id_uuid FROM lojas 
  WHERE email_admin = 'admin@acaiaqui.com' 
  LIMIT 1;
  
  -- Se não existir, usa a primeira loja
  IF loja_id_uuid IS NULL THEN
    SELECT id INTO loja_id_uuid FROM lojas LIMIT 1;
  END IF;
  
  -- Atualiza todas as tabelas com o loja_id
  UPDATE categorias SET loja_id = loja_id_uuid WHERE loja_id IS NULL;
  UPDATE produtos SET loja_id = loja_id_uuid WHERE loja_id IS NULL;
  UPDATE pedidos SET loja_id = loja_id_uuid WHERE loja_id IS NULL;
  UPDATE configuracoes SET loja_id = loja_id_uuid WHERE loja_id IS NULL;
END $$;


-- ============================================
-- 3. TORNAR loja_id OBRIGATÓRIO
-- ============================================

ALTER TABLE categorias ALTER COLUMN loja_id SET NOT NULL;
ALTER TABLE produtos ALTER COLUMN loja_id SET NOT NULL;
ALTER TABLE pedidos ALTER COLUMN loja_id SET NOT NULL;
ALTER TABLE configuracoes ALTER COLUMN loja_id SET NOT NULL;


-- ============================================
-- 4. CRIAR ÍNDICES PARA PERFORMANCE
-- ============================================

CREATE INDEX IF NOT EXISTS idx_categorias_loja_id ON categorias(loja_id);
CREATE INDEX IF NOT EXISTS idx_produtos_loja_id ON produtos(loja_id);
CREATE INDEX IF NOT EXISTS idx_pedidos_loja_id ON pedidos(loja_id);
CREATE INDEX IF NOT EXISTS idx_configuracoes_loja_id ON configuracoes(loja_id);


-- ============================================
-- 5. ROW LEVEL SECURITY - CATEGORIAS
-- ============================================

DROP POLICY IF EXISTS "Anyone can view categories" ON categorias;
DROP POLICY IF EXISTS "Authenticated users can manage categories" ON categorias;

-- Permitir leitura apenas se o email do admin pertencer à loja
CREATE POLICY "Loja pode ver suas categorias" ON categorias FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM lojas 
      WHERE lojas.id = categorias.loja_id 
      AND lojas.email_admin = current_setting('app.settings.loja_email', TRUE)
    )
  );

CREATE POLICY "Loja pode criar categorias" ON categorias FOR INSERT
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM lojas 
      WHERE lojas.id = categorias.loja_id 
      AND lojas.email_admin = current_setting('app.settings.loja_email', TRUE)
      AND lojas.ativa = true
    )
  );

CREATE POLICY "Loja pode atualizar categorias" ON categorias FOR UPDATE
  USING (
    EXISTS (
      SELECT 1 FROM lojas 
      WHERE lojas.id = categorias.loja_id 
      AND lojas.email_admin = current_setting('app.settings.loja_email', TRUE)
      AND lojas.ativa = true
    )
  );

CREATE POLICY "Loja pode excluir categorias" ON categorias FOR DELETE
  USING (
    EXISTS (
      SELECT 1 FROM lojas 
      WHERE lojas.id = categorias.loja_id 
      AND lojas.email_admin = current_setting('app.settings.loja_email', TRUE)
      AND lojas.ativa = true
    )
  );


-- ============================================
-- 6. ROW LEVEL SECURITY - PRODUTOS
-- ============================================

DROP POLICY IF EXISTS "Anyone can view products" ON produtos;
DROP POLICY IF EXISTS "Authenticated users can manage products" ON produtos;

CREATE POLICY "Loja pode ver seus produtos" ON produtos FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM lojas 
      WHERE lojas.id = produtos.loja_id 
      AND lojas.email_admin = current_setting('app.settings.loja_email', TRUE)
    )
  );

CREATE POLICY "Loja pode criar produtos" ON produtos FOR INSERT
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM lojas 
      WHERE lojas.id = produtos.loja_id 
      AND lojas.email_admin = current_setting('app.settings.loja_email', TRUE)
      AND lojas.ativa = true
    )
  );

CREATE POLICY "Loja pode atualizar produtos" ON produtos FOR UPDATE
  USING (
    EXISTS (
      SELECT 1 FROM lojas 
      WHERE lojas.id = produtos.loja_id 
      AND lojas.email_admin = current_setting('app.settings.loja_email', TRUE)
      AND lojas.ativa = true
    )
  );

CREATE POLICY "Loja pode excluir produtos" ON produtos FOR DELETE
  USING (
    EXISTS (
      SELECT 1 FROM lojas 
      WHERE lojas.id = produtos.loja_id 
      AND lojas.email_admin = current_setting('app.settings.loja_email', TRUE)
      AND lojas.ativa = true
    )
  );


-- ============================================
-- 7. ROW LEVEL SECURITY - PEDIDOS
-- ============================================

DROP POLICY IF EXISTS "Anyone can create orders" ON pedidos;
DROP POLICY IF EXISTS "Authenticated users can view orders" ON pedidos;

-- Clientes podem criar pedidos (sem loja_id)
CREATE POLICY "Clientes podem criar pedidos" ON pedidos FOR INSERT
  WITH CHECK (true);

-- Loja pode ver seus pedidos
CREATE POLICY "Loja pode ver seus pedidos" ON pedidos FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM lojas 
      WHERE lojas.id = pedidos.loja_id 
      AND lojas.email_admin = current_setting('app.settings.loja_email', TRUE)
    )
    OR loja_id IS NULL  -- Permite ver pedidos sem loja (antigos)
  );


-- ============================================
-- 8. ROW LEVEL SECURITY - CONFIGURACOES
-- ============================================

DROP POLICY IF EXISTS "Anyone can view settings" ON configuracoes;
DROP POLICY IF EXISTS "Authenticated users can update settings" ON configuracoes;

-- Qualquer um pode ver as configurações (público)
CREATE POLICY "Qualquer um pode ver configuracoes" ON configuracoes FOR SELECT
  USING (true);

-- Loja pode atualizar suas configurações
CREATE POLICY "Loja pode atualizar configuracoes" ON configuracoes FOR UPDATE
  USING (
    EXISTS (
      SELECT 1 FROM lojas 
      WHERE lojas.id = configuracoes.loja_id 
      AND lojas.email_admin = current_setting('app.settings.loja_email', TRUE)
      AND lojas.ativa = true
    )
  );


-- ============================================
-- 9. ROW LEVEL SECURITY - STORAGE (PRODUTOS)
-- ============================================

DROP POLICY IF EXISTS "Anyone can view product images" ON storage.objects;
DROP POLICY IF EXISTS "Authenticated users can upload product images" ON storage.objects;
DROP POLICY IF EXISTS "Authenticated users can update product images" ON storage.objects;
DROP POLICY IF EXISTS "Authenticated users can delete product images" ON storage.objects;

CREATE POLICY "Anyone can view product images"
ON storage.objects FOR SELECT TO public
USING (bucket_id = 'produtos');

-- Loja pode upload apenas na sua pasta
CREATE POLICY "Loja pode upload product images"
ON storage.objects FOR INSERT TO authenticated
WITH CHECK (
  bucket_id = 'produtos' AND
  EXISTS (
    SELECT 1 FROM lojas 
    WHERE lojas.email_admin = current_setting('app.settings.loja_email', TRUE)
    AND lojas.ativa = true
  )
);

CREATE POLICY "Loja pode update product images"
ON storage.objects FOR UPDATE TO authenticated
USING (
  bucket_id = 'produtos' AND
  EXISTS (
    SELECT 1 FROM lojas 
    WHERE lojas.email_admin = current_setting('app.settings.loja_email', TRUE)
    AND lojas.ativa = true
  )
);

CREATE POLICY "Loja pode delete product images"
ON storage.objects FOR DELETE TO authenticated
USING (
  bucket_id = 'produtos' AND
  EXISTS (
    SELECT 1 FROM lojas 
    WHERE lojas.email_admin = current_setting('app.settings.loja_email', TRUE)
    AND lojas.ativa = true
  )
);


-- ============================================
-- 10. FUNÇÃO PARA CRIAR DADOS INICIAIS DA LOJA
-- ============================================

CREATE OR REPLACE FUNCTION public.criar_dados_iniciais_loja(p_loja_id UUID)
RETURNS VOID AS $$
BEGIN
  -- Criar configurações padrão para a loja
  INSERT INTO configuracoes (loja_id, nome_loja, telefone_whatsapp, endereco)
  VALUES (p_loja_id, 'Nova Loja', '', '')
  ON CONFLICT DO NOTHING;
  
  -- Criar categorias padrão
  INSERT INTO categorias (loja_id, nome) 
  VALUES 
    (p_loja_id, 'AÇAÍS'),
    (p_loja_id, 'CREMES'),
    (p_loja_id, 'ADICIONAIS')
  ON CONFLICT DO NOTHING;
END;
$$ LANGUAGE plpgsql;


-- ============================================
-- 11. TRIGGER PARA CRIAR DADOS AO CRIAR LOJA
-- ============================================

CREATE OR REPLACE FUNCTION public.criar_dados_ao_criar_loja()
RETURNS TRIGGER AS $$
BEGIN
  -- Criar configurações padrão
  INSERT INTO configuracoes (loja_id, nome_loja, telefone_whatsapp, endereco)
  VALUES (NEW.id, NEW.nome_loja, NEW.telefone_whatsapp, NEW.endereco);
  
  -- Criar categorias padrão
  INSERT INTO categorias (loja_id, nome) 
  VALUES 
    (NEW.id, 'AÇAÍS'),
    (NEW.id, 'CREMES'),
    (NEW.id, 'ADICIONAIS');
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Remover trigger se existir e criar nova
DROP TRIGGER IF EXISTS trigger_criar_dados_loja ON lojas;
CREATE TRIGGER trigger_criar_dados_loja
  AFTER INSERT ON lojas
  FOR EACH ROW
  EXECUTE FUNCTION public.criar_dados_ao_criar_loja();


-- ============================================
-- 12. ATUALIZAR LOJAS EXISTENTES
-- ============================================
-- Executa a função para todas as lojas existentes

DO $$
DECLARE
  loja_record RECORD;
BEGIN
  FOR loja_record IN SELECT id FROM lojas LOOP
    PERFORM public.criar_dados_iniciais_loja(loja_record.id);
  END LOOP;
END $$;


-- ============================================
-- FIM DO SCRIPT DE ISOLAMENTO
-- ============================================
