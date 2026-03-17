-- ============================================
-- CRIAR USUÁRIOS NO SUPABASE AUTH
-- ============================================

-- Deletar usuários existentes se houver
DELETE FROM auth.users WHERE email = 'super@acaiaqui.com';
DELETE FROM auth.users WHERE email = 'admin@acaiaqui.com';

-- Super Admin
INSERT INTO auth.users (
  instance_id,
  id,
  aud,
  role,
  email,
  encrypted_password,
  email_confirmed_at,
  recovery_sent_at,
  last_sign_in_at,
  raw_app_meta_data,
  raw_user_meta_data,
  confirmation_token,
  email_change,
  email_change_token_new,
  recovery_token
) VALUES (
  '00000000-0000-0000-0000-000000000000',
  gen_random_uuid(),
  'authenticated',
  'authenticated',
  'super@acaiaqui.com',
  crypt('super123', gen_salt('bf')),
  NOW(),
  NOW(),
  NOW(),
  '{"provider":"email","providers":["email"]}',
  '{"nome":"Super Administrador","role":"super-admin"}',
  '',
  '',
  '',
  ''
);

-- Admin da Loja
INSERT INTO auth.users (
  instance_id,
  id,
  aud,
  role,
  email,
  encrypted_password,
  email_confirmed_at,
  recovery_sent_at,
  last_sign_in_at,
  raw_app_meta_data,
  raw_user_meta_data,
  confirmation_token,
  email_change,
  email_change_token_new,
  recovery_token
) VALUES (
  '00000000-0000-0000-0000-000000000000',
  gen_random_uuid(),
  'authenticated',
  'authenticated',
  'admin@acaiaqui.com',
  crypt('admin123', gen_salt('bf')),
  NOW(),
  NOW(),
  NOW(),
  '{"provider":"email","providers":["email"]}',
  '{"nome":"Administrador","role":"admin"}',
  '',
  '',
  '',
  ''
);

-- Verificar usuários criados
SELECT email, role, created_at FROM auth.users WHERE email IN ('super@acaiaqui.com', 'admin@acaiaqui.com');
