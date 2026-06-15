output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.main.id
}


output "internet_gateway_id" {
  description = "The ID of the Internet Gateway"
  value       = aws_internet_gateway.igw.id
}

output "ec2_public_ip" {
  description = "The Public IP address of the EC2 instance"
  value       = aws_instance.web_server.public_ip
}

output "final_alb_dns" {
  description = "The final DNS of Application Load Balancer"
  value       = module.my_custom_alb.alb_dns_name
}

output "final_target_group_arns" {
  description = "The ARNs of Target Groups from our custom module"
  value       = module.my_custom_alb.target_group_arns
}
# تعديل المخرج القديم ليقرأ من الشبكة الأولى
output "public_subnet_1_id" {
  description = "The ID of the Public Subnet 1"
  value       = aws_subnet.public_subnet_1.id
}

# إضافة مخرج للشبكة الثانية (اختياري لو أحببتِ)
output "public_subnet_2_id" {
  description = "The ID of the Public Subnet 2"
  value       = aws_subnet.public_subnet_2.id
}