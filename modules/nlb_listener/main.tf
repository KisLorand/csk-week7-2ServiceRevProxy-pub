/* resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.this.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = "arn:aws:iam::187416307283:server-certificate/test_cert_rab3wuqwgja25ct3n4jdj2tzu4"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.front_end.arn
  }

  depends_on = [ 
    aws_lb.this 
  ]
} */

resource "aws_lb_listener" "http" {
  load_balancer_arn = var.lb_arn
  port              = "80"
  protocol          = "TCP"
/*   ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = "arn:aws:iam::187416307283:server-certificate/test_cert_rab3wuqwgja25ct3n4jdj2tzu4" */

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.http_tg.arn
  }

  depends_on = [ 
    aws_lb_target_group.http_tg
  ]
}

resource "aws_lb_target_group" "http_tg" {
  name        = "lori-week7-nlb-tg"
  port        = 80
  protocol    = "TCP"
  target_type = "instance"
  vpc_id      = var.vpc_id

  health_check {
    protocol            = "TCP"
    port                = "traffic-port" # same port as above
    interval            = 10
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }

  /* lifecycle {
    create_before_destroy = true
  } */
}

resource "aws_autoscaling_attachment" "app" {
  autoscaling_group_name = var.eks_node_group // TODO change to asg_name
  lb_target_group_arn    = aws_lb_target_group.http_tg.arn
}


//// -v2
/* 
# Adjust these resource references to match the names in your existing code:
#   aws_vpc.main             -> your VPC
#   aws_lb.nlb               -> your Network Load Balancer
#   aws_eks_cluster.main     -> your EKS cluster
#   aws_eks_node_group.main  -> your node group

variable "nginx_host_port" {
  description = "hostPort the nginx DaemonSet listens on on every node"
  type        = number
  default     = 80
}

# 1. Target group: sends traffic to the nginx pod on each worker node (hostPort)
resource "aws_lb_target_group" "app" {
  name        = "eks-app-tg"
  port        = var.nginx_host_port
  protocol    = "TCP"
  vpc_id      = aws_vpc.main.id
  target_type = "instance"

  health_check {
    protocol            = "TCP"
    port                = "traffic-port" # same port as above
    interval            = 10
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }
}

# 2. Listener: accepts public traffic on port 80 and forwards it to the target group
resource "aws_lb_listener" "app" {
  load_balancer_arn = aws_lb.nlb.arn
  port              = 80
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app.arn
  }
}
 ----- copied until this section
# 3. Register the nodes automatically: attach the node group's Auto Scaling group
#    to the target group. New nodes are added, terminated nodes are removed.
resource "aws_autoscaling_attachment" "app" {
  autoscaling_group_name = aws_eks_node_group.main.resources[0].autoscaling_groups[0].name
  lb_target_group_arn    = aws_lb_target_group.app.arn
}

# 4. Allow traffic to the nginx hostPort on the nodes.
#    Managed node groups use the cluster security group by default.
#    NLBs preserve the client IP, so the nodes see the real client address.
#    If your NLB has its own security group, use referenced_security_group_id
#    (pointing to the NLB's SG) instead of cidr_ipv4.
resource "aws_vpc_security_group_ingress_rule" "nginx_host_port" {
  security_group_id = aws_eks_cluster.main.vpc_config[0].cluster_security_group_id
  description       = "NLB traffic to nginx hostPort"
  ip_protocol       = "tcp"
  from_port         = var.nginx_host_port
  to_port           = var.nginx_host_port
  cidr_ipv4         = "0.0.0.0/0"
  # referenced_security_group_id = aws_security_group.nlb.id
}

# 5. Only if your NLB has a security group attached: allow public inbound on 80
# resource "aws_vpc_security_group_ingress_rule" "nlb_http" {
#   security_group_id = aws_security_group.nlb.id
#   ip_protocol       = "tcp"
#   from_port         = 80
#   to_port           = 80
#   cidr_ipv4         = "0.0.0.0/0"
# }
 */