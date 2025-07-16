# Google Cloud Platform Infrastructure Configuration
# This file contains GCP-specific resources

# Project
resource "google_project" "main" {
  count = var.cloud_provider == "gcp" ? 1 : 0
  
  name            = var.project_name
  project_id      = replace("${local.name_prefix}-project", "-", "")
  billing_account = var.billing_account
  org_id          = var.org_id

  labels = local.tags
}

# Enable required APIs
resource "google_project_service" "required_apis" {
  count = var.cloud_provider == "gcp" ? 6 : 0
  
  project = google_project.main[0].project_id
  service = [
    "compute.googleapis.com",
    "run.googleapis.com",
    "containerregistry.googleapis.com",
    "cloudbuild.googleapis.com",
    "logging.googleapis.com",
    "monitoring.googleapis.com"
  ][count.index]

  disable_dependent_services = true
  disable_on_destroy         = false
}

# VPC Network
resource "google_compute_network" "main" {
  count = var.cloud_provider == "gcp" ? 1 : 0
  
  name                    = "${local.name_prefix}-vpc"
  auto_create_subnetworks = false
  project                 = google_project.main[0].project_id

  depends_on = [google_project_service.required_apis]
}

# Subnets
resource "google_compute_subnetwork" "public" {
  count = var.cloud_provider == "gcp" ? 1 : 0
  
  name          = "${local.name_prefix}-public-subnet"
  ip_cidr_range = "10.0.1.0/24"
  region        = var.region
  network       = google_compute_network.main[0].id
  project       = google_project.main[0].project_id

  log_config {
    aggregation_interval = "INTERVAL_5_SEC"
    flow_sampling       = 0.5
    metadata            = "INCLUDE_ALL_METADATA"
  }
}

resource "google_compute_subnetwork" "private" {
  count = var.cloud_provider == "gcp" ? 1 : 0
  
  name          = "${local.name_prefix}-private-subnet"
  ip_cidr_range = "10.0.2.0/24"
  region        = var.region
  network       = google_compute_network.main[0].id
  project       = google_project.main[0].project_id

  private_ip_google_access = true

  log_config {
    aggregation_interval = "INTERVAL_5_SEC"
    flow_sampling       = 0.5
    metadata            = "INCLUDE_ALL_METADATA"
  }
}

# Cloud Router
resource "google_compute_router" "main" {
  count = var.cloud_provider == "gcp" ? 1 : 0
  
  name    = "${local.name_prefix}-router"
  region  = var.region
  network = google_compute_network.main[0].id
  project = google_project.main[0].project_id
}

# Cloud NAT
resource "google_compute_router_nat" "main" {
  count = var.cloud_provider == "gcp" ? 1 : 0
  
  name                               = "${local.name_prefix}-nat"
  router                            = google_compute_router.main[0].name
  region                            = var.region
  project                           = google_project.main[0].project_id
  nat_ip_allocate_option            = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}

# Firewall Rules
resource "google_compute_firewall" "allow_http" {
  count = var.cloud_provider == "gcp" ? 1 : 0
  
  name    = "${local.name_prefix}-allow-http"
  network = google_compute_network.main[0].name
  project = google_project.main[0].project_id

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["http-server"]
}

resource "google_compute_firewall" "allow_https" {
  count = var.cloud_provider == "gcp" ? 1 : 0
  
  name    = "${local.name_prefix}-allow-https"
  network = google_compute_network.main[0].name
  project = google_project.main[0].project_id

  allow {
    protocol = "tcp"
    ports    = ["443"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["https-server"]
}

# Container Registry
resource "google_container_registry" "main" {
  count = var.cloud_provider == "gcp" ? 1 : 0
  
  project = google_project.main[0].project_id

  depends_on = [google_project_service.required_apis]
}

# Cloud Run Service
resource "google_cloud_run_service" "app" {
  count = var.cloud_provider == "gcp" ? 1 : 0
  
  name     = "${local.name_prefix}-service"
  location = var.region
  project  = google_project.main[0].project_id

  template {
    spec {
      containers {
        image = "gcr.io/${google_project.main[0].project_id}/${local.name_prefix}:latest"
        
        ports {
          container_port = var.app_port
        }

        env {
          name  = "NODE_ENV"
          value = var.environment
        }

        env {
          name  = "PORT"
          value = tostring(var.app_port)
        }

        resources {
          limits = {
            cpu    = "1000m"
            memory = "512Mi"
          }
        }
      }

      container_concurrency = 80
      timeout_seconds       = 300
    }

    metadata {
      annotations = {
        "autoscaling.knative.dev/minScale" = "1"
        "autoscaling.knative.dev/maxScale" = "10"
      }
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }

  depends_on = [google_project_service.required_apis]
}

# Cloud Run Service IAM
resource "google_cloud_run_service_iam_member" "public" {
  count = var.cloud_provider == "gcp" ? 1 : 0
  
  location = google_cloud_run_service.app[0].location
  project  = google_cloud_run_service.app[0].project
  service  = google_cloud_run_service.app[0].name
  role     = "roles/run.invoker"
  member   = "allUsers"
}

# Load Balancer
resource "google_compute_global_forwarding_rule" "main" {
  count = var.cloud_provider == "gcp" ? 1 : 0
  
  name       = "${local.name_prefix}-forwarding-rule"
  target     = google_compute_target_http_proxy.main[0].id
  port_range = "80"
  project    = google_project.main[0].project_id
}

resource "google_compute_target_http_proxy" "main" {
  count = var.cloud_provider == "gcp" ? 1 : 0
  
  name    = "${local.name_prefix}-http-proxy"
  url_map = google_compute_url_map.main[0].id
  project = google_project.main[0].project_id
}

resource "google_compute_url_map" "main" {
  count = var.cloud_provider == "gcp" ? 1 : 0
  
  name            = "${local.name_prefix}-url-map"
  default_service = google_compute_backend_service.app[0].id
  project         = google_project.main[0].project_id
}

resource "google_compute_backend_service" "app" {
  count = var.cloud_provider == "gcp" ? 1 : 0
  
  name        = "${local.name_prefix}-backend"
  protocol    = "HTTP"
  port_name   = "http"
  timeout_sec = 30
  project     = google_project.main[0].project_id

  backend {
    group = google_compute_network_endpoint_group.app[0].id
  }

  health_checks = [google_compute_health_check.app[0].id]
}

resource "google_compute_network_endpoint_group" "app" {
  count = var.cloud_provider == "gcp" ? 1 : 0
  
  name                  = "${local.name_prefix}-neg"
  network               = google_compute_network.main[0].id
  subnetwork           = google_compute_subnetwork.public[0].id
  default_port         = var.app_port
  zone                 = "${var.region}-a"
  network_endpoint_type = "SERVERLESS"
  cloud_run {
    service = google_cloud_run_service.app[0].name
  }
  project = google_project.main[0].project_id
}

resource "google_compute_health_check" "app" {
  count = var.cloud_provider == "gcp" ? 1 : 0
  
  name    = "${local.name_prefix}-health-check"
  project = google_project.main[0].project_id

  http_health_check {
    port         = var.app_port
    request_path = "/health"
  }

  check_interval_sec = 30
  timeout_sec        = 5
  healthy_threshold  = 2
  unhealthy_threshold = 3
}

# Logging
resource "google_logging_project_sink" "app" {
  count = var.cloud_provider == "gcp" ? 1 : 0
  
  name        = "${local.name_prefix}-logs"
  destination = "storage.googleapis.com/${google_storage_bucket.logs[0].name}"
  project     = google_project.main[0].project_id

  log_filter = "resource.type=\"cloud_run_revision\" AND resource.labels.service_name=\"${google_cloud_run_service.app[0].name}\""
}

resource "google_storage_bucket" "logs" {
  count = var.cloud_provider == "gcp" ? 1 : 0
  
  name          = "${local.name_prefix}-logs-${random_id.bucket_suffix[0].hex}"
  location      = var.region
  project       = google_project.main[0].project_id
  force_destroy = true

  lifecycle_rule {
    condition {
      age = 30
    }
    action {
      type = "Delete"
    }
  }
}

resource "random_id" "bucket_suffix" {
  count = var.cloud_provider == "gcp" ? 1 : 0
  
  byte_length = 4
}

# Monitoring
resource "google_monitoring_alert_policy" "app" {
  count = var.cloud_provider == "gcp" ? 1 : 0
  
  display_name = "${local.name_prefix}-alert-policy"
  project      = google_project.main[0].project_id

  conditions {
    display_name = "High error rate"

    condition_threshold {
      filter     = "resource.type=\"cloud_run_revision\" AND resource.labels.service_name=\"${google_cloud_run_service.app[0].name}\""
      duration   = "300s"
      comparison = "COMPARISON_GREATER_THAN"
      threshold_value = 0.05

      aggregations {
        alignment_period   = "300s"
        per_series_aligner = "ALIGN_RATE"
      }
    }
  }

  notification_channels = [google_monitoring_notification_channel.email[0].name]
}

resource "google_monitoring_notification_channel" "email" {
  count = var.cloud_provider == "gcp" ? 1 : 0
  
  display_name = "${local.name_prefix}-email-notifications"
  type         = "email"
  project      = google_project.main[0].project_id

  labels = {
    email_address = var.alert_email
  }
}

# Variables for GCP
variable "billing_account" {
  description = "GCP billing account ID"
  type        = string
  default     = ""
}

variable "org_id" {
  description = "GCP organization ID"
  type        = string
  default     = ""
}

variable "alert_email" {
  description = "Email address for monitoring alerts"
  type        = string
  default     = ""
}

# Outputs
output "gcp_project_id" {
  description = "GCP project ID"
  value       = var.cloud_provider == "gcp" ? google_project.main[0].project_id : null
}

output "gcp_cloud_run_url" {
  description = "Cloud Run service URL"
  value       = var.cloud_provider == "gcp" ? google_cloud_run_service.app[0].status[0].url : null
}

output "gcp_container_registry_url" {
  description = "Container Registry URL"
  value       = var.cloud_provider == "gcp" ? google_container_registry.main[0].id : null
}