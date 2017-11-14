resource "aws_iam_instance_profile" "web_server" {
  name = "kelk-example-web-server"
  role = "${aws_iam_role.web_server.name}"
}

data "aws_iam_policy_document" "web_server_assume" {
  statement {
    principals {
      type = "Service"

      identifiers = [
        "ec2.amazonaws.com",
      ]
    }

    actions = [
      "sts:AssumeRole",
    ]
  }
}

resource "aws_iam_role" "web_server" {
  name               = "kelk-example-web-server"
  path               = "/"
  assume_role_policy = "${data.aws_iam_policy_document.web_server_assume.json}"
}

data "aws_iam_policy_document" "web_server" {
  statement {
    actions = [
      "firehose:PutRecordBatch",
    ]

    resources = [
      "${aws_kinesis_firehose_delivery_stream.kelk.arn}",
    ]
  }
}

resource "aws_iam_policy" "web_server" {
  name = "kelk-example-web-server"

  policy = "${data.aws_iam_policy_document.web_server.json}"
}

resource "aws_iam_role_policy_attachment" "web_server" {
  role       = "${aws_iam_role.web_server.name}"
  policy_arn = "${aws_iam_policy.web_server.arn}"
}

data "aws_iam_policy_document" "firehose_assume" {
  statement {
    principals {
      type = "Service"

      identifiers = [
        "firehose.amazonaws.com",
      ]
    }

    actions = [
      "sts:AssumeRole",
    ]
  }
}

resource "aws_iam_role" "firehose" {
  name               = "kelk-example-firehose"
  assume_role_policy = "${data.aws_iam_policy_document.firehose_assume.json}"
}

data "aws_iam_policy_document" "firehose" {
  statement {
    actions = [
      "s3:AbortMultipartUpload",
      "s3:GetBucketLocation",
      "s3:GetObject",
      "s3:ListBucket",
      "s3:ListBucketMultipartUploads",
      "s3:PutObject",
    ]

    resources = [
      "${aws_s3_bucket.instance_logs.arn}",
      "${aws_s3_bucket.instance_logs.arn}/*",
    ]
  }

  statement {
    actions = [
      "lambda:InvokeFunction",
      "lambda:GetFunctionConfiguration",
    ]

    resources = [
      "arn:aws:lambda:eu-west-1:${data.aws_caller_identity.current.account_id}:function:%FIREHOSE_DEFAULT_FUNCTION%:%FIREHOSE_DEFAULT_VERSION%",
    ]
  }

  statement {
    actions = [
      "es:DescribeElasticsearchDomain",
      "es:DescribeElasticsearchDomains",
      "es:DescribeElasticsearchDomainConfig",
      "es:ESHttpPost",
      "es:ESHttpPut",
    ]

    resources = [
      "${aws_elasticsearch_domain.kelk.arn}",
      "${aws_elasticsearch_domain.kelk.arn}/*",
    ]
  }

  statement {
    actions = [
      "es:ESHttpGet",
    ]

    resources = [
      "${aws_elasticsearch_domain.kelk.arn}/_all/_settings",
      "${aws_elasticsearch_domain.kelk.arn}/_cluster/stats",
      "${aws_elasticsearch_domain.kelk.arn}/instance-logs*/_mapping/instance-logs",
      "${aws_elasticsearch_domain.kelk.arn}/_nodes",
      "${aws_elasticsearch_domain.kelk.arn}/_nodes/stats",
      "${aws_elasticsearch_domain.kelk.arn}/_nodes/*/stats",
      "${aws_elasticsearch_domain.kelk.arn}/_stats",
      "${aws_elasticsearch_domain.kelk.arn}/instance-logs*/_stats",
    ]
  }

  statement {
    actions = [
      "logs:PutLogEvents",
    ]

    resources = [
      "arn:aws:logs:eu-west-1:${data.aws_caller_identity.current.account_id}:log-group:/aws/kinesisfirehose/kelk-example:log-stream:*",
    ]
  }

  statement {
    actions = [
      "kinesis:DescribeStream",
      "kinesis:GetShardIterator",
      "kinesis:GetRecords",
    ]

    resources = [
      "arn:aws:kinesis:eu-west-1:${data.aws_caller_identity.current.account_id}:stream/%FIREHOSE_STREAM_NAME%",
    ]
  }
}

resource "aws_iam_policy" "firehose" {
  name   = "kelk-example-firehose"
  policy = "${data.aws_iam_policy_document.firehose.json}"
}

resource "aws_iam_role_policy_attachment" "firehose" {
  role       = "${aws_iam_role.firehose.name}"
  policy_arn = "${aws_iam_policy.firehose.arn}"
}

data "aws_iam_policy_document" "lambda_assume" {
  statement {
    actions = [
      "sts:AssumeRole",
    ]

    principals {
      type = "Service"

      identifiers = [
        "lambda.amazonaws.com",
      ]
    }
  }
}

resource "aws_iam_role" "cloudfront_log_lambda" {
  name               = "kelk-example-cloudfront-log-lambda"
  assume_role_policy = "${data.aws_iam_policy_document.lambda_assume.json}"
}

data "aws_iam_policy_document" "cloudfront_log_lambda" {
  statement {
    actions = [
      "s3:GetObject",
      "s3:ListBucket",
    ]

    resources = [
      "${aws_s3_bucket.cloudfront_logs.arn}",
      "${aws_s3_bucket.cloudfront_logs.arn}/*",
    ]
  }

  statement {
    actions = [
      "es:DescribeElasticsearchDomain",
      "es:DescribeElasticsearchDomains",
      "es:DescribeElasticsearchDomainConfig",
      "es:ESHttpPost",
      "es:ESHttpPut",
    ]

    resources = [
      "${aws_elasticsearch_domain.kelk.arn}",
      "${aws_elasticsearch_domain.kelk.arn}/*",
    ]
  }

  statement {
    actions = [
      "logs:CreateLogGroup",
    ]

    resources = [
      "arn:aws:logs:eu-west-1:${data.aws_caller_identity.current.account_id}:*",
    ]
  }

  statement {
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]

    resources = [
      "arn:aws:logs:eu-west-1:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/kelk-example-cloudfront-log-ingestor:*",
    ]
  }
}

resource "aws_iam_policy" "cloudfront_log_lambda" {
  name   = "kelk-example-cloudfront-log-lambda"
  policy = "${data.aws_iam_policy_document.cloudfront_log_lambda.json}"
}

resource "aws_iam_role_policy_attachment" "cloudfront_log_lambda" {
  role       = "${aws_iam_role.cloudfront_log_lambda.name}"
  policy_arn = "${aws_iam_policy.cloudfront_log_lambda.arn}"
}

resource "aws_iam_role" "alb_log_lambda" {
  name               = "kelk-example-alb-log-lambda"
  assume_role_policy = "${data.aws_iam_policy_document.lambda_assume.json}"
}

data "aws_iam_policy_document" "alb_log_lambda" {
  statement {
    actions = [
      "s3:GetObject",
      "s3:ListBucket",
    ]

    resources = [
      "${aws_s3_bucket.alb_logs.arn}",
      "${aws_s3_bucket.alb_logs.arn}/*",
    ]
  }

  statement {
    actions = [
      "es:DescribeElasticsearchDomain",
      "es:DescribeElasticsearchDomains",
      "es:DescribeElasticsearchDomainConfig",
      "es:ESHttpPost",
      "es:ESHttpPut",
    ]

    resources = [
      "${aws_elasticsearch_domain.kelk.arn}",
      "${aws_elasticsearch_domain.kelk.arn}/*",
    ]
  }

  statement {
    actions = [
      "logs:CreateLogGroup",
    ]

    resources = [
      "arn:aws:logs:eu-west-1:${data.aws_caller_identity.current.account_id}:*",
    ]
  }

  statement {
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]

    resources = [
      "arn:aws:logs:eu-west-1:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/kelk-example-alb-log-ingestor:*",
    ]
  }
}

resource "aws_iam_policy" "alb_log_lambda" {
  name   = "kelk-example-alb-log-lambda"
  policy = "${data.aws_iam_policy_document.alb_log_lambda.json}"
}

resource "aws_iam_role_policy_attachment" "alb_log_lambda" {
  role       = "${aws_iam_role.alb_log_lambda.name}"
  policy_arn = "${aws_iam_policy.alb_log_lambda.arn}"
}

resource "aws_iam_role" "cloudtrail_log_lambda" {
  name               = "kelk-example-cloudtrail-log-lambda"
  assume_role_policy = "${data.aws_iam_policy_document.lambda_assume.json}"
}

data "aws_iam_policy_document" "cloudtrail_log_lambda" {
  statement {
    actions = [
      "s3:GetObject",
      "s3:ListBucket",
    ]

    resources = [
      "${aws_s3_bucket.cloudtrail_logs.arn}",
      "${aws_s3_bucket.cloudtrail_logs.arn}/*",
    ]
  }

  statement {
    actions = [
      "es:DescribeElasticsearchDomain",
      "es:DescribeElasticsearchDomains",
      "es:DescribeElasticsearchDomainConfig",
      "es:ESHttpPost",
      "es:ESHttpPut",
    ]

    resources = [
      "${aws_elasticsearch_domain.kelk.arn}",
      "${aws_elasticsearch_domain.kelk.arn}/*",
    ]
  }

  statement {
    actions = [
      "logs:CreateLogGroup",
    ]

    resources = [
      "arn:aws:logs:eu-west-1:${data.aws_caller_identity.current.account_id}:*",
    ]
  }

  statement {
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]

    resources = [
      "arn:aws:logs:eu-west-1:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/kelk-example-cloudtrail-log-ingestor:*",
    ]
  }
}

resource "aws_iam_policy" "cloudtrail_log_lambda" {
  name   = "kelk-example-cloudtrail-log-lambda"
  policy = "${data.aws_iam_policy_document.cloudtrail_log_lambda.json}"
}

resource "aws_iam_role_policy_attachment" "cloudtrail_log_lambda" {
  role       = "${aws_iam_role.cloudtrail_log_lambda.name}"
  policy_arn = "${aws_iam_policy.cloudtrail_log_lambda.arn}"
}
