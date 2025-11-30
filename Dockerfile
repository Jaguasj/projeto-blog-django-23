FROM python:3.11-alpine3.18
LABEL maintainer="jaguasj@gmail.com"

# Variáveis de ambiente
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

# Instala dependências do sistema
RUN apk update && \
    apk add --no-cache \
    bash \
    postgresql-dev \
    gcc \
    python3-dev \
    musl-dev \
    linux-headers \
    libffi-dev \
    netcat-openbsd

# Cria diretórios necessários primeiro
RUN mkdir -p /data/web/static && \
    mkdir -p /data/web/media && \
    mkdir -p /scripts

# Copia os arquivos
COPY djangoapp /djangoapp
COPY scripts /scripts

WORKDIR /djangoapp

# Cria venv e instala dependências
RUN python -m venv /venv && \
    /venv/bin/pip install --upgrade pip && \
    /venv/bin/pip install --no-cache-dir -r /djangoapp/requirements.txt

# Cria usuário
RUN adduser -D -s /bin/bash duser

# Ajusta permissões
RUN chown -R duser:duser /venv && \
    chown -R duser:duser /data/web/static && \
    chown -R duser:duser /data/web/media && \
    chown -R duser:duser /scripts && \
    chmod -R 755 /data/web/static && \
    chmod -R 755 /data/web/media && \
    chmod -R +x /scripts

# Configura PATH
ENV PATH="/scripts:/venv/bin:$PATH"

USER duser

CMD ["commands.sh"]