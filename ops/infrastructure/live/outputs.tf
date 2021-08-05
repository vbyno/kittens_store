output "vpc_id" {
  value = data.terraform_remote_state.vpc.outputs.vpc_id
}
