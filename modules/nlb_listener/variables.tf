variable "lb_arn" {
  type = string
  description = "ARN of the Amazon (Network) LoadBalancer"
}

variable "eks_node_group" {
  type = string
}

variable "vpc_id" {
  type = string
}