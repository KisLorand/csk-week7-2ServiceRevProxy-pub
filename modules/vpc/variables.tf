variable "project_name" {
  description = "The name of the project, that will be present in all of the created resources"
  type = string
}

variable "aws_region" {
  type = string
}


variable "vpc_name" {
  type = string
}

variable "vpc_cidr" {
  type = string
  default = "10.0.0.0/8"
}


variable "vpc_tags" {
  description = "Tags to apply to the vpc"
  type = map(string)
}

variable "NAT_subnet" {
  type = string
}

variable "subnets" {
  type = list(object({
    name              = string
    cidr_block        = string
    type              = string // public | private
    availability_zone = string // a, b, c
  }))
}