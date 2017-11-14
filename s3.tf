resource "aws_s3_bucket" "instance_logs" {
  bucket        = "kelk-example-instance-logs-${random_string.name_suffix.result}"
  acl           = "private"
  force_destroy = true
}

data "aws_elb_service_account" "main" {}

data "aws_iam_policy_document" "alb_logs_bucket_policy" {
  statement {
    principals {
      type = "AWS"

      identifiers = [
        "${data.aws_elb_service_account.main.arn}",
      ]
    }

    actions = [
      "s3:PutObject",
    ]

    resources = [
      "arn:aws:s3:::kelk-example-alb-logs-${random_string.name_suffix.result}/*",
    ]
  }
}

resource "aws_s3_bucket" "alb_logs" {
  bucket        = "kelk-example-alb-logs-${random_string.name_suffix.result}"
  acl           = "private"
  force_destroy = true
  policy        = "${data.aws_iam_policy_document.alb_logs_bucket_policy.json}"
}

resource "aws_s3_bucket" "cloudfront_logs" {
  bucket        = "kelk-example-cloudfront-logs-${random_string.name_suffix.result}"
  acl           = "private"
  force_destroy = true
}

data "aws_iam_policy_document" "cloudtrail_logs_bucket_policy" {
  statement {
    principals {
      type = "Service"

      identifiers = [
        "cloudtrail.amazonaws.com",
      ]
    }

    actions = [
      "s3:GetBucketAcl",
    ]

    resources = [
      "arn:aws:s3:::kelk-example-cloudtrail-logs-${random_string.name_suffix.result}",
    ]
  }

  statement {
    principals {
      type = "Service"

      identifiers = [
        "cloudtrail.amazonaws.com",
      ]
    }

    actions = [
      "s3:PutObject",
    ]

    resources = [
      "arn:aws:s3:::kelk-example-cloudtrail-logs-${random_string.name_suffix.result}/*",
    ]

    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"

      values = [
        "bucket-owner-full-control",
      ]
    }
  }
}

resource "aws_s3_bucket" "cloudtrail_logs" {
  bucket        = "kelk-example-cloudtrail-logs-${random_string.name_suffix.result}"
  acl           = "private"
  force_destroy = true
  policy        = "${data.aws_iam_policy_document.cloudtrail_logs_bucket_policy.json}"
}
