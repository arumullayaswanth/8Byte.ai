output "alb_dns_name" {
  value = module.alb.alb_dns_name
}

output "ecr_repository_url" {
  value = module.ecr.repository_url
}

output "ecs_cluster_name" {
  value = module.ecs.cluster_name
}

output "ecs_service_name" {
  value = module.ecs.service_name
}

output "db_endpoint" {
  value = module.rds.db_endpoint
}

output "db_secret_arn" {
  value = module.rds.db_secret_arn
}

output "app_dashboard" {
  value = module.monitoring.app_dashboard_name
}

output "db_dashboard" {
  value = module.monitoring.db_dashboard_name
}

output "log_group_name" {
  value = module.ecs.log_group_name
}
