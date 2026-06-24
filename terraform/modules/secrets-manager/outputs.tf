output "secret_arn" {
  value = aws_secretsmanager_secret.backend_secrets.arn
}

output "secret_name" {
  value = aws_secretsmanager_secret.backend_secrets.name
}