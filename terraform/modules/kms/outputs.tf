output "kms_key_arn" {
  value = aws_kms_key.movie_images_kms.arn
}

output "kms_key_id" {
  value = aws_kms_key.movie_images_kms.key_id
}

output "kms_alias" {
  value = aws_kms_alias.movie_images_alias.name
}