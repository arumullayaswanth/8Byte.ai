variable "name" { type = string }
variable "vpc_id" { type = string }
variable "private_app_subnet_ids" { type = list(string) }

variable "alb_listener_arn" { type = string }
variable "target_group_arn" { type = string }
variable "app_security_group_id" { type = string }

variable "db_secret_arn" { type = string }

variable "container_image" { type = string }

variable "container_port" {
  type    = number
  default = 3000
}

variable "task_cpu" {
  type    = number
  default = 256
}

variable "task_memory" {
  type    = number
  default = 512
}

variable "desired_count" {
  type    = number
  default = 2
}

variable "max_count" {
  type    = number
  default = 4
}

variable "log_retention_days" {
  type    = number
  default = 14
}
