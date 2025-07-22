# MLOps Infrastructure

[![Manual Deployment](https://github.com/team-xx-capstone-deploycamp/mlops-infra/actions/workflows/manual-deployment.yml/badge.svg)](https://github.com/team-xx-capstone-deploycamp/mlops-infra/actions/workflows/manual-deployment.yml)

This repository contains the infrastructure for MLOps using Docker Compose.

## Services

The infrastructure includes the following services:

- **MinIO**: Object storage service compatible with Amazon S3
- **HAProxy**: High-availability load balancer and proxy server
- **Certbot**: Let's Encrypt client for SSL certificate management

## Getting Started

### Prerequisites

- Docker
- Docker Compose

### Local Development

For local development, you can create a `.env` file with your secrets:

```
MINIO_ROOT_USER=your_minio_user
MINIO_ROOT_PASSWORD=your_minio_password
```

Then run:

```bash
docker-compose -f docker-compose.base.yaml --env-file .env up -d
```

## Accessing Services

- **MinIO API**: https://minio.capstone.pebrisulistiyo.com
- **MinIO Console**: https://minio.capstone.pebrisulistiyo.com:9001
- **HAProxy Stats**: http://localhost:8404

## Configuration

### MinIO

MinIO is configured with the following settings:

- **Username**: `${MINIO_ROOT_USER}` (default: minioadmin)
- **Password**: `${MINIO_ROOT_PASSWORD}` (default: minioadmin)
- **Data Directory**: `/data`
- **Domain**: minio.capstone.pebrisulistiyo.com

### HAProxy

HAProxy is configured to route traffic to MinIO:

- Port 80: Redirects to HTTPS (port 443)
- Port 443: Routes to MinIO API (port 9000) with SSL
- Port 9001: Routes to MinIO Console (port 9001) with SSL
- Port 8404: HAProxy stats page

### Certbot

Certbot is configured to obtain and renew SSL certificates for:

- minio.capstone.pebrisulistiyo.com

## SSL Configuration

The infrastructure uses Let's Encrypt for SSL certificates. The certificates are automatically obtained and renewed by Certbot. HAProxy is configured to use these certificates for HTTPS connections.

## Deployment

### Manual Deployment

You can use the GitHub Actions workflow to deploy the services to a VPS:

1. Set up the following secrets in your GitHub repository:
   - `SSH_PRIVATE_KEY`: SSH private key for connecting to the VPS
   - `VPS_HOST`: Hostname or IP address of the VPS
   - `VPS_USERNAME`: Username for SSH connection to the VPS
   - `MINIO_ROOT_USER`: MinIO root username
   - `MINIO_ROOT_PASSWORD`: MinIO root password

2. Go to the Actions tab in your GitHub repository
3. Select the "Manual Deployment" workflow
4. Click "Run workflow"
5. Select the service you want to deploy (leave empty to deploy all services)
6. Click "Run workflow"

The workflow will:
1. Connect to the VPS via SSH
2. Create necessary directories
3. Copy configuration files
4. Run docker-compose to deploy the services

### Local Deployment

The infrastructure is deployed using Docker Compose. To deploy all services:

```bash
docker-compose -f docker-compose.base.yaml up -d
```

To deploy a specific service:

```bash
docker-compose -f docker-compose.base.yaml up -d <service_name>
```

## License

This project is licensed under the MIT License - see the LICENSE file for details.
