output "dns_name" {
  value = aws_alb.app_lb.dns_name
}

output "security_groups" {
  value = [aws_security_group.app_lb_sg.id]
  # value = aws_alb.app_lb.security_groups
}
