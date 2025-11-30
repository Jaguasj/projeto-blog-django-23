#!/bin/bash

# O shell irá encerrar a execução do script quando um comando falhar
set -e

echo "🟡 Aguardando inicialização do PostgreSQL..."

# Verifica se variáveis de ambiente estão definidas
: "${POSTGRES_HOST:?Erro: POSTGRES_HOST não definida}"
: "${POSTGRES_PORT:?Erro: POSTGRES_PORT não definida}"

# Instala netcat se não estiver disponível (para Alpine Linux)
if ! command -v nc &> /dev/null; then
    echo "📦 Instalando netcat..."
    apk add --no-cache netcat-openbsd
fi

# Aguarda PostgreSQL ficar disponível
while ! nc -z $POSTGRES_HOST $POSTGRES_PORT; do
    echo "🟡 Aguardando PostgreSQL ($POSTGRES_HOST:$POSTGRES_PORT)..."
    sleep 2
done

echo "✅ PostgreSQL está rodando ($POSTGRES_HOST:$POSTGRES_PORT)"

# Comandos Django
echo "📦 Coletando arquivos estáticos..."
python manage.py collectstatic --noinput

echo "🔄 Criando migrações..."
python manage.py makemigrations --noinput

echo "💾 Aplicando migrações..."
python manage.py migrate --noinput

echo "🚀 Iniciando servidor Django..."
exec python manage.py runserver 0.0.0.0:8000