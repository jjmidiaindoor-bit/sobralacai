-- ============================================
-- CRIAR USUÁRIOS PARA SOBRALACAI
-- ============================================

-- Deletar usuários existentes se houver
DELETE FROM auth.users WHERE email = 'admin@sobralacai.com';

-- Admin SobralAçaí
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
  recovery_token,
  created_at,
  updated_at
) VALUES (
  '00000000-0000-0000-0000-000000000000',
  gen_random_uuid(),
  'authenticated',
  'authenticated',
  'admin@sobralacai.com',
  crypt('admin123', gen_salt('bf')),
  NOW(),
  NOW(),
  NOW(),
  '{"provider":"email","providers":["email"]}',
  '{"nome":"Administrador SobralAçaí","role":"admin","schema":"sobralacai"}',
  '',
  '',
  '',
  '',
  NOW(),
  NOW()
);

-- Verificar
SELECT email, raw_user_meta_data->>'schema' as schema FROM auth.users WHERE email = 'admin@sobralacai.com';
