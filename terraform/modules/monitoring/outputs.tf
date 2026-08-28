output "sns_topic_arn" {
  value = aws_sns_topic.alerts.arn
}

output "app_dashboard_name" {
  value = aws_cloudwatch_dashboard.app.dashboard_name
}

output "db_dashboard_name" {
  value = aws_cloudwatch_dashboard.db.dashboard_name
}
