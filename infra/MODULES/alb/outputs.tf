output "alb_dns_name" {
  value = module.alb_official.dns_name
}

output "target_group_arns" {
  value = {
    for k, v in module.alb_official.target_groups :
    k => v.arn
  }
}