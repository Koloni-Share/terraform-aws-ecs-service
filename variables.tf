variable "custom_iam_policies" {
  type    = list(string)
  default = []
}

variable "environment_variables" {
  type    = map(string)
  default = {}
}

variable "environment_secrets" {
  type    = map(string)
  default = {}
}

variable "service_name" {
  type = string
}

variable "service_version" {
  type = string
}

variable "cluster_name" {
  type = string
}

variable "cluster_arn" {
  type = string
}

variable "private_subnets" {
  type = list(string)
}

variable "public_subnets" {
  type = list(string)
}

variable "vpc_id" {
  type = string
}

variable "certificate_arn" {
  type = string
}

variable "outbound_sg_id" {
  type = string
}

variable "lb_internal" {
  type    = bool
  default = false
}

variable "lb_ip_address_type" {
  type    = string
  default = "dualstack"
}

variable "health_check_path" {
  type    = string
  default = "/"
}

variable "container_cpu" {
  type    = number
  default = 256
}

variable "container_memory" {
  type    = number
  default = 2048
}

variable "container_memory_reservation" {
  type    = number
  default = 1024
}
