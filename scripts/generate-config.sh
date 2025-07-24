#!/bin/bash

generate_config() {
    local domain=$1
    local service_name=$2
    local service_port=$3
    local ssl_enabled=${4:-false}
    
    local config_file="nginx/conf.d/${domain}.conf"
    
    echo "Generating config for $domain..."
    
    if [ "$ssl_enabled" = "true" ]; then
        # Use HTTPS template
        if [ "$service_name" = 'minio' && "$service_port" = '9001' ]; then
            template_file="nginx/templates/https.console-minio.template"
        else
            template_file="nginx/templates/https.template"
        fi
        echo "Using HTTPS template"
    else
        if [ "$service_name" = 'minio' && "$service_port" = '9001' ]; then
            template_file="nginx/templates/http.console-minio.template"
        else
            template_file="nginx/templates/http.template"
        fi
        echo "Using HTTP template"
    fi
    
    # Replace placeholders in template
    sed -e "s/{{DOMAIN}}/$domain/g" \
        -e "s/{{SERVICE_NAME}}/$service_name/g" \
        -e "s/{{SERVICE_PORT}}/$service_port/g" \
        "$template_file" > "$config_file"
    
    echo "✓ Config generated: $config_file"
}

# Check if function is called directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    if [ $# -lt 3 ]; then
        echo "Usage: $0 <domain> <service_name> <service_port> [ssl_enabled]"
        echo "Example: $0 domain1.example.com service1 8001"
        echo "Example: $0 domain1.example.com service1 8001 true"
        exit 1
    fi
    
    generate_config "$@"
fi