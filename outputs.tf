output "service_name" {
  value = var.service_name
}

output "lb_zone_id" {
  value = module.service.aws_lb_lb_zone_id
}

output "lb_dns_name" {
  value = module.service.aws_lb_lb_dns_name
}
