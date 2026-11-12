variable "name" { 
  type = string 
}

variable "image_tag_mutability" { 
  type = string 
  default = "IMMUTABLE"
  validation {
    condition = contains(
      ["MUTABLE", "IMMUTABLE", "IMMUTABLE_WITH_EXCLUSION", "MUTABLE_WITH_EXCLUSION"],
      var.image_tag_mutability
    )
    error_message = "Invalid value for image_tag_mutability"
  }
}

variable "encryption_type" { 
  type = string 
  description = "Encryption type to use for the repository."
  default = "AES256"
  validation {
    condition = contains(["AES256", "KMS", "KMS_DSSE"], var.encryption_type)
    error_message = "Invalid value for encryption_type - should be one of: AES256, KMS, KMS_DSSE"
  }
} 

variable "force_delete" { 
  type = bool 
}

variable "scan_on_push" { 
  type = bool 
  default = false         // default false (in prod)
}           