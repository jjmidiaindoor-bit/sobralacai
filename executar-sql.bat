@echo off
echo ============================================
echo  SOBRALACAI - EXECUTAR SQL NO SUPABASE
echo ============================================
echo.
echo Servidor: 147.93.3.69
echo Usuario: root
echo Senha: tenderbr0
echo.
echo ============================================
echo  COPIE E COLE ESTE SQL NO SUPABASE:
echo ============================================
echo.
echo 1. Acesse: https://supab.zedarede.org/project/default/sql/new
echo 2. Login: jjmidia / Tenderbr0
echo 3. Copie TODO o SQL abaixo e cole no editor
echo 4. Clique em RUN
echo.
echo ============================================
echo.

echo SQL COMPLETO (copie da proxima linha ate o fim):
echo.
echo -- ============================================
echo -- SOBRALACAI - BANCO DE DADOS COMPLETO
echo -- ============================================
echo.
echo CREATE TABLE IF NOT EXISTS lojas (
echo   id UUID PRIMARY KEY DEFAULT gen_random_uuid^(^),
echo   nome_loja TEXT NOT NULL,
echo   nome_admin TEXT NOT NULL,
echo   email_admin TEXT NOT NULL UNIQUE,
echo   senha_admin TEXT NOT NULL,
echo   telefone_whatsapp TEXT,
echo   endereco TEXT,
echo   ativa BOOLEAN DEFAULT true,
echo   created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW^(^),
echo   updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW^(^)
echo ^);
echo.
echo ALTER TABLE lojas ENABLE ROW LEVEL SECURITY;
echo CREATE POLICY "Lojas select" ON lojas FOR SELECT USING ^(true^);
echo CREATE POLICY "Lojas insert" ON lojas FOR INSERT WITH CHECK ^(true^);
echo CREATE POLICY "Lojas update" ON lojas FOR UPDATE USING ^(true^);
echo CREATE POLICY "Lojas delete" ON lojas FOR DELETE USING ^(true^);
echo.
echo CREATE OR REPLACE FUNCTION update_updated_at_column^(^)
echo RETURNS TRIGGER AS \$\$
echo BEGIN
echo   NEW.updated_at = NOW^(^);
echo   RETURN NEW;
echo END;
echo \$\$ LANGUAGE plpgsql;
echo.
echo CREATE TRIGGER update_lojas_updated_at BEFORE UPDATE ON lojas
echo   FOR EACH ROW EXECUTE FUNCTION update_updated_at_column^(^);
echo.
echo INSERT INTO lojas ^(nome_loja, nome_admin, email_admin, senha_admin, ativa^)
echo VALUES ^('Super Admin', 'Super Administrador', 'super@acaiaqui.com', 'super123', true^)
echo ON CONFLICT ^(email_admin^) DO NOTHING;
echo.
echo INSERT INTO lojas ^(nome_loja, nome_admin, email_admin, senha_admin, telefone_whatsapp, endereco, ativa^)
echo VALUES ^('Acaciai Express', 'Administrador', 'admin@acaiaqui.com', 'admin123', '^('85^) 99999-9999'^', 'Rua Exemplo, 123', true^)
echo ON CONFLICT ^(email_admin^) DO NOTHING;
echo.
echo -- CATEGORIAS
echo CREATE TABLE IF NOT EXISTS categorias (
echo   id UUID PRIMARY KEY DEFAULT gen_random_uuid^(^),
echo   loja_id UUID REFERENCES lojas^(id^) ON DELETE CASCADE,
echo   nome TEXT NOT NULL,
echo   created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW^(^),
echo   updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW^(^)
echo ^);
echo.
echo ALTER TABLE categorias ENABLE ROW LEVEL SECURITY;
echo CREATE POLICY "Categorias select" ON categorias FOR SELECT USING ^(true^);
echo.
echo -- PRODUTOS
echo CREATE TABLE IF NOT EXISTS produtos (
echo   id UUID PRIMARY KEY DEFAULT gen_random_uuid^(^),
echo   loja_id UUID REFERENCES lojas^(id^) ON DELETE CASCADE,
echo   categoria_id UUID REFERENCES categorias^(id^) ON DELETE SET NULL,
echo   nome TEXT NOT NULL,
echo   descricao TEXT,
echo   preco DECIMAL^(10,2^) NOT NULL DEFAULT 0,
echo   foto_url TEXT,
echo   created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW^(^),
echo   updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW^(^)
echo ^);
echo.
echo ALTER TABLE produtos ENABLE ROW LEVEL SECURITY;
echo CREATE POLICY "Produtos select" ON produtos FOR SELECT USING ^(true^);
echo.
echo -- CONFIGURACOES
echo CREATE TABLE IF NOT EXISTS configuracoes (
echo   id UUID PRIMARY KEY DEFAULT gen_random_uuid^(^),
echo   loja_id UUID REFERENCES lojas^(id^) ON DELETE CASCADE,
echo   nome_loja TEXT NOT NULL,
echo   telefone_whatsapp TEXT NOT NULL,
echo   endereco TEXT,
echo   logo_url TEXT,
echo   banner_url TEXT,
echo   slogan TEXT,
echo   created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW^(^),
echo   updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW^(^)
echo ^);
echo.
echo ALTER TABLE configuracoes ENABLE ROW LEVEL SECURITY;
echo CREATE POLICY "Configuracoes select" ON configuracoes FOR SELECT USING ^(true^);
echo.
echo -- PEDIDOS
echo CREATE TABLE IF NOT EXISTS pedidos (
echo   id UUID PRIMARY KEY DEFAULT gen_random_uuid^(^),
echo   loja_id UUID REFERENCES lojas^(id^) ON DELETE CASCADE,
echo   nome_cliente TEXT NOT NULL,
echo   telefone TEXT NOT NULL,
echo   endereco TEXT,
echo   observacao TEXT,
echo   detalhes_pedido TEXT NOT NULL,
echo   total DECIMAL^(10,2^) NOT NULL DEFAULT 0,
echo   created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW^(^)
echo ^);
echo.
echo -- ENTREGADORES
echo CREATE TABLE IF NOT EXISTS entregadores (
echo   id UUID PRIMARY KEY DEFAULT gen_random_uuid^(^),
echo   loja_id UUID REFERENCES lojas^(id^) ON DELETE CASCADE,
echo   nome TEXT NOT NULL,
echo   email TEXT NOT NULL UNIQUE,
echo   senha_hash TEXT NOT NULL,
echo   telefone TEXT,
echo   placa_veiculo TEXT,
echo   modelo_veiculo TEXT,
echo   cor_veiculo TEXT,
echo   ativo BOOLEAN DEFAULT true,
echo   created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW^(^),
echo   updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW^(^)
echo ^);
echo.
echo -- ENTREGAS
echo CREATE TABLE IF NOT EXISTS entregas (
echo   id UUID PRIMARY KEY DEFAULT gen_random_uuid^(^),
echo   pedido_id UUID REFERENCES pedidos^(id^) ON DELETE SET NULL,
echo   loja_id UUID REFERENCES lojas^(id^) ON DELETE CASCADE,
echo   entregador_id UUID REFERENCES entregadores^(id^) ON DELETE SET NULL,
echo   status TEXT DEFAULT 'pendente',
echo   endereco_entrega TEXT,
echo   telefone_cliente TEXT,
echo   observacoes TEXT,
echo   valor_entrega DECIMAL^(10,2^),
echo   aceita_em TIMESTAMP WITH TIME ZONE,
echo   entregue_em TIMESTAMP WITH TIME ZONE,
echo   created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW^(^)
echo ^);
echo.
echo -- DADOS INICIAIS
echo INSERT INTO configuracoes ^(nome_loja, telefone_whatsapp, endereco, slogan^)
echo VALUES ^('Acaciai Express', '^('85^) 99999-9999'^', 'Rua Exemplo, 123', 'O melhor acaciai da cidade'^)
echo ON CONFLICT DO NOTHING;
echo.
echo INSERT INTO categorias ^(nome^) VALUES ^('ACACAI'^) ON CONFLICT DO NOTHING;
echo INSERT INTO categorias ^(nome^) VALUES ^('CREMES'^) ON CONFLICT DO NOTHING;
echo INSERT INTO categorias ^(nome^) VALUES ^('ACOMPANHAMENTOS'^) ON CONFLICT DO NOTHING;
echo.
echo -- ============================================
echo -- CONCLUIDO!
echo -- ============================================
echo.
echo ============================================
echo.
echo Agora va no Supabase e execute este SQL!
echo.
pause
