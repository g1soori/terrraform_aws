provider "aws" {
  region     = var.region
  access_key = var.access_key
  secret_key = var.secret_key
  profile    = var.profile
 # version    = "~> 3.0"
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

variable region {
  type        = string
  default     = ""
  description = "description"
}

variable profile {
  type        = string
  default     = "g1"
  description = "description"
}

