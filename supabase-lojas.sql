-- ============================================
-- SCRIPT DE CRIAÇÃO - TABELA DE LOJAS
-- ============================================

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

-- Row Level Security
ALTER TABLE lojas ENABLE ROW LEVEL SECURITY;

-- Política para permitir leitura pública (ajuste conforme necessário)
CREATE POLICY "Lojas são visíveis para todos" ON lojas
  FOR SELECT USING (true);

-- Política para inserção
CREATE POLICY "Inserção de lojas" ON lojas
  FOR INSERT WITH CHECK (true);

-- Política para atualização
CREATE POLICY "Atualização de lojas" ON lojas
  FOR UPDATE USING (true);

-- Política para exclusão
CREATE POLICY "Exclusão de lojas" ON lojas
  FOR DELETE USING (true);

-- Trigger para updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_lojas_updated_at BEFORE UPDATE ON lojas
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- ============================================
-- DADOS INICIAIS
-- ============================================

-- Super Admin (senha: super123)
INSERT INTO lojas (nome_loja, nome_admin, email_admin, senha_admin, ativa)
VALUES ('Super Admin', 'Super Administrador', 'super@acaiaqui.com', 'super123', true)
ON CONFLICT (email_admin) DO NOTHING;

-- Loja de Exemplo (senha: admin123)
INSERT INTO lojas (nome_loja, nome_admin, email_admin, senha_admin, telefone_whatsapp, endereco, ativa)
VALUES ('Açaí Express', 'Administrador', 'admin@acaiaqui.com', 'admin123', '(85) 99999-9999', 'Rua Exemplo, 123', true)
ON CONFLICT (email_admin) DO NOTHING;
