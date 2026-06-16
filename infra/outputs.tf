
output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.main.id
}

output "internet_gateway_id" {
  description = "The ID of the Internet Gateway"
  value       = aws_internet_gateway.igw.id
}

output "public_subnet_1_id" {
  description = "The ID of Public Subnet 1"
  value       = aws_subnet.public_subnet_1.id
}

output "public_subnet_2_id" {
  description = "The ID of Public Subnet 2"
  value       = aws_subnet.public_subnet_2.id
}

output "alb_security_group_id" {
  description = "Security Group ID of the ALB"
  value       = aws_security_group.alb_sg.id
}

output "ec2_security_group_id" {
  description = "Security Group ID of the EC2 instance"
  value       = aws_security_group.ec2_sg.id
}

output "ec2_instance_id" {
  description = "The EC2 Instance ID"
  value       = aws_instance.web_server.id
}

output "ec2_public_ip" {
  description = "The Public IP Address of the EC2 Instance"
  value       = aws_instance.web_server.public_ip
}

output "final_alb_dns" {
  description = "DNS Name of the Application Load Balancer"
  value       = module.my_custom_alb.alb_dns_name
}

output "final_target_group_arns" {
  description = "Target Group ARNs"
  value       = module.my_custom_alb.target_group_arns
}

