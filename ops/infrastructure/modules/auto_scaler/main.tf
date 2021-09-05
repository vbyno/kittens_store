resource "aws_autoscaling_group" "app_autoscaling_group" {
  name = "Application autoscaling group"
  capacity_rebalance  = true
  desired_capacity    = 2
  max_size            = 6
  min_size            = 1
  vpc_zone_identifier = var.vpc_config.subnet_ids
  health_check_grace_period = 120
  health_check_type         = "ELB"

  launch_template {
    id      = var.launch_template_id
    version = "$Latest"
  }
}
