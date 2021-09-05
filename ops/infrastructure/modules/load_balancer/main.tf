resource "aws_security_group" "app_lb_sg" {
  name_prefix = "${var.name}-lb-sg-"
  description = "Load Balancer security group"
  vpc_id      = var.vpc_config.vpc_id

  ingress {
    description      = "HTTP from outside world"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "${var.name}-lb-sg"
  }
}

resource "aws_alb" "app_lb" {
  name               = "${var.name}-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.app_lb_sg.id]
  subnets            = var.vpc_config.subnet_ids

  enable_deletion_protection = false

  tags = {
    Environment = "production"
  }
}

resource "aws_alb_listener" "app_lb_listener" {
  load_balancer_arn = aws_alb.app_lb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.app_lb_target_group.arn
  }
}

resource "aws_alb_target_group" "app_lb_target_group" {
  name        = "${var.name}-target-group"
  port        = 80
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = var.vpc_config.vpc_id

  health_check {
    enabled = true
    path = "/kittens/info"
    interval = 5
    timeout = 2
  }
}

resource "aws_alb_target_group_attachment" "app_lb_tg_attachment" {
  count = length(var.ec2_instance_ids)
  # for_each = toset(var.ec2_instance_ids)
  # for_each = toset(["i-0b90132300f02be7b", "i-0bad5083269a877ac"])

  target_group_arn = aws_alb_target_group.app_lb_target_group.arn
  target_id        = element(var.ec2_instance_ids, count.index)
  # target_id        = each.key
  port             = 80
}

resource "aws_autoscaling_attachment" "app_autoscaling_attachment" {
  count = length(var.autoscaling_group_ids)

  autoscaling_group_name = element(var.autoscaling_group_ids, count.index)
  alb_target_group_arn   = aws_alb_target_group.app_lb_target_group.arn
}
