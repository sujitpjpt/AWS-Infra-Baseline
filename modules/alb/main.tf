locals {
  common_tags = {
    Project     = var.project
    Environment = var.environment
    ManagedBy   = "terraform"
    Owner       = "sujit"
  }
}

# Internet-facing ALB living in the public subnets — the only path from the internet into the app tier.
resource "aws_lb" "public_alb" {
  name               = "${var.project}-${var.environment}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.public_sg_id]
  subnets            = var.public_subnet_ids
  tags = merge(local.common_tags, {
    Name = "${var.project}-${var.environment}-alb"
  })
}

# target_type "instance" (not "ip" or "lambda") since targets are the EC2 smoke-test instances themselves.
resource "aws_lb_target_group" "app_tg" {
  name        = "${var.project}-${var.environment}-app-tg"
  port        = var.app_port
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "instance"

  # Marks a target unhealthy/healthy only after 3 consecutive checks — avoids flapping targets in/out on a single blip.
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

# HTTP only for this smoke-test setup — no ACM cert/HTTPS listener yet.
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.public_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_tg.arn
  }
}

# for_each over a map (not count over a list) so target instance IDs stay stably keyed even if the EC2 module's map changes.
resource "aws_lb_target_group_attachment" "app_tg_attach" {
  for_each         = var.target_instance_ids
  target_group_arn = aws_lb_target_group.app_tg.arn
  target_id        = each.value
  port             = var.app_port
}
