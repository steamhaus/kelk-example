resource "aws_kinesis_firehose_delivery_stream" "kelk" {
  name        = "kelk-example"
  destination = "elasticsearch"

  s3_configuration {
    role_arn           = "${aws_iam_role.firehose.arn}"
    bucket_arn         = "${aws_s3_bucket.instance_logs.arn}"
    compression_format = "GZIP"
  }

  elasticsearch_configuration {
    domain_arn     = "${aws_elasticsearch_domain.kelk.arn}"
    role_arn       = "${aws_iam_role.firehose.arn}"
    index_name     = "instance-logs"
    type_name      = "instance-logs"
    s3_backup_mode = "AllDocuments"
  }
}
