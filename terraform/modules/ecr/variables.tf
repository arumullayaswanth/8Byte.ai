variable "name" {
  type        = string
  description = "ECR repository name."
}

variable "image_tag_mutability" {
  type    = string
  default = "MUTABLE"
}

variable "scan_on_push" {
  type    = bool
  default = true
}

variable "encryption_type" {
  type    = string
  default = "AES256"
}

variable "untagged_expiry_days" {
  type    = number
  default = 7
}
