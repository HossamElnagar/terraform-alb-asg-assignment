variable "alb_name" {
  type        = string
  description = "Name of the ALB"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID where ALB will be deployed"
}

variable "subnets" {
  type        = list(string)
  description = "List of public subnet IDs for the ALB"
}

variable "target_groups" {
  type = map(object({
    port        = number
    protocol    = string
    target_id   = string 
  }))
  description = "Map of target groups to create and attach"
}