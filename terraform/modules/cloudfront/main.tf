################################################################################
# CloudFront Origin Access Control
################################################################################

resource "aws_cloudfront_origin_access_control" "movie_images_oac" {
  name                              = "bookmyscreen-s3-oac"
  description                       = "OAC for BookMyScreen Movie Images"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

################################################################################
# CloudFront Distribution
################################################################################

resource "aws_cloudfront_distribution" "movie_images_cdn" {

  enabled             = true
  default_root_object = ""

  origin {
    domain_name              = aws_s3_bucket.movie_images.bucket_regional_domain_name
    origin_id                = "movie-images-s3-origin"
    origin_access_control_id = aws_cloudfront_origin_access_control.movie_images_oac.id
  }

  default_cache_behavior {
    target_origin_id       = "movie-images-s3-origin"
    viewer_protocol_policy = "redirect-to-https"

    allowed_methods = [
      "GET",
      "HEAD"
    ]

    cached_methods = [
      "GET",
      "HEAD"
    ]

    compress = true

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  tags = {
    Name        = "bookmyscreen-movie-images-cdn"
    Project     = "BookMyScreen"
    Environment = "Dev"
  }
}