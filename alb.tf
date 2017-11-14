resource "aws_alb" "kelk" {
  name            = "kelk-example"
  internal        = false
  security_groups = ["${aws_security_group.alb.id}"]
  subnets         = ["${module.vpc.public_subnets}"]

  access_logs {
    enabled = true
    bucket  = "${aws_s3_bucket.alb_logs.bucket}"
  }
}

resource "aws_alb_target_group" "kelk" {
  name     = "kelk-example"
  port     = 80
  protocol = "HTTP"
  vpc_id   = "${module.vpc.vpc_id}"
}

resource "aws_alb_listener" "kelk" {
  load_balancer_arn = "${aws_alb.kelk.arn}"
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = "${aws_alb_target_group.kelk.arn}"
    type             = "forward"
  }
}
