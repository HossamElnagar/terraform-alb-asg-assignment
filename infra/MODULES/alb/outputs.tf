# 1. مخرج الـ DNS الخاص بالـ Load Balancer
output "alb_dns_name" {
  description = "The DNS name of the load balancer"
  # نقرأ من الموديول الداخلي المسمى alb_official
  value       = module.alb_official.dns_name 
}

# 2. مخرج الـ ARNs الخاص بالـ Target Groups
output "target_group_arns" {
  description = "ARNs of the created target groups"
  # في الإصدارات الحديثة نقوم بجلب الـ ARNs من الـ map الخاص بالـ target_groups
  value       = { for k, v in module.alb_official.target_groups : k => v.arn }
}