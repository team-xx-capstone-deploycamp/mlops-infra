FROM python:3.13-alpine

WORKDIR /app

COPY requirements.txt /app/
RUN pip install --no-cache-dir -r requirements.txt

COPY . /app

RUN chmod -R 777 /app
RUN mkdir -p /mlflow && chmod -R 777 /mlflow

EXPOSE 5000