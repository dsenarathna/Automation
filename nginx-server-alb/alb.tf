# Define the security group for public subnet
resource "aws_security_group" "sgweb" {
  name = "vpc_nginx_web"
  description = "Allow incoming HTTP connections & SSH access"
  vpc_id = "${aws_default_vpc.default.id}"

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = -1
    to_port = -1
    protocol = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks =  ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Web Server SG"
  }
}

data "aws_subnet_ids" "subnet" {
  vpc_id = "${aws_default_vpc.default.id}"
}

resource "aws_default_vpc" "default" {
   tags = {
     Name = "Default VPC"
   }
}


resource "aws_eip" "nginx-eip" {
  count = length(aws_instance.nginx_wb)
  vpc = true
  instance = "${element(aws_instance.nginx_wb.*.id,count.index)}"

 tags = {
  Name = "eip-block${count.index + 1}"
}
}

resource "aws_lb_target_group" "nginx-target-group" {
  health_check {
    interval            = 10
    path                = "/"
    protocol            = "HTTP"
    timeout             = 5
    healthy_threshold   = 5
    unhealthy_threshold = 2
  }

  name        = "nginx-tg"
  port        = 80
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = "${aws_default_vpc.default.id}"
}

resource "aws_lb" "aws-alb" {
  name     = "nginx-alb"
  internal = false

  security_groups = [
    "${aws_security_group.sgweb.id}",
  ]

  subnets = data.aws_subnet_ids.subnet.ids

tags = {
    Name = "nginx-alb"
  }

  ip_address_type    = "ipv4"
  load_balancer_type = "application"
}

resource "aws_lb_listener" "nginx-alb-listner" {
  load_balancer_arn = "${aws_lb.aws-alb.arn}"
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.nginx-target-group.arn}"
  }
}

resource "aws_lb_target_group_attachment" "alb-target-group-attachment1" {
  count = length(aws_instance.nginx_wb)
  target_group_arn = "${aws_lb_target_group.nginx-target-group.arn}"
  target_id        = aws_instance.nginx_wb[count.index].id
}

