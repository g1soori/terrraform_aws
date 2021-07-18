provider "aws" {
  region     = var.region
  access_key = var.access_key
  secret_key = var.secret_key
 # version    = "~> 3.0"
  profile    = var.profile
}

variable access_key {
  type        = string
  default     = ""
  description = "description"
}

variable secret_key {
  type        = string
  default     = ""
  description = "description"
}

variable resource_prefix {
  type        = string
  default     = ""
  description = "description"
}

variable region {
  type        = string
  default     = "us-west-2"
  description = "description"
}

variable server_count {
  type        = number
  default     = 1
  description = "description"
}

variable environment {
  type        = string
  default     = "dev"
  description = "description"
}

variable profile {
  type        = string
  default     = "g1"
  description = "description"
}

