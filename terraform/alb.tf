# Application Load Balancer resource
resource "aws_lb" "mvp_alb" {
  name               = "mvp-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.allow_http.id]
  subnets            = [data.tfe_outputs.network.values.public_subnet[1], data.tfe_outputs.network.values.public_subnet[0]]

  enable_deletion_protection = true
  tags = {
    Environment = "development"
  }
}

# ALB Target group resource
resource "aws_lb_target_group" "alb_tg_mvp" {
  port                          = 80
  protocol                      = "HTTP"
  vpc_id                        = data.tfe_outputs.network.values.vpc
  load_balancing_algorithm_type = "least_outstanding_requests"
  health_check {
    timeout             = 15 # How long to wait for a response
    healthy_threshold   = 2  # Number of successes before healthy
    unhealthy_threshold = 4  # Number of failures before unhealthy

  }

}

# # ALB registration to Target Group
# resource "aws_lb_target_group_attachment" "lb_register_tg" {
#   target_group_arn = aws_lb_target_group.alb_tg_mvp.arn
#   target_id        = aws_instance
#   port             = 80
# }

# ALB Listener Resource
resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.mvp_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb_tg_mvp.arn
  }
}