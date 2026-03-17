-- Configurar RLS para todas as tabelas
ALTER TABLE lojas ENABLE ROW LEVEL SECURITY;
ALTER TABLE categorias ENABLE ROW LEVEL SECURITY;
ALTER TABLE produtos ENABLE ROW LEVEL SECURITY;
ALTER TABLE configuracoes ENABLE ROW LEVEL SECURITY;
ALTER TABLE pedidos ENABLE ROW LEVEL SECURITY;
ALTER TABLE entregadores ENABLE ROW LEVEL SECURITY;
ALTER TABLE entregas ENABLE ROW LEVEL SECURITY;

-- Políticas para Lojas
DROP POLICY IF EXISTS "Lojas select" ON lojas;
DROP POLICY IF EXISTS "Lojas insert" ON lojas;
DROP POLICY IF EXISTS "Lojas update" ON lojas;
DROP POLICY IF EXISTS "Lojas delete" ON lojas;

CREATE POLICY "Lojas select" ON lojas FOR SELECT USING (true);
CREATE POLICY "Lojas insert" ON lojas FOR INSERT WITH CHECK (true);
CREATE POLICY "Lojas update" ON lojas FOR UPDATE USING (true);
CREATE POLICY "Lojas delete" ON lojas FOR DELETE USING (true);

-- Políticas para Categorias
DROP POLICY IF EXISTS "Categorias select" ON categorias;
CREATE POLICY "Categorias select" ON categorias FOR SELECT USING (true);

-- Políticas para Produtos
DROP POLICY IF EXISTS "Produtos select" ON produtos;
CREATE POLICY "Produtos select" ON produtos FOR SELECT USING (true);

-- Políticas para Configuracoes
DROP POLICY IF EXISTS "Configuracoes select" ON configuracoes;
CREATE POLICY "Configuracoes select" ON configuracoes FOR SELECT USING (true);

-- Inserir dados iniciais (se não existirem)
INSERT INTO configuracoes (nome_loja, telefone_whatsapp, endereco, slogan)
VALUES ('Açaí Express', '(85) 99999-9999', 'Rua Exemplo, 123', 'O melhor açaí da cidade')
ON CONFLICT DO NOTHING;

INSERT INTO categorias (nome) VALUES ('AÇAÍ') ON CONFLICT DO NOTHING;
INSERT INTO categorias (nome) VALUES ('CREMES') ON CONFLICT DO NOTHING;
INSERT INTO categorias (nome) VALUES ('ACOMPANHAMENTOS') ON CONFLICT DO NOTHING;

-- Verificar tabelas
SELECT 'Tabelas criadas com sucesso!' as status;
