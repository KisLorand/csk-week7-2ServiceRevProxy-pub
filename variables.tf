variable "project_name" {
  type    = string
  default = "lori-week7-task"
}

variable "aws_region" {
  type    = string
  default = "eu-central-1"
}

variable "aws_profile" {
  type = string
}

//scalability - list for app ec2/subnet
variable "ec2_instances" {
  type = list(object({
    name              = string
    type              = string // bastion | app
    instance_type     = string
    ami_id            = string
    availability_zone = string
    subnet_type       = string // public | private

    // for the bastion host
    key_name          = string
    public_key_string = string
    public_key_path   = string
  }))
}

// root -> more objects instead of simpler types
variable "vpc" {
  type = object({
    name       = string
    cidr_block = string
    tags       = map(string)
    NAT_subnet = string

    subnets = list(object({
      name              = string
      cidr_block        = string
      type              = string // public | private
      availability_zone = string // a, b, c
    }))
  })
}

variable "security_groups" {
  type = list(object({
    name        = string,
    description = string,
    ingress = list(object({
      name        = string
      description = string
      from_port   = string
      ip_protocol = string
      to_port     = string
      // security_group_id = string,
      cidr_block = optional(string)
      cidr_ref   = optional(string)
    })),
    egress = list(object({
      name        = string
      description = string
      from_port   = string
      ip_protocol = string
      to_port     = string
      // security_group_id = string,
      cidr_block = optional(string)
      cidr_ref   = optional(string)
    }))
  }))
}

variable "eks_cluster" {
  type = object({
    name    = string
    subnets = list(string)
    version = string

    configure_kubectl = bool

    node_groups = list(object({
      node_group_name = string
      ami_type        = string
      instance_types  = list(string)
      capacity_type   = string
      disk_size       = number

      scaling_config = object({
        desired_size = number
        min_size     = number
        max_size     = number
      })
    }))
  })
}

variable "ecr_registries" {
  type = list(object({
    name                 = string
    image_tag_mutability = string // "IMMUTABLE" | "MUTABLE"
    force_delete         = bool
    scan_on_push         = bool
    encryption_type      = string // "AES256" | "KMS"
  }))
}