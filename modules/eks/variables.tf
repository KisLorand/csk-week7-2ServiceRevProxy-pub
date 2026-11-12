variable "project_name" {
    description = "The name of the project, that will be present in all of the created resources"
    type = string
}

variable "name" { 
    type = string 
}

variable "subnet_ids" { type = list(string) }
variable "vpc_id" { type = string }
variable "k8s_version" { type = string }


variable "configure_kubectl" { 
    type = object({
        aws_region = string
        aws_cli_profile = string
    })
}

variable "lb_sg_id" {
  type = string
}