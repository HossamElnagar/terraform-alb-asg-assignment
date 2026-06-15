module "alb_official" {
  source  = "terraform-aws-modules/alb/aws"
  version = "~> 9.0"

  name    = var.alb_name
  vpc_id  = var.vpc_id
  subnets = var.subnets


  security_group_ingress_rules = {
    all_http = {
      from_port   = 80
      to_port     = 80
      ip_protocol = "tcp"
      cidr_ipv4   = "0.0.0.0/0"
    }
  }
  security_group_egress_rules = {
    all = {
      ip_protocol = "-1"
      cidr_ipv4   = "0.0.0.0/0"
    }
  }

  listeners = {
    ex-http = {
      port     = 80
      protocol = "HTTP"
      forward = {
        target_group_key = keys(var.target_groups)[0]
      }
    }
  }

  
  target_groups = {
    for key, tg in var.target_groups : key => {
      name_prefix      = "alb-"
      protocol         = tg.protocol
      port             = tg.port
      target_type      = "instance"
      target_id        = tg.target_id
    }
  }
}