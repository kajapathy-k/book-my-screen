resource "aws_kms_key" "movie_images_kms" {
  description             = "KMS key for encrypting BookMyScreen movie posters"
  deletion_window_in_days = 7
  enable_key_rotation     = true

  tags = {
    Name        = "bms-movie-images-kms"
    Project     = "BookMyScreen"
    Environment = "Dev"
  }
}

resource "aws_kms_alias" "movie_images_alias" {
  name          = "alias/bms-movie-images-key"
  target_key_id = aws_kms_key.movie_images_kms.key_id
}