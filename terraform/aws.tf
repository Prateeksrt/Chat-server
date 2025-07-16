# AWS Infrastructure Configuration
# This file contains AWS-specific resources

# VPC and Networking
resource "aws_vpc" "main" {
  count = var.cloud_provider == "aws" ? 1 : 0
  
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(local.tags, {
    Name = "${local.name_prefix}-vpc"
  })
}

resource "aws_subnet" "public" {
  count = var.cloud_provider == "aws" ? 2 : 0
  
  vpc_id            = aws_vpc.main[0].id
  cidr_block        = "10.0.${count.index + 1}.0/24"
  availability_zone = data.aws_availability_zones.available[count.index].names[0]

  map_public_ip_on_launch = true

  tags = merge(local.tags, {
    Name = "${local.name_prefix}-public-subnet-${count.index + 1}"
  })
}

resource "aws_subnet" "private" {
  count = var.cloud_provider == "aws" ? 2 : 0
  
  vpc_id            = aws_vpc.main[0].id
  cidr_block        = "10.0.${count.index + 10}.0/24"
  availability_zone = data.aws_availability_zones.available[count.index].names[0]

  tags = merge(local.tags, {
    Name = "${local.name_prefix}-private-subnet-${count.index + 1}"
  })
}

resource "aws_internet_gateway" "main" {
  count = var.cloud_provider == "aws" ? 1 : 0
  
  vpc_id = aws_vpc.main[0].id

  tags = merge(local.tags, {
    Name = "${local.name_prefix}-igw"
  })
}

resource "aws_nat_gateway" "main" {
  count = var.cloud_provider == "aws" ? 1 : 0
  
  allocation_id = aws_eip.nat[0].id
  subnet_id     = aws_subnet.public[0].id

  tags = merge(local.tags, {
    Name = "${local.name_prefix}-nat"
  })

  depends_on = [aws_internet_gateway.main]
}

resource "aws_eip" "nat" {
  count = var.cloud_provider == "aws" ? 1 : 0
  
  domain = "vpc"

  tags = merge(local.tags, {
    Name = "${local.name_prefix}-nat-eip"
  })
}

# Route Tables
resource "aws_route_table" "public" {
  count = var.cloud_provider == "aws" ? 1 : 0
  
  vpc_id = aws_vpc.main[0].id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main[0].id
  }

  tags = merge(local.tags, {
    Name = "${local.name_prefix}-public-rt"
  })
}

resource "aws_route_table" "private" {
  count = var.cloud_provider == "aws" ? 1 : 0
  
  vpc_id = aws_vpc.main[0].id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main[0].id
  }

  tags = merge(local.tags, {
    Name = "${local.name_prefix}-private-rt"
  })
}

resource "aws_route_table_association" "public" {
  count = var.cloud_provider == "aws" ? 2 : 0
  
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public[0].id
}

resource "aws_route_table_association" "private" {
  count = var.cloud_provider == "aws" ? 2 : 0
  
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[0].id
}

# Security Groups
resource "aws_security_group" "alb" {
  count = var.cloud_provider == "aws" ? 1 : 0
  
  name_prefix = "${local.name_prefix}-alb-"
  vpc_id      = aws_vpc.main[0].id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.tags, {
    Name = "${local.name_prefix}-alb-sg"
  })
}

resource "aws_security_group" "ecs" {
  count = var.cloud_provider == "aws" ? 1 : 0
  
  name_prefix = "${local.name_prefix}-ecs-"
  vpc_id      = aws_vpc.main[0].id

  ingress {
    from_port       = var.app_port
    to_port         = var.app_port
    protocol        = "tcp"
    security_groups = [aws_security_group.alb[0].id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.tags, {
    Name = "${local.name_prefix}-ecs-sg"
  })
}

# ECS Cluster
resource "aws_ecs_cluster" "main" {
  count = var.cloud_provider == "aws" ? 1 : 0
  
  name = "${local.name_prefix}-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = local.tags
}

# ECS Task Definition
resource "aws_ecs_task_definition" "app" {
  count = var.cloud_provider == "aws" ? 1 : 0
  
  family                   = "${local.name_prefix}-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 256
  memory                   = 512
  execution_role_arn       = aws_iam_role.ecs_execution_role[0].arn
  task_role_arn            = aws_iam_role.ecs_task_role[0].arn

  container_definitions = jsonencode([
    {
      name  = "${local.name_prefix}-container"
      image = "${aws_ecr_repository.app[0].repository_url}:latest"
      
      portMappings = [
        {
          containerPort = var.app_port
          protocol      = "tcp"
        }
      ]

      environment = [
        {
          name  = "NODE_ENV"
          value = var.environment
        },
        {
          name  = "PORT"
          value = tostring(var.app_port)
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.app[0].name
          awslogs-region        = var.region
          awslogs-stream-prefix = "ecs"
        }
      }

      healthCheck = {
        command     = ["CMD-SHELL", "node dist/health.js || exit 1"]
        interval    = 30
        timeout     = 5
        retries     = 3
        startPeriod = 60
      }
    }
  ])

  tags = local.tags
}

# ECS Service
resource "aws_ecs_service" "app" {
  count = var.cloud_provider == "aws" ? 1 : 0
  
  name            = "${local.name_prefix}-service"
  cluster         = aws_ecs_cluster.main[0].id
  task_definition = aws_ecs_task_definition.app[0].arn
  desired_count   = 2
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = aws_subnet.private[*].id
    security_groups  = [aws_security_group.ecs[0].id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.app[0].arn
    container_name   = "${local.name_prefix}-container"
    container_port   = var.app_port
  }

  depends_on = [aws_lb_listener.app]

  tags = local.tags
}

# Application Load Balancer
resource "aws_lb" "main" {
  count = var.cloud_provider == "aws" ? 1 : 0
  
  name               = "${local.name_prefix}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb[0].id]
  subnets            = aws_subnet.public[*].id

  enable_deletion_protection = var.environment == "prod"

  tags = local.tags
}

resource "aws_lb_target_group" "app" {
  count = var.cloud_provider == "aws" ? 1 : 0
  
  name        = "${local.name_prefix}-tg"
  port        = var.app_port
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main[0].id
  target_type = "ip"

  health_check {
    enabled             = true
    healthy_threshold   = 2
    interval            = 30
    matcher             = "200"
    path                = "/health"
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = 5
    unhealthy_threshold = 2
  }

  tags = local.tags
}

resource "aws_lb_listener" "app" {
  count = var.cloud_provider == "aws" ? 1 : 0
  
  load_balancer_arn = aws_lb.main[0].arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app[0].arn
  }
}

# ECR Repository
resource "aws_ecr_repository" "app" {
  count = var.cloud_provider == "aws" ? 1 : 0
  
  name                 = "${local.name_prefix}-repo"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = local.tags
}

# CloudWatch Log Group
resource "aws_cloudwatch_log_group" "app" {
  count = var.cloud_provider == "aws" ? 1 : 0
  
  name              = "/ecs/${local.name_prefix}"
  retention_in_days = 7

  tags = local.tags
}

# IAM Roles
resource "aws_iam_role" "ecs_execution_role" {
  count = var.cloud_provider == "aws" ? 1 : 0
  
  name = "${local.name_prefix}-ecs-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })

  tags = local.tags
}

resource "aws_iam_role_policy_attachment" "ecs_execution_role_policy" {
  count = var.cloud_provider == "aws" ? 1 : 0
  
  role       = aws_iam_role.ecs_execution_role[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role" "ecs_task_role" {
  count = var.cloud_provider == "aws" ? 1 : 0
  
  name = "${local.name_prefix}-ecs-task-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })

  tags = local.tags
}

# Data sources
data "aws_availability_zones" "available" {
  count = var.cloud_provider == "aws" ? 1 : 0
  
  state = "available"
}

# Outputs
output "aws_load_balancer_dns" {
  description = "DNS name of the load balancer"
  value       = var.cloud_provider == "aws" ? aws_lb.main[0].dns_name : null
}

output "aws_ecr_repository_url" {
  description = "URL of the ECR repository"
  value       = var.cloud_provider == "aws" ? aws_ecr_repository.app[0].repository_url : null
}