locals {
  sorted_subnet_ids = zipmap(
    tolist(range(var.instances_number)),
    [for i in range(var.instances_number): element(sort(var.vpc_config.subnet_ids), i)]
  )
}
resource "aws_instance" "dogs_server" {
  for_each = local.sorted_subnet_ids
  subnet_id = each.value

  launch_template {
    id      = var.launch_template_id
    version = "$Latest"
  }

  lifecycle {
    ignore_changes = [tags]
  }
}
