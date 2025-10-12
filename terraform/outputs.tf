output "alb_dns_name" {
  value = aws_lb.app_alb.dns_name
}

output "db_endpoint" {
  value = aws_db_instance.postgres.endpoint
}
