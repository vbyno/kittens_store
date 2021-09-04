# resource "aws_lb" "app_lb" {
#   name               = "${var.name}-lb"
#   internal           = false
#   load_balancer_type = "application"
#   security_groups    = [aws_security_group.lb_sg.id]
#   subnets            = aws_subnet.public.*.id

#   enable_deletion_protection = false

#   # access_logs {
#   #   bucket  = aws_s3_bucket.lb_logs.bucket
#   #   prefix  = "test-lb"
#   #   enabled = true
#   # }

#   tags = {
#     Environment = "production"
#   }
# }

resource "aws_lb_target_group" "app_lb_target_group" {
  name        = "${var.name}-target-group"
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = var.vpc_config.vpc_id
}
