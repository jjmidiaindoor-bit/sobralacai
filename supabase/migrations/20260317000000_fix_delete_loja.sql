-- ============================================
-- MIGRATION: Correção exclusão de lojas
-- ============================================
-- Cria função para excluir loja em cascata de forma segura

-- Drop da função se existir
DROP FUNCTION IF EXISTS public.excluir_loja_com_cascade(uuid);

-- Cria função que exclui todos os dados relacionados e depois a loja
CREATE OR REPLACE FUNCTION public.excluir_loja_com_cascade(loja_id uuid)
RETURNS void AS $$
DECLARE
  tabela record;
  sql text;
BEGIN
  -- Lista de tabelas que podem referenciar a loja
  FOR tabela IN SELECT unnest(ARRAY['categorias', 'produtos', 'pedidos', 'configuracoes']) AS nome
  LOOP
    BEGIN
      -- Tenta excluir registros da tabela que referenciam esta loja
      EXECUTE format('DELETE FROM %I WHERE loja_id = $1', tabela.nome) USING loja_id;
    EXCEPTION WHEN OTHERS THEN
      -- Ignora erro se a tabela não existir ou não tiver loja_id
      RAISE NOTICE 'Erro ao limpar tabela %: %', tabela.nome, SQLERRM;
    END;
  END LOOP;
  
  -- Agora exclui a loja
  DELETE FROM lojas WHERE id = loja_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Concede permissão para authenticated executarem a função
GRANT EXECUTE ON FUNCTION public.excluir_loja_com_cascade(uuid) TO authenticated;

-- ============================================
-- Alternativa: Adiciona ON DELETE CASCADE nas foreign keys
-- ============================================
-- Se preferir, pode adicionar CASCADE nas constraints existentes

-- Verifica e atualiza constraint de categorias
DO $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM information_schema.constraint_column_usage 
    WHERE table_name = 'categorias' AND column_name = 'loja_id'
  ) THEN
    -- Drop e recria com CASCADE
    ALTER TABLE categorias DROP CONSTRAINT IF EXISTS categorias_loja_id_fkey;
    ALTER TABLE categorias ADD CONSTRAINT categorias_loja_id_fkey 
      FOREIGN KEY (loja_id) REFERENCES lojas(id) ON DELETE CASCADE;
  END IF;
EXCEPTION WHEN OTHERS THEN
  NULL;
END $$;

-- Verifica e atualiza constraint de produtos
DO $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM information_schema.constraint_column_usage 
    WHERE table_name = 'produtos' AND column_name = 'loja_id'
  ) THEN
    ALTER TABLE produtos DROP CONSTRAINT IF EXISTS produtos_loja_id_fkey;
    ALTER TABLE produtos ADD CONSTRAINT produtos_loja_id_fkey 
      FOREIGN KEY (loja_id) REFERENCES lojas(id) ON DELETE CASCADE;
  END IF;
EXCEPTION WHEN OTHERS THEN
  NULL;
END $$;

-- Verifica e atualiza constraint de pedidos
DO $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM information_schema.constraint_column_usage 
    WHERE table_name = 'pedidos' AND column_name = 'loja_id'
  ) THEN
    ALTER TABLE pedidos DROP CONSTRAINT IF EXISTS pedidos_loja_id_fkey;
    ALTER TABLE pedidos ADD CONSTRAINT pedidos_loja_id_fkey 
      FOREIGN KEY (loja_id) REFERENCES lojas(id) ON DELETE CASCADE;
  END IF;
EXCEPTION WHEN OTHERS THEN
  NULL;
END $$;

-- Verifica e atualiza constraint de configuracoes
DO $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM information_schema.constraint_column_usage 
    WHERE table_name = 'configuracoes' AND column_name = 'loja_id'
  ) THEN
    ALTER TABLE configuracoes DROP CONSTRAINT IF EXISTS configuracoes_loja_id_fkey;
    ALTER TABLE configuracoes ADD CONSTRAINT configuracoes_loja_id_fkey 
      FOREIGN KEY (loja_id) REFERENCES lojas(id) ON DELETE CASCADE;
  END IF;
EXCEPTION WHEN OTHERS THEN
  NULL;
END $$;
