resource "aws_elasticsearch_domain" "kelk" {
  domain_name           = "kelk-example"
  elasticsearch_version = "5.5"

  cluster_config {
    instance_type = "t2.small.elasticsearch"
  }

  ebs_options {
    ebs_enabled = true
    volume_size = 10
  }
}

data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "es_kelk" {
  statement {
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }

    actions = [
      "es:*",
    ]

    resources = [
      "${aws_elasticsearch_domain.kelk.arn}",
      "${aws_elasticsearch_domain.kelk.arn}/*",
    ]
  }
}

resource "aws_elasticsearch_domain_policy" "kelk" {
  domain_name     = "${aws_elasticsearch_domain.kelk.domain_name}"
  access_policies = "${data.aws_iam_policy_document.es_kelk.json}"
}
