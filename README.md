# MLOps Infrastructure

[![Manual Deployment](https://github.com/team-xx-capstone-deploycamp/mlops-infra/actions/workflows/manual-deployment.yml/badge.svg)](https://github.com/team-xx-capstone-deploycamp/mlops-infra/actions/workflows/manual-deployment.yml)

This repository contains the infrastructure for MLOps using Docker Compose.

## Services

The infrastructure includes the following services:

- **MinIO**: Object storage service compatible with Amazon S3
- **Nginx**: Web server and reverse proxy
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

- **MinIO API**: https://minio.mydomain.com
- **MinIO Console**: https://console.minio.mydomain.com

## Configuration

### MinIO

MinIO is configured with the following settings:

- **Username**: `${MINIO_ROOT_USER}` (default: minioadmin)
- **Password**: `${MINIO_ROOT_PASSWORD}` (default: minioadminpassword123)
- **Data Directory**: `/data`
- **Domain**: minio.mydomain.com
- **Server URL**: https://minio.mydomain.com
- **Browser Redirect URL**: https://console.minio.mydomain.com

### Nginx

Nginx is configured as a reverse proxy for the services:

- Port 80: Serves HTTP traffic and Let's Encrypt challenges
- Port 443: Serves HTTPS traffic with SSL certificates
- Configured with rate limiting and security headers
- Uses templates for generating service-specific configurations

### Certbot

Certbot is configured to obtain and renew SSL certificates for domains. The certificates are automatically renewed every 12 hours.

## SSL Configuration

The infrastructure uses Let's Encrypt for SSL certificates. The certificates are automatically obtained and renewed by Certbot. Nginx is configured to use these certificates for HTTPS connections.

## Domain Management

### How the Automation Works

The infrastructure includes scripts to automate the process of adding new domains and configuring SSL certificates.

#### Adding a New Domain (Automatic Process)

Run the command:
```bash
bash ./scripts/add-domain.sh domain4.example.com service4 8004
```

What happens automatically:
1. Creates `nginx/conf.d/domain4.example.com.conf` with HTTP config
2. Reloads nginx to serve HTTP traffic
3. Requests SSL certificate from Let's Encrypt via ACME challenge
4. Updates the same config file to include HTTPS configuration
5. Reloads nginx again with SSL enabled

The generated config file (`domain4.example.com.conf`) will contain both HTTP redirect and HTTPS server blocks.

#### Manual Domain Management

For more control over the domain configuration process, you can use the individual scripts:

1. Generate HTTP-only configuration:
```bash
bash ./scripts/generate-config.sh domain4.example.com service4 8004 false
```

2. Generate HTTPS configuration (requires existing SSL certificate):
```bash
bash ./scripts/generate-config.sh domain4.example.com service4 8004 true
```

3. Get SSL certificate only:
```bash
bash ./scripts/ssl-manager.sh get-cert domain4.example.com admin@example.com
```

4. Enable SSL for an existing domain:
```bash
bash ./scripts/ssl-manager.sh enable-ssl domain4.example.com service4 8004 admin@example.com
```

5. Update configuration to use HTTPS:
```bash
bash ./scripts/ssl-manager.sh update-config domain4.example.com service4 8004
```

### Checking Domain Configuration

Before adding a new domain, you can check if a configuration already exists:

```bash
ls nginx/conf.d | grep domain4.example.com
```

If the configuration exists, you can check if it's using HTTP or HTTPS:

```bash
grep -q "listen 443 ssl" nginx/conf.d/domain4.example.com.conf && echo "HTTPS enabled" || echo "HTTP only"
```

### SSL Certificate Renewal

SSL certificates are automatically renewed by the Certbot service. To manually trigger a renewal:

```bash
docker compose exec certbot certbot renew
```

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
5. Configure the workflow:
   - **Service**: Select the service you want to deploy (leave empty to deploy all services)
   - **Domain Management** (optional):
     - **Domain**: Domain name (e.g., domain.example.com)
     - **Service Name**: Docker service name for the domain
     - **Service Port**: Internal port for the service
     - **Enable SSL**: Whether to enable SSL for the domain (default: true)
     - **Admin Email**: Email for Let's Encrypt (default: admin@example.com)
6. Click "Run workflow"

The workflow will:
1. Connect to the VPS via SSH
2. Create necessary directories
3. Copy configuration files
4. Deploy the selected services using docker-compose
5. If domain parameters are provided:
   - Check if a domain configuration already exists
   - If it exists:
     - Check if it's using HTTPS
     - If it's using HTTPS, check if the SSL certificate needs renewal
     - If it's not using HTTPS and enable_ssl is true, enable SSL
   - If it doesn't exist, create a new domain configuration

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
