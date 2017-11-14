data "aws_ami" "amazon_linux" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn-ami-hvm*"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  owners = ["amazon"]
}

data "template_file" "web_server_user_data" {
  template = "${file("user_data.tpl")}"
}

resource "aws_launch_configuration" "web_server" {
  lifecycle {
    create_before_destroy = true
  }

  name_prefix          = "kelk-example-web-server"
  image_id             = "${data.aws_ami.amazon_linux.id}"
  instance_type        = "t2.micro"
  user_data            = "${data.template_file.web_server_user_data.rendered}"
  security_groups      = ["${aws_security_group.web_server.id}"]
  iam_instance_profile = "${aws_iam_instance_profile.web_server.name}"
}

resource "aws_autoscaling_group" "web_server" {
  depends_on           = ["aws_kinesis_firehose_delivery_stream.kelk"]
  vpc_zone_identifier  = ["${module.vpc.private_subnets}"]
  name                 = "kelk-example-web-server"
  max_size             = 1
  min_size             = 1
  desired_capacity     = 1
  force_delete         = true
  launch_configuration = "${aws_launch_configuration.web_server.name}"
  target_group_arns    = ["${aws_alb_target_group.kelk.arn}"]
  health_check_type    = "ELB"

  tag {
    key                 = "Name"
    value               = "kelk-example-web-server"
    propagate_at_launch = true
  }
}
