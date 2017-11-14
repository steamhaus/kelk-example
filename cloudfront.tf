resource "aws_cloudfront_distribution" "kelk" {
  origin {
    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only"

      origin_ssl_protocols = [
        "TLSv1",
        "TLSv1.1",
        "TLSv1.2",
      ]
    }

    domain_name = "${aws_alb.kelk.dns_name}"
    origin_id   = "alb"
  }

  enabled         = true
  is_ipv6_enabled = true

  logging_config {
    include_cookies = false
    bucket          = "${aws_s3_bucket.cloudfront_logs.bucket_domain_name }"
  }

  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "alb"

    forwarded_values {
      query_string = true

      cookies {
        forward = "all"
      }

      headers = [
        "*",
      ]
    }

    viewer_protocol_policy = "allow-all"
    min_ttl                = 0
    default_ttl            = 0
    max_ttl                = 0
  }

  price_class = "PriceClass_200"

  restrictions {
    geo_restriction {
      restriction_type = "whitelist"
      locations        = ["GB"]
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
    minimum_protocol_version       = "TLSv1"
  }
}
