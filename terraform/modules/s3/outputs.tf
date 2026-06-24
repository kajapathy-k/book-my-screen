output "bucket_name" {
  value = aws_s3_bucket.movie_images.bucket
}

output "bucket_arn" {
  value = aws_s3_bucket.movie_images.arn
}