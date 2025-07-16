# Azure Infrastructure Configuration
# This file contains Azure-specific resources

# Resource Group
resource "azurerm_resource_group" "main" {
  count = var.cloud_provider == "azure" ? 1 : 0
  
  name     = "${local.name_prefix}-rg"
  location = var.region

  tags = local.tags
}

# Virtual Network
resource "azurerm_virtual_network" "main" {
  count = var.cloud_provider == "azure" ? 1 : 0
  
  name                = "${local.name_prefix}-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.main[0].location
  resource_group_name = azurerm_resource_group.main[0].name

  tags = local.tags
}

# Subnets
resource "azurerm_subnet" "public" {
  count = var.cloud_provider == "azure" ? 1 : 0
  
  name                 = "${local.name_prefix}-public-subnet"
  resource_group_name  = azurerm_resource_group.main[0].name
  virtual_network_name = azurerm_virtual_network.main[0].name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_subnet" "private" {
  count = var.cloud_provider == "azure" ? 1 : 0
  
  name                 = "${local.name_prefix}-private-subnet"
  resource_group_name  = azurerm_resource_group.main[0].name
  virtual_network_name = azurerm_virtual_network.main[0].name
  address_prefixes     = ["10.0.2.0/24"]
}

# Public IP
resource "azurerm_public_ip" "lb" {
  count = var.cloud_provider == "azure" ? 1 : 0
  
  name                = "${local.name_prefix}-lb-pip"
  location            = azurerm_resource_group.main[0].location
  resource_group_name = azurerm_resource_group.main[0].name
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = local.tags
}

# Network Security Groups
resource "azurerm_network_security_group" "public" {
  count = var.cloud_provider == "azure" ? 1 : 0
  
  name                = "${local.name_prefix}-public-nsg"
  location            = azurerm_resource_group.main[0].location
  resource_group_name = azurerm_resource_group.main[0].name

  security_rule {
    name                       = "AllowHTTP"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "AllowHTTPS"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = local.tags
}

resource "azurerm_network_security_group" "private" {
  count = var.cloud_provider == "azure" ? 1 : 0
  
  name                = "${local.name_prefix}-private-nsg"
  location            = azurerm_resource_group.main[0].location
  resource_group_name = azurerm_resource_group.main[0].name

  security_rule {
    name                       = "AllowAppPort"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = tostring(var.app_port)
    source_address_prefix      = "10.0.1.0/24"
    destination_address_prefix = "*"
  }

  tags = local.tags
}

# Subnet NSG Associations
resource "azurerm_subnet_network_security_group_association" "public" {
  count = var.cloud_provider == "azure" ? 1 : 0
  
  subnet_id                 = azurerm_subnet.public[0].id
  network_security_group_id = azurerm_network_security_group.public[0].id
}

resource "azurerm_subnet_network_security_group_association" "private" {
  count = var.cloud_provider == "azure" ? 1 : 0
  
  subnet_id                 = azurerm_subnet.private[0].id
  network_security_group_id = azurerm_network_security_group.private[0].id
}

# Container Registry
resource "azurerm_container_registry" "main" {
  count = var.cloud_provider == "azure" ? 1 : 0
  
  name                = replace("${local.name_prefix}acr", "-", "")
  resource_group_name = azurerm_resource_group.main[0].name
  location            = azurerm_resource_group.main[0].location
  sku                 = "Basic"
  admin_enabled       = true

  tags = local.tags
}

# Container Instances
resource "azurerm_container_group" "app" {
  count = var.cloud_provider == "azure" ? 2 : 0
  
  name                = "${local.name_prefix}-ci-${count.index + 1}"
  location            = azurerm_resource_group.main[0].location
  resource_group_name = azurerm_resource_group.main[0].name
  ip_address_type     = "Private"
  subnet_ids          = [azurerm_subnet.private[0].id]
  os_type             = "Linux"
  restart_policy      = "Always"

  container {
    name   = "${local.name_prefix}-container"
    image  = "${azurerm_container_registry.main[0].login_server}/${local.name_prefix}:latest"
    cpu    = "0.5"
    memory = "1.0"

    ports {
      port     = var.app_port
      protocol = "TCP"
    }

    environment_variables = {
      NODE_ENV = var.environment
      PORT     = tostring(var.app_port)
    }

    volume {
      name       = "logs"
      mount_path = "/app/logs"
      read_only  = false
      share_name = azurerm_storage_share.app[0].name

      storage_account_name = azurerm_storage_account.app[0].name
      storage_account_key  = azurerm_storage_account.app[0].primary_access_key
    }
  }

  tags = local.tags
}

# Load Balancer
resource "azurerm_lb" "main" {
  count = var.cloud_provider == "azure" ? 1 : 0
  
  name                = "${local.name_prefix}-lb"
  location            = azurerm_resource_group.main[0].location
  resource_group_name = azurerm_resource_group.main[0].name
  sku                 = "Standard"

  frontend_ip_configuration {
    name                 = "frontend"
    public_ip_address_id = azurerm_public_ip.lb[0].id
  }

  tags = local.tags
}

# Backend Address Pool
resource "azurerm_lb_backend_address_pool" "app" {
  count = var.cloud_provider == "azure" ? 1 : 0
  
  name            = "${local.name_prefix}-backend-pool"
  loadbalancer_id = azurerm_lb.main[0].id
}

# Health Probe
resource "azurerm_lb_probe" "app" {
  count = var.cloud_provider == "azure" ? 1 : 0
  
  name            = "${local.name_prefix}-health-probe"
  loadbalancer_id = azurerm_lb.main[0].id
  port            = var.app_port
  protocol        = "Http"
  request_path    = "/health"
  interval_in_seconds = 30
  number_of_probes   = 3
}

# Load Balancer Rule
resource "azurerm_lb_rule" "app" {
  count = var.cloud_provider == "azure" ? 1 : 0
  
  name                           = "${local.name_prefix}-lb-rule"
  loadbalancer_id                = azurerm_lb.main[0].id
  frontend_ip_configuration_name = "frontend"
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.app[0].id]
  probe_id                       = azurerm_lb_probe.app[0].id
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = var.app_port
}

# Network Interface Cards for Container Instances
resource "azurerm_network_interface" "app" {
  count = var.cloud_provider == "azure" ? 2 : 0
  
  name                = "${local.name_prefix}-nic-${count.index + 1}"
  location            = azurerm_resource_group.main[0].location
  resource_group_name = azurerm_resource_group.main[0].name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.private[0].id
    private_ip_address_allocation = "Dynamic"
  }

  tags = local.tags
}

# Storage Account for Logs
resource "azurerm_storage_account" "app" {
  count = var.cloud_provider == "azure" ? 1 : 0
  
  name                     = replace("${local.name_prefix}storage", "-", "")
  resource_group_name      = azurerm_resource_group.main[0].name
  location                 = azurerm_resource_group.main[0].location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = local.tags
}

resource "azurerm_storage_share" "app" {
  count = var.cloud_provider == "azure" ? 1 : 0
  
  name                 = "app-logs"
  storage_account_name = azurerm_storage_account.app[0].name
  quota                = 50
}

# Application Insights
resource "azurerm_application_insights" "main" {
  count = var.cloud_provider == "azure" ? 1 : 0
  
  name                = "${local.name_prefix}-appinsights"
  location            = azurerm_resource_group.main[0].location
  resource_group_name = azurerm_resource_group.main[0].name
  application_type    = "web"

  tags = local.tags
}

# Log Analytics Workspace
resource "azurerm_log_analytics_workspace" "main" {
  count = var.cloud_provider == "azure" ? 1 : 0
  
  name                = "${local.name_prefix}-workspace"
  location            = azurerm_resource_group.main[0].location
  resource_group_name = azurerm_resource_group.main[0].name
  sku                 = "PerGB2018"
  retention_in_days   = 30

  tags = local.tags
}

# Outputs
output "azure_load_balancer_ip" {
  description = "Public IP address of the load balancer"
  value       = var.cloud_provider == "azure" ? azurerm_public_ip.lb[0].ip_address : null
}

output "azure_container_registry_url" {
  description = "URL of the Azure Container Registry"
  value       = var.cloud_provider == "azure" ? azurerm_container_registry.main[0].login_server : null
}

output "azure_application_insights_key" {
  description = "Application Insights instrumentation key"
  value       = var.cloud_provider == "azure" ? azurerm_application_insights.main[0].instrumentation_key : null
  sensitive   = true
}