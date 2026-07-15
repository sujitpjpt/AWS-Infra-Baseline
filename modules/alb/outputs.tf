output "alb_arn" {
  description = "ARN of the public ALB"
  value       = aws_lb.public_alb.arn
}

output "alb_dns_name" {
  description = "DNS name of the public ALB, used to reach the app tier"
  value       = aws_lb.public_alb.dns_name
}

output "alb_zone_id" {
  description = "Route53 hosted zone ID of the ALB, needed for an alias record"
  value       = aws_lb.public_alb.zone_id
}

output "target_group_arn" {
  description = "ARN of the app-tier target group"
  value       = aws_lb_target_group.app_tg.arn
}

output "listener_arn" {
  description = "ARN of the HTTP listener"
  value       = aws_lb_listener.http.arn
}
