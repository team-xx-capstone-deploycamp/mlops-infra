#!/bin/bash

source scripts/generate-config.sh

get_ssl_certificate() {
    local domain=$1
    local email=${2:-"admin@example.com"}
    
    echo "Getting SSL certificate for $domain..."
    
    # Get SSL certificate using certbot
    docker compose run --rm certbot certonly \
        --webroot \
        --webroot-path=/var/www/certbot \
        --email "$email" \
        --agree-tos \
        --no-eff-email \
        --force-renewal \
        -d "$domain"
    
    if [ $? -eq 0 ]; then
        echo "✓ SSL certificate obtained for $domain"
        return 0
    else
        echo "✗ Failed to get SSL certificate for $domain"
        return 1
    fi
}

update_domain_to_https() {
    local domain=$1
    local service_name=$2
    local service_port=$3
    
    echo "Updating $domain configuration to use HTTPS..."
    
    generate_config "$domain" "$service_name" "$service_port" "true"
    
    docker exec -it nginx nginx -t
    
    if [ $? -eq 0 ]; then
        echo "✓ Nginx configuration is valid"
        docker exec -it nginx nginx -s reload
        echo "✓ Nginx reloaded with new SSL configuration"
        return 0
    else
        echo "✗ Nginx configuration is invalid"
        generate_config "$domain" "$service_name" "$service_port" "false"
        return 1
    fi
}

enable_ssl_for_domain() {
    local domain=$1
    local service_name=$2
    local service_port=$3
    local email=${4:-"admin@example.com"}
    
    echo "=== Enabling SSL for $domain ==="
    
    if get_ssl_certificate "$domain" "$email"; then
        if update_domain_to_https "$domain" "$service_name" "$service_port"; then
            echo "🎉 SSL successfully enabled for $domain"
            return 0
        else
            echo "❌ Failed to update nginx configuration"
            return 1
        fi
    else
        echo "❌ Failed to get SSL certificate"
        return 1
    fi
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    case "$1" in
        "get-cert")
            if [ $# -lt 2 ]; then
                echo "Usage: $0 get-cert <domain> [email]"
                exit 1
            fi
            get_ssl_certificate "$2" "$3"
            ;;
        "enable-ssl")
            if [ $# -lt 4 ]; then
                echo "Usage: $0 enable-ssl <domain> <service_name> <service_port> [email]"
                echo "Example: $0 enable-ssl domain1.example.com service1 8001"
                exit 1
            fi
            enable_ssl_for_domain "$2" "$3" "$4" "$5"
            ;;
        "update-config")
            if [ $# -lt 4 ]; then
                echo "Usage: $0 update-config <domain> <service_name> <service_port> [ssl_enabled]"
                exit 1
            fi
            update_domain_to_https "$2" "$3" "$4"
            ;;
        *)
            echo "Usage: $0 {get-cert|enable-ssl|update-config}"
            echo ""
            echo "Commands:"
            echo "  get-cert <domain> [email]                           - Get SSL certificate only"
            echo "  enable-ssl <domain> <service> <port> [email]        - Get cert and enable HTTPS"
            echo "  update-config <domain> <service> <port> [ssl]       - Update nginx config only"
            exit 1
            ;;
    esac
fi