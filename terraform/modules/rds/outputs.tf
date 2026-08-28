output "db_endpoint" {
  value = aws_db_instance.this.address
}

output "db_instance_id" {
  value = aws_db_instance.this.identifier
}

output "db_name" {
  value = var.db_name
}

# ARN of the AWS-managed master credentials secret (holds username + password)
output "db_secret_arn" {
  value = aws_db_instance.this.master_user_secret[0].secret_arn
}

output "db_security_group_id" {
  value = aws_security_group.db.id
}
