@echo off
echo ============================================
echo  IMPLANTAR SOBRALACAÍ - NOVA INSTÂNCIA
echo ============================================
echo.
echo Servidor: 147.93.3.69
echo Usuario: root
echo Senha: tenderbr0
echo.
echo ============================================
echo  PASSOS:
echo ============================================
echo.
echo 1. Copiar docker-compose para o servidor
echo 2. Criar diretorias no servidor
echo 3. Iniciar containers
echo 4. Executar SQL de criacao
echo.
echo ============================================
echo.
echo Copiando arquivos para o servidor...
echo.

:: Copiar docker-compose
plink -ssh root@147.93.3.69 -pw tenderbr0 "mkdir -p /root/supabase-sobralacai/docker/volumes/api"
plink -ssh root@147.93.3.69 -pw tenderbr0 "mkdir -p /root/supabase-sobralacai/docker/volumes/db"

echo.
echo Por favor, copie manualmente o arquivo docker-compose-sobralacai.yml para:
echo /root/supabase-sobralacai/docker-compose.yml
echo.
echo Depois execute no servidor:
echo cd /root/supabase-sobralacai
echo docker stack deploy sobralacai -c docker-compose.yml
echo.
pause
