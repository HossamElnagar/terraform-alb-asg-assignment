variable "alb_name" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "subnets" {
  type = list(string)
}

variable "target_groups" {
  type = map(object({
    port     = number
    protocol = string
  }))
}

variable "security_groups" {
  type = list(string)
}