# Creating External LoadBalancer
resource "aws_lb" "external-alb" {
  name               = "PhpLB"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.jumpsg.id, aws_security_group.Websg.id]
  subnets            = [aws_subnet.public-sub1.id, aws_subnet.public-sub2.id]

  tags = {
    Name = "Php_Lb"
  }
}
resource "aws_lb_target_group" "target-group" {
  name     = "bookstore"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.php-vpc.id

  health_check {
    path                = "/index.php"
    interval            = 5
    timeout             = 2
    healthy_threshold   = 5
    unhealthy_threshold = 2
    matcher             = "200"
  }
}

resource "aws_lb_target_group_attachment" "attachement-1" {
  target_group_arn = aws_lb_target_group.target-group.arn
  target_id        = aws_instance.Web1[0].id
  port             = 80


 depends_on = [
    aws_instance.Web1,
  ]
}

resource "aws_lb_target_group_attachment" "attachment-2" {
  target_group_arn = aws_lb_target_group.target-group.arn
  target_id        = aws_instance.Web2[0].id
  port             = 80
depends_on = [
    aws_instance.Web2,
  ]
}


resource "aws_lb_listener" "external-elb" {
  load_balancer_arn = aws_lb.external-alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target-group.arn
  }
}
# Output the Load Balancer DNS
output "load_balancer_dns" {
  value = aws_lb.external-alb.dns_name
}
