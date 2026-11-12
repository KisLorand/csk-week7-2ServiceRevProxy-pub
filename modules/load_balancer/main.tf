resource "aws_lb" "this" {
  name               = "${var.project_name}-network-lb"
  internal           = false
  load_balancer_type = "network"
  security_groups    = [module.security_group.sg_id]
  subnets            = var.subnet_ids

  enable_deletion_protection = false  // true

  tags = {
    Name = "${var.project_name}-network-lb"
  }

  depends_on = [ 
    module.security_group 
  ]
}

// load_balancer sg??
module "security_group" {
  source = "../security_group"

  project_name = var.project_name
  name = "${var.project_name}-network-lb-sg"
  description = "Allow HTTP(80) inbound traffic and all outbound traffic for the load balancer"
  vpc_id = var.vpc_id
  ingress_rules = [
    {
      name        = "lori-week7-task-LB-ALLOW-HTTP"
      description = "Allow HTTP"
      from_port   = 80
      to_port     = 80
      ip_protocol = "tcp"
      cidr_block  = "0.0.0.0/0"
    }, {
      name        = "lori-week7-task-LB-ALLOW-HTTPS"
      description = "Allow HTTPS"
      from_port   = 443
      to_port     = 443
      ip_protocol = "tcp"
      cidr_block  = "0.0.0.0/0"
    }, {
      name        = "lori-week7-task-LB-ALLOW-8080"
      description = "Allow HTTP"
      from_port   = 8080
      to_port     = 8080
      ip_protocol = "tcp"
      cidr_block  = "0.0.0.0/0"
    }
  ]
  egress_rules = [
    {
      name        = "lori-week7-task-LB-ALLOW-ALL-OUT"
      description = "Allow all outbound traffic"
      from_port   = 0
      to_port     = 0
      ip_protocol = "-1"
      cidr_block  = "0.0.0.0/0"
    }
  ]
}