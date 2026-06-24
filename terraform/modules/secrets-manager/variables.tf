variable "mongo_connection_string" {
  type        = string
  description = "MongoDB Connection String"
  sensitive   = true
}

variable "mongo_replica_string" {
  type        = string
  description = "MongoDB Replica Set Connection String"
  sensitive   = true
}

variable "email_username" {
  type        = string
  description = "SMTP Username"
  sensitive   = true
}

variable "email_password" {
  type        = string
  description = "SMTP Password"
  sensitive   = true
}

variable "hash_secret" {
  type        = string
  description = "Hash Secret"
  sensitive   = true
}

variable "access_token_secret" {
  type        = string
  description = "Access Token Secret"
  sensitive   = true
}

variable "refresh_token_secret" {
  type        = string
  description = "Refresh Token Secret"
  sensitive   = true
}