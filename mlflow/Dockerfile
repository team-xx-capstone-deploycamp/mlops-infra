FROM python:3.11-alpine

WORKDIR /app

# Install system dependencies for psycopg2
RUN apk add --no-cache postgresql-dev gcc python3-dev musl-dev

COPY requirements.txt /app/
RUN pip install --no-cache-dir -r requirements.txt

COPY . /app

RUN chmod -R 777 /app
RUN mkdir -p /mlflow && chmod -R 777 /mlflow

EXPOSE 5000
