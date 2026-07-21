locals {
  common_tags = {
    Project     = var.project
    Environment = var.environment
    ManagedBy   = "terraform"
    Owner       = "sujit"
  }
}

resource "aws_lb" "public_alb" {
  name               = "${var.project}-${var.environment}-public-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.public_sg_id]
  subnets            = var.public_subnet_ids
  tags = merge(local.common_tags, {
    Name = "${var.project}-${var.environment}-public-alb"
  })
}

resource "aws_lb_target_group" "app_tg" {
  port        = var.app_port
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "instance"

  health_check {
    enabled             = true
    path                = var.health_check_path
    protocol            = "HTTP"
    port                = "traffic-port"
    healthy_threshold   = 3
    unhealthy_threshold = 3
    timeout             = 5
    interval            = 30
    matcher             = "200"
  }

  tags = merge(local.common_tags, {
    Name = "${var.project}-${var.environment}-app-tg"
  })
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.public_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_tg.arn
  }
}

resource "aws_lb_target_group_attachment" "app_tg_attach" {
  for_each         = var.target_instance_ids
  target_group_arn = aws_lb_target_group.app_tg.arn
  target_id        = each.value
  port             = var.app_port
}
