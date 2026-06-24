################################################################################
# Secrets Manager - BookMyScreen Backend Secrets
################################################################################

resource "aws_secretsmanager_secret" "backend_secrets" {
  name                    = "bookmyscreen/backend-secrets"
  description             = "Secrets for BookMyScreen Backend Application"
  recovery_window_in_days = 7

  tags = {
    Name        = "bookmyscreen-backend-secrets"
    Project     = "BookMyScreen"
    Environment = "Dev"
  }
}

resource "aws_secretsmanager_secret_version" "backend_secrets_version" {
  secret_id = aws_secretsmanager_secret.backend_secrets.id

  secret_string = jsonencode({
    MONGO_CONNECTION_STRING = var.mongo_connection_string
    MONGO_REPLICA_STRING    = var.mongo_replica_string
    EMAIL_USERNAME          = var.email_username
    EMAIL_PASSWORD          = var.email_password
    HASH_SECRET             = var.hash_secret
    ACCESS_TOKEN_SECRET     = var.access_token_secret
    REFRESH_TOKEN_SECRET    = var.refresh_token_secret
  })
}