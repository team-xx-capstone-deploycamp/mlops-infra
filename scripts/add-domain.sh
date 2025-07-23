#!/bin/bash

source scripts/generate-config.sh
source scripts/ssl-manager.sh

add_new_domain() {
    local domain=$1
    local service_name=$2
    local service_port=$3
    local enable_ssl=${4:-"true"}
    local email=${5:-"admin@example.com"}
    
    echo "=== Adding new domain: $domain ==="
    
    # Step 1: Generate HTTP config first
    echo "Step 1: Creating initial HTTP configuration..."
    generate_config "$domain" "$service_name" "$service_port" "false"
    
    # Step 2: Reload nginx to apply HTTP config
    echo "Step 2: Reloading nginx with HTTP configuration..."
    docker compose exec nginx nginx -t && docker compose exec nginx nginx -s reload
    
    if [ $? -ne 0 ]; then
        echo "❌ Failed to reload nginx with HTTP configuration"
        return 1
    fi
    
    echo "✓ Domain $domain is now accessible via HTTP"
    
    # Step 3: Enable SSL if requested
    if [ "$enable_ssl" = "true" ]; then
        echo "Step 3: Enabling SSL..."
        sleep 2  # Give nginx a moment to start serving HTTP
        
        if enable_ssl_for_domain "$domain" "$service_name" "$service_port" "$email"; then
            echo "🎉 Domain $domain successfully added with SSL!"
        else
            echo "⚠️  Domain $domain added with HTTP only (SSL failed)"
        fi
    else
        echo "🎉 Domain $domain successfully added with HTTP only!"
    fi
}

# Validate domain format
validate_domain() {
    local domain=$1
    if ! echo "$domain" | grep -qE '^[a-z0-9]([a-z0-9\-]{0,61}[a-z0-9])?(\.[a-z0-9]([a-z0-9\-]{0,61}[a-z0-9])?)*$'; then
        echo "❌ Invalid domain format: $domain"
        return 1
    fi
    return 0
}

# Main script
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    if [ $# -lt 3 ]; then
        echo "Usage: $0 <domain> <service_name> <service_port> [enable_ssl] [email]"
        echo ""
        echo "Examples:"
        echo "  $0 domain4.example.com service4 8004"
        echo "  $0 domain4.example.com service4 8004 true admin@example.com"
        echo "  $0 domain4.example.com service4 8004 false"
        echo ""
        echo "Parameters:"
        echo "  domain       - Domain name (e.g., domain4.example.com)"
        echo "  service_name - Docker service name (e.g., service4)"
        echo "  service_port - Internal service port (e.g., 8004)"
        echo "  enable_ssl   - Enable SSL (true/false, default: true)"
        echo "  email        - Email for Let's Encrypt (default: admin@example.com)"
        exit 1
    fi
    
    domain=$1
    service_name=$2
    service_port=$3
    enable_ssl=${4:-"true"}
    email=${5:-"admin@example.com"}
    
    # Validate inputs
    if ! validate_domain "$domain"; then
        exit 1
    fi
    
    if ! [[ "$service_port" =~ ^[0-9]+$ ]]; then
        echo "❌ Service port must be a number"
        exit 1
    fi
    
    # Add the domain
    add_new_domain "$domain" "$service_name" "$service_port" "$enable_ssl" "$email"
fi