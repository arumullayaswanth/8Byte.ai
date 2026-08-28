resource "random_password" "db" {
  length  = 24
  special = false
}

resource "aws_secretsmanager_secret" "db" {
  name        = "${var.name}-db-credentials"
  description = "rds credentials for ${var.name}"
}

resource "aws_secretsmanager_secret_version" "db" {
  secret_id = aws_secretsmanager_secret.db.id
  secret_string = jsonencode({
    engine   = "postgres"
    username = var.db_username
    password = random_password.db.result
    dbname   = var.db_name
    host     = aws_db_instance.this.address
    port     = 5432
  })

  # rotation rewrites the password, so don't let terraform reset it back
  lifecycle {
    ignore_changes = [secret_string]
  }
}

resource "aws_db_subnet_group" "this" {
  name       = "${var.name}-db-subnets"
  subnet_ids = var.private_data_subnet_ids
  tags       = { Name = "${var.name}-db-subnets" }
}

resource "aws_security_group" "db" {
  name        = "${var.name}-db-sg"
  description = "postgres from app tier only"
  vpc_id      = var.vpc_id

  ingress {
    description     = "postgres from app"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [var.app_security_group_id]
  }

  # the rotation lambda also needs to connect to change the password
  ingress {
    description     = "postgres from rotation lambda"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.rotation.id]
  }

  egress {
    description = "allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "${var.name}-db-sg" }
}

resource "aws_db_instance" "this" {
  identifier     = "${var.name}-postgres"
  engine         = "postgres"
  engine_version = var.engine_version
  instance_class = var.instance_class

  allocated_storage     = var.allocated_storage
  max_allocated_storage = var.max_allocated_storage
  storage_type          = "gp3"
  storage_encrypted     = true

  db_name  = var.db_name
  username = var.db_username
  password = random_password.db.result
  port     = 5432

  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = [aws_security_group.db.id]
  publicly_accessible    = false

  multi_az = var.multi_az

  backup_retention_period = var.backup_retention_days
  backup_window           = "03:00-04:00"
  maintenance_window      = "Mon:04:00-Mon:05:00"
  copy_tags_to_snapshot   = true
  deletion_protection     = var.deletion_protection
  skip_final_snapshot     = var.skip_final_snapshot

  enabled_cloudwatch_logs_exports = ["postgresql", "upgrade"]
  performance_insights_enabled    = true

  tags = { Name = "${var.name}-postgres" }
}

# ---- daily password rotation ----

resource "aws_security_group" "rotation" {
  name        = "${var.name}-rotation-sg"
  description = "secrets manager rotation lambda"
  vpc_id      = var.vpc_id

  egress {
    description = "allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "${var.name}-rotation-sg" }
}

# aws-provided single-user postgres rotation function from the serverless repo
resource "aws_serverlessapplicationrepository_cloudformation_stack" "rotation" {
  name             = "${var.name}-db-rotation"
  application_id   = "arn:aws:serverlessrepo:us-east-1:297356227824:applications/SecretsManagerRDSPostgreSQLRotationSingleUser"
  semantic_version = "1.1.60"
  capabilities = [
    "CAPABILITY_IAM",
    "CAPABILITY_RESOURCE_POLICY",
    "CAPABILITY_AUTO_EXPAND",
  ]

  parameters = {
    functionName        = "${var.name}-db-rotation"
    endpoint            = "https://secretsmanager.${var.region}.amazonaws.com"
    vpcSubnetIds        = join(",", var.private_app_subnet_ids)
    vpcSecurityGroupIds = aws_security_group.rotation.id
  }
}

resource "aws_secretsmanager_secret_rotation" "db" {
  secret_id           = aws_secretsmanager_secret.db.id
  rotation_lambda_arn = aws_serverlessapplicationrepository_cloudformation_stack.rotation.outputs["RotationLambdaARN"]

  rotation_rules {
    automatically_after_days = 1
  }

  depends_on = [aws_secretsmanager_secret_version.db]
}
