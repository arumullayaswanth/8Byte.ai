output "alb_dns_name" { value = module.stack.alb_dns_name }
output "ecr_repository_url" { value = module.stack.ecr_repository_url }
output "ecs_cluster_name" { value = module.stack.ecs_cluster_name }
output "ecs_service_name" { value = module.stack.ecs_service_name }
output "db_endpoint" { value = module.stack.db_endpoint }
output "app_dashboard" { value = module.stack.app_dashboard }
output "db_dashboard" { value = module.stack.db_dashboard }
output "sns_topic_arn" { value = module.stack.sns_topic_arn }
