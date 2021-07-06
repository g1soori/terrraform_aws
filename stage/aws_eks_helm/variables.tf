provider "aws" {
  region     = var.region
  access_key = var.access_key
  secret_key = var.secret_key
}

variable "kubernetes_version" {
  type    = string
  default = "1.18"
}

variable "workers_count" {
  type = number
  default = 1
}

variable "workers_type" {
  type    = string
  default = "t3.micro"
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
  default     = ""
  description = "description"
}