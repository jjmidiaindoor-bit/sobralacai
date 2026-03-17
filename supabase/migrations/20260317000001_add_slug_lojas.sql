-- ============================================
-- MIGRATION: Adiciona slug nas lojas para URL amigável
-- ============================================

-- Adiciona coluna slug
ALTER TABLE lojas ADD COLUMN IF NOT EXISTS slug TEXT UNIQUE;

-- Cria índice para performance
CREATE INDEX IF NOT EXISTS idx_lojas_slug ON lojas(slug);

-- Cria função para gerar slug único
CREATE OR REPLACE FUNCTION public.gerar_slug_unico(nome TEXT, loja_id UUID DEFAULT NULL)
RETURNS TEXT AS $$
DECLARE
  base_slug TEXT;
  slug_final TEXT;
  contador INTEGER := 0;
BEGIN
  -- Gera slug base: lowercase, remove acentos, substitui espaços por hífens
  base_slug := LOWER(
    REPLACE(
      REPLACE(
        REPLACE(
          REPLACE(
            REPLACE(
              REPLACE(
                REPLACE(
                  REPLACE(nome, 'á', 'a'), 'ã', 'a'), 'â', 'a'),
                'é', 'e'), 'ê', 'e'),
              'í', 'i'), 'ó', 'o'), 'õ', 'o'), 'ô', 'o'
    )
  );
  base_slug := REPLACE(
    REPLACE(
      REPLACE(
        REPLACE(
          REPLACE(
            REPLACE(
              REPLACE(
                REPLACE(
                  REPLACE(
                    REPLACE(base_slug, 'ç', 'c'), 'ü', 'u'), 'ñ', 'n'
                  ), 'à', 'a'
                ), 'ä', 'a'
              ), 'ë', 'e'
            ), 'ï', 'i'
          ), 'ö', 'o'
        ), 'ß', 's'
      ), ' ', '-'
    );
  
  -- Remove caracteres especiais
  base_slug := REGEXP_REPLACE(base_slug, '[^a-z0-9-]', '', 'g');
  
  -- Remove hífens múltiplos
  base_slug := REGEXP_REPLACE(base_slug, '-+', '-', 'g');
  
  -- Remove hífens do início e fim
  base_slug := TRIM(BOTH '-' FROM base_slug);
  
  -- Verifica se já existe slug
  slug_final := base_slug;
  WHILE EXISTS (
    SELECT 1 FROM lojas WHERE slug = slug_final AND id != COALESCE(loja_id, '00000000-0000-0000-0000-000000000000'::UUID)
  ) LOOP
    contador := contador + 1;
    slug_final := base_slug || '-' || contador;
  END LOOP;
  
  RETURN slug_final;
END;
$$ LANGUAGE plpgsql;

-- Cria trigger para gerar slug automaticamente ao criar/editar loja
CREATE OR REPLACE FUNCTION public.atualizar_slug_loja()
RETURNS TRIGGER AS $$
BEGIN
  -- Só gera slug se não foi fornecido ou se o nome mudou
  IF NEW.slug IS NULL OR NEW.nome_loja != OLD.nome_loja THEN
    NEW.slug := public.gerar_slug_unico(NEW.nome_loja, NEW.id);
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Drop trigger se existir e cria novo
DROP TRIGGER IF EXISTS trigger_atualizar_slug_loja ON lojas;
CREATE TRIGGER trigger_atualizar_slug_loja 
  BEFORE INSERT OR UPDATE ON lojas
  FOR EACH ROW EXECUTE FUNCTION public.atualizar_slug_loja();

-- Gera slug para lojas existentes
UPDATE lojas SET slug = NULL WHERE slug IS NULL;
