resource "aws_security_group" "alb" {
  vpc_id = "${module.vpc.vpc_id}"
  name   = "kelk-example-alb"
}

resource "aws_security_group_rule" "alb_https" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.alb.id}"
}

resource "aws_security_group_rule" "alb_outbound" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "all"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.alb.id}"
}

resource "aws_security_group" "web_server" {
  vpc_id = "${module.vpc.vpc_id}"
  name   = "kelk-example-web-server"
}

resource "aws_security_group_rule" "web_server_http" {
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  source_security_group_id = "${aws_security_group.alb.id}"
  security_group_id        = "${aws_security_group.web_server.id}"
}

resource "aws_security_group_rule" "web_server_outbound" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "all"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.web_server.id}"
}
