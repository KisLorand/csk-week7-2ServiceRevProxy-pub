variable "project_name" {
  description = "The name of the project, that will be present in all of the created resources"
  type = string
}

variable "security_group_ids" {
  description = "List of security group ids for the load balancer"
  type = list(string)
}

// this or subnets instead?
variable "subnet_ids" {
  type = list(string)
}

variable "vpc_id" {
  type = string
}

/* variable "vpc_cidr_block" {
  type = string
} */
