#######################################
# ECR Repository
#######################################

data "aws_ecr_repository" "app_repo" {
  name = var.ecr_repo
}


#######################################
# ECS Cluster
#######################################

resource "aws_ecs_cluster" "app_cluster" {
  name = "${var.project}-cluster"
  tags = local.common_tags
}


#######################################
# IAM Roles for ECS Task Execution
#######################################

resource "aws_iam_role" "ecs_task_execution_role" {
  name = "${var.project}-ecs-exec-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_exec_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}


#######################################
# ALB (Application Load Balancer)
#######################################

resource "aws_lb" "app_alb" {
  name               = "${var.project}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = aws_subnet.public[*].id

  dynamic "access_logs" {
    for_each = var.enable_alb_access_logs ? [1] : []
    content {
      bucket  = var.alb_logs_bucket
      enabled = true
    }
  }

  tags = local.common_tags
}


#######################################
# ALB Target Group
#######################################

resource "aws_lb_target_group" "app_tg" {
  name        = "${var.project}-tg"
  port        = 8080
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = aws_vpc.main.id

  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
    matcher             = "200-499"
  }

  tags = local.common_tags
}


#######################################
# ALB Listeners
#######################################

# HTTP 
resource "aws_lb_listener" "http_listener" {
  load_balancer_arn = aws_lb.app_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_tg.arn
  }
}


# HTTPS listener
resource "aws_lb_listener" "https" {
  count             = var.acm_cert_arn != "" ? 1 : 0
  load_balancer_arn = aws_lb.app_alb.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = var.acm_cert_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_tg.arn
  }
}


#######################################
# ECS Task Definition
#######################################

resource "aws_ecs_task_definition" "app_task" {
  family                   = "${var.project}-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([
    {
      name      = "banking-app"
      image     = "${data.aws_ecr_repository.app_repo.repository_url}:${var.image_tag}"
      essential = true
      portMappings = [
        {
          containerPort = 8080
          hostPort      = 8080
        }
      ]
      environment = [
        { name = "DB_HOST", value = aws_db_instance.postgres.address },
        { name = "DB_USER", value = var.db_username },
        { name = "DB_PASS", value = var.db_password },
        { name = "DB_NAME", value = "bankdb" }
      ]
    }
  ])

  tags = local.common_tags
}



#######################################
# ECS Service
#######################################

resource "aws_ecs_service" "app_service" {
  name            = "${var.project}-service"
  cluster         = aws_ecs_cluster.app_cluster.id
  task_definition = aws_ecs_task_definition.app_task.arn
  desired_count   = var.desired_count
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = aws_subnet.private[*].id
    security_groups = [aws_security_group.ecs_sg.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.app_tg.arn
    container_name   = "banking-app"
    container_port   = 8080
  }

  depends_on = [
  aws_lb_listener.http_listener,
  aws_lb_target_group.app_tg
]



  tags = local.common_tags
}
