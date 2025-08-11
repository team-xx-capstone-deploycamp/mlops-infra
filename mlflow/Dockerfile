FROM python:3.13-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    g++ \
    gcc \
    python3-dev \
    gettext-base \
    && rm -rf /var/lib/apt/lists/*

RUN pip install --no-cache-dir \
    mlflow==3.1.4 \
    mlflow[auth] \
    psycopg2-binary \
    boto3

WORKDIR /app

COPY auth_config.ini.template /app/

RUN chmod -R 777 /app
RUN mkdir -p /mlflow && chmod -R 777 /mlflow
