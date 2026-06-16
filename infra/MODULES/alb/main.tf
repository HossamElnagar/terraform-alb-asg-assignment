module "alb_official" {
  source  = "terraform-aws-modules/alb/aws"
  version = "~> 9.0"

  name = var.alb_name

  vpc_id          = var.vpc_id
  subnets         = var.subnets
  security_groups = var.security_groups

  listeners = {
    http = {
      port     = 80
      protocol = "HTTP"

      forward = {
        target_group_key = "web-server-tg"
      }
    }
  }

  target_groups = {
  for key, tg in var.target_groups :
  key => {
    protocol    = tg.protocol
    port        = tg.port
    target_type = "instance"
  create_attachment = false
    health_check = {
      enabled = true
      path    = "/"
      matcher = "200"
    }
  }
}
}
