resource "null_resource" "cloudfront_log_lambda" {
  provisioner "local-exec" {
    command = "cd lambdas/cloudfront-log-ingestor && rm -rf packaged && mkdir packaged && cp lambda.py packaged/ && cp requirements.txt packaged/ && cd packaged && pip install -r requirements.txt -t ."
  }

  provisioner "local-exec" {
    when    = "destroy"
    command = "rm -rf lambdas/cloudfront-log-ingestor/cloudfront-log-ingestor.zip lambdas/cloudfront-log-ingestor/packaged"
  }
}

data "archive_file" "cloudfront_log_lambda" {
  depends_on  = ["null_resource.cloudfront_log_lambda"]
  type        = "zip"
  source_dir  = "lambdas/cloudfront-log-ingestor/packaged"
  output_path = "lambdas/cloudfront-log-ingestor/cloudfront-log-ingestor.zip"
}

resource "aws_lambda_function" "cloudfront_log_lambda" {
  depends_on    = ["data.archive_file.cloudfront_log_lambda"]
  filename      = "lambdas/cloudfront-log-ingestor/cloudfront-log-ingestor.zip"
  function_name = "kelk-example-cloudfront-log-ingestor"
  role          = "${aws_iam_role.cloudfront_log_lambda.arn}"
  handler       = "lambda.lambda_handler"
  runtime       = "python3.6"
  timeout       = 60

  environment {
    variables = {
      ES_HOST   = "${aws_elasticsearch_domain.kelk.endpoint}"
      ES_REGION = "eu-west-1"
    }
  }
}

resource "aws_lambda_permission" "cloudfront_log_lambda" {
  statement_id  = "kelk-example-cloudfront-log-ingestor"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.cloudfront_log_lambda.arn}"
  principal     = "s3.amazonaws.com"
  source_arn    = "${aws_s3_bucket.cloudfront_logs.arn}"
}

resource "aws_s3_bucket_notification" "cloudfront_log_lambda" {
  bucket = "${aws_s3_bucket.cloudfront_logs.id}"

  lambda_function {
    lambda_function_arn = "${aws_lambda_function.cloudfront_log_lambda.arn}"
    events              = ["s3:ObjectCreated:*"]
  }
}

resource "null_resource" "alb_log_lambda" {
  provisioner "local-exec" {
    command = "cd lambdas/alb-log-ingestor && rm -rf packaged && mkdir packaged && cp lambda.py packaged/ && cp requirements.txt packaged/ && cd packaged && pip install -r requirements.txt -t ."
  }

  provisioner "local-exec" {
    when    = "destroy"
    command = "rm -rf lambdas/alb-log-ingestor/alb-log-ingestor.zip lambdas/alb-log-ingestor/packaged"
  }
}

data "archive_file" "alb_log_lambda" {
  depends_on  = ["null_resource.alb_log_lambda"]
  type        = "zip"
  source_dir  = "lambdas/alb-log-ingestor/packaged"
  output_path = "lambdas/alb-log-ingestor/alb-log-ingestor.zip"
}

resource "aws_lambda_function" "alb_log_lambda" {
  depends_on    = ["data.archive_file.alb_log_lambda"]
  filename      = "lambdas/alb-log-ingestor/alb-log-ingestor.zip"
  function_name = "kelk-example-alb-log-ingestor"
  role          = "${aws_iam_role.alb_log_lambda.arn}"
  handler       = "lambda.lambda_handler"
  runtime       = "python3.6"
  timeout       = 60

  environment {
    variables = {
      ES_HOST   = "${aws_elasticsearch_domain.kelk.endpoint}"
      ES_REGION = "eu-west-1"
    }
  }
}

resource "aws_lambda_permission" "alb_log_lambda" {
  statement_id  = "kelk-example-alb-log-ingestor"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.alb_log_lambda.arn}"
  principal     = "s3.amazonaws.com"
  source_arn    = "${aws_s3_bucket.alb_logs.arn}"
}

resource "aws_s3_bucket_notification" "alb_log_lambda" {
  bucket = "${aws_s3_bucket.alb_logs.id}"

  lambda_function {
    lambda_function_arn = "${aws_lambda_function.alb_log_lambda.arn}"
    events              = ["s3:ObjectCreated:*"]
  }
}

resource "null_resource" "cloudtrail_log_lambda" {
  provisioner "local-exec" {
    command = "cd lambdas/cloudtrail-log-ingestor && rm -rf packaged && mkdir packaged && cp lambda.py packaged/ && cp requirements.txt packaged/ && cd packaged && pip install -r requirements.txt -t ."
  }

  provisioner "local-exec" {
    when    = "destroy"
    command = "rm -rf lambdas/cloudtrail-log-ingestor/cloudtrail-log-ingestor.zip lambdas/cloudtrail-log-ingestor/packaged"
  }
}

data "archive_file" "cloudtrail_log_lambda" {
  depends_on  = ["null_resource.cloudtrail_log_lambda"]
  type        = "zip"
  source_dir  = "lambdas/cloudtrail-log-ingestor/packaged"
  output_path = "lambdas/cloudtrail-log-ingestor/cloudtrail-log-ingestor.zip"
}

resource "aws_lambda_function" "cloudtrail_log_lambda" {
  depends_on    = ["data.archive_file.cloudtrail_log_lambda"]
  filename      = "lambdas/cloudtrail-log-ingestor/cloudtrail-log-ingestor.zip"
  function_name = "kelk-example-cloudtrail-log-ingestor"
  role          = "${aws_iam_role.cloudtrail_log_lambda.arn}"
  handler       = "lambda.lambda_handler"
  runtime       = "python3.6"
  timeout       = 60

  environment {
    variables = {
      ES_HOST   = "${aws_elasticsearch_domain.kelk.endpoint}"
      ES_REGION = "eu-west-1"
    }
  }
}

resource "aws_lambda_permission" "cloudtrail_log_lambda" {
  statement_id  = "kelk-example-cloudtrail-log-ingestor"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.cloudtrail_log_lambda.arn}"
  principal     = "s3.amazonaws.com"
  source_arn    = "${aws_s3_bucket.cloudtrail_logs.arn}"
}

resource "aws_s3_bucket_notification" "cloudtrail_log_lambda" {
  bucket = "${aws_s3_bucket.cloudtrail_logs.id}"

  lambda_function {
    lambda_function_arn = "${aws_lambda_function.cloudtrail_log_lambda.arn}"
    events              = ["s3:ObjectCreated:*"]
  }
}
