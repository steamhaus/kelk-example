output "elasticsearch_endpoint" {
  value = "https://${aws_elasticsearch_domain.kelk.endpoint}"
}

output "cloudfront_domain_name" {
  value = "https://${aws_cloudfront_distribution.kelk.domain_name}"
}
