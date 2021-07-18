provider "aws" {
  region     = "us-west-2"
  access_key = var.access_key
  secret_key = var.secret_key
  profile    = var.profile
  #version    = "~> 3.0"
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

variable "subnets" {
  type        = map
  description = "map of values"
}

variable profile {
  type        = string
  default     = "g1"
  description = "description"
}
