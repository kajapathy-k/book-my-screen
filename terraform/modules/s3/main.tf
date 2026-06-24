resource "aws_s3_bucket" "movie_images" {
  bucket = var.bucket_name

  force_destroy = true

  tags = {
    Name        = "BookMyScreen Movie Images"
    Project     = "BookMyScreen"
    Environment = "Dev"
  }
}

resource "aws_s3_bucket_versioning" "movie_images_versioning" {
  bucket = aws_s3_bucket.movie_images.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "movie_images_encryption" {
  bucket = aws_s3_bucket.movie_images.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = var.kms_key_arn
    }
  }
}

resource "aws_s3_bucket_public_access_block" "movie_images_public_block" {
  bucket = aws_s3_bucket.movie_images.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}