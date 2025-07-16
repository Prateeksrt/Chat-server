# DigitalOcean Infrastructure Configuration
# This file contains DigitalOcean-specific resources

# Project
resource "digitalocean_project" "main" {
  count = var.cloud_provider == "digitalocean" ? 1 : 0
  
  name        = "${local.name_prefix}-project"
  description = "Terraform managed project for ${var.project_name}"
  environment = var.environment
  is_default  = false

  resources = [
    digitalocean_app.app[0].urn
  ]
}

# Container Registry
resource "digitalocean_container_registry" "main" {
  count = var.cloud_provider == "digitalocean" ? 1 : 0
  
  name                   = "${local.name_prefix}-registry"
  subscription_tier_slug = "basic"
  region                 = var.region
}

# App Platform Application
resource "digitalocean_app" "app" {
  count = var.cloud_provider == "digitalocean" ? 1 : 0
  
  spec {
    name   = "${local.name_prefix}-app"
    region = var.region

    # Container service
    service {
      name               = "${local.name_prefix}-service"
      instance_count     = var.environment == "prod" ? 2 : 1
      instance_size_slug = var.environment == "prod" ? "basic-xxs" : "basic-xs"

      # Container configuration
      container {
        registry_type = "DOCR"
        registry      = digitalocean_container_registry.main[0].name
        image         = "${digitalocean_container_registry.main[0].name}/${local.name_prefix}:latest"
        port          = var.app_port

        # Environment variables
        env {
          key   = "NODE_ENV"
          value = var.environment
        }

        env {
          key   = "PORT"
          value = tostring(var.app_port)
        }

        # Health check
        health_check {
          http_path = "/health"
          initial_delay_seconds = 30
          period_seconds        = 30
          timeout_seconds       = 5
          success_threshold     = 1
          failure_threshold     = 3
        }
      }

      # HTTP routes
      http_port = var.app_port

      # Auto-scaling
      autoscaling {
        min_instance_count = var.environment == "prod" ? 2 : 1
        max_instance_count = var.environment == "prod" ? 10 : 3
        metrics {
          type = "CPU_UTILIZATION"
          value = 70
        }
      }
    }

    # Ingress configuration
    ingress {
      rule {
        component {
          name = "${local.name_prefix}-service"
          port = var.app_port
        }
      }
    }
  }
}

# Database (optional - for future use)
resource "digitalocean_database_cluster" "main" {
  count = var.cloud_provider == "digitalocean" && var.environment == "prod" ? 1 : 0
  
  name       = "${local.name_prefix}-db"
  engine     = "pg"
  version    = "15"
  size       = "db-s-1vcpu-1gb"
  region     = var.region
  node_count = 1

  maintenance_window {
    day  = "sunday"
    hour = "02:00:00"
  }
}

# Load Balancer (if needed for custom domain)
resource "digitalocean_loadbalancer" "main" {
  count = var.cloud_provider == "digitalocean" && var.environment == "prod" ? 1 : 0
  
  name   = "${local.name_prefix}-lb"
  region = var.region

  forwarding_rule {
    entry_port     = 80
    entry_protocol = "http"

    target_port     = var.app_port
    target_protocol = "http"
  }

  healthcheck {
    port     = var.app_port
    protocol = "http"
    path     = "/health"
  }

  droplet_tag = "web"
}

# Firewall
resource "digitalocean_firewall" "main" {
  count = var.cloud_provider == "digitalocean" ? 1 : 0
  
  name = "${local.name_prefix}-firewall"

  # Allow HTTP
  inbound_rule {
    protocol         = "tcp"
    port_range       = "80"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  # Allow HTTPS
  inbound_rule {
    protocol         = "tcp"
    port_range       = "443"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  # Allow application port
  inbound_rule {
    protocol         = "tcp"
    port_range       = tostring(var.app_port)
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  # Allow all outbound traffic
  outbound_rule {
    protocol              = "tcp"
    port_range            = "1-65535"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol              = "udp"
    port_range            = "1-65535"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol              = "icmp"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }
}

# Spaces (object storage for logs)
resource "digitalocean_spaces_bucket" "logs" {
  count = var.cloud_provider == "digitalocean" ? 1 : 0
  
  name   = "${local.name_prefix}-logs"
  region = var.region

  lifecycle_rule {
    enabled = true

    expiration {
      days = 30
    }
  }
}

# Monitoring and Alerting
resource "digitalocean_monitoring_alert" "cpu" {
  count = var.cloud_provider == "digitalocean" ? 1 : 0
  
  name = "${local.name_prefix}-cpu-alert"
  type = "v1/insights/droplet/cpu"

  compare = "GreaterThan"
  value   = 80
  window  = "5m"

  enabled = true
}

resource "digitalocean_monitoring_alert" "memory" {
  count = var.cloud_provider == "digitalocean" ? 1 : 0
  
  name = "${local.name_prefix}-memory-alert"
  type = "v1/insights/droplet/memory_utilization_percent"

  compare = "GreaterThan"
  value   = 80
  window  = "5m"

  enabled = true
}

# Domain and DNS (optional)
resource "digitalocean_domain" "main" {
  count = var.cloud_provider == "digitalocean" && var.environment == "prod" ? 1 : 0
  
  name = var.domain_name
}

resource "digitalocean_record" "app" {
  count = var.cloud_provider == "digitalocean" && var.environment == "prod" ? 1 : 0
  
  domain = digitalocean_domain.main[0].name
  type   = "CNAME"
  name   = "@"
  value  = "${digitalocean_app.app[0].live_url}."
  ttl    = 300
}

# Variables for DigitalOcean
variable "domain_name" {
  description = "Domain name for the application (optional, for production)"
  type        = string
  default     = ""
}

# Outputs
output "digitalocean_app_url" {
  description = "DigitalOcean App Platform URL"
  value       = var.cloud_provider == "digitalocean" ? digitalocean_app.app[0].live_url : null
}

output "digitalocean_container_registry_url" {
  description = "DigitalOcean Container Registry URL"
  value       = var.cloud_provider == "digitalocean" ? digitalocean_container_registry.main[0].server_url : null
}

output "digitalocean_project_id" {
  description = "DigitalOcean Project ID"
  value       = var.cloud_provider == "digitalocean" ? digitalocean_project.main[0].id : null
}

output "digitalocean_spaces_bucket" {
  description = "DigitalOcean Spaces bucket for logs"
  value       = var.cloud_provider == "digitalocean" ? digitalocean_spaces_bucket.logs[0].name : null
}