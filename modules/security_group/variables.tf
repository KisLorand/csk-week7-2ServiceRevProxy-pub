variable "project_name" {
  description = "The name of the project, that will be present in all of the created resources"
  type = string
}

variable "name" {
  type = string
}

variable "description" {
  type = string
  default = ""
}

variable "vpc_id" {
  type = string
}

variable "ingress_rules" {
  type = list(object({
    name = string,
    description  = string,
    from_port  = string,
    ip_protocol = string,
    to_port = string
    // security_group_id = string,
    cidr_block  = optional(string)
    cidr_ref    = optional(string)
  }))
}

variable "egress_rules" {
  type = list(object({
    name = string,
    description  = string,
    from_port  = string,
    ip_protocol = string,
    to_port = string
    // security_group_id = string,
    cidr_block  = optional(string)
    cidr_ref    = optional(string)
  }))
}

variable "dynamic_cidrs" {
  description = "CIDRs only known at apply time, referenced by cidr_ref"
  type        = map(string)
  default     = {}
}