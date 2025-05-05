# Terraform code for AWS Auto Scaling Group

# AWS Launch Template
resource "aws_launch_template" "startup_template" {
  image_id      = data.aws_ami.custom_ami.id
  instance_type = "t2.micro"
  iam_instance_profile {
    name = aws_iam_instance_profile.connectEC2_profile.name
  }
  monitoring {
    enabled = false # Disables detailed monitoring
  }
  network_interfaces {
    associate_public_ip_address = true
    security_groups             = ["${aws_security_group.allow_http.id}"]
  }
  placement {
    availability_zone = var.az
  }
  update_default_version = true
}

# Auto Scaling Group
resource "aws_autoscaling_group" "startup_asg" {
  desired_capacity    = 1
  max_size            = 5
  min_size            = 1
  vpc_zone_identifier = [data.tfe_outputs.network.values.public_subnet[1]]
  launch_template {
    id      = aws_launch_template.startup_template.id
    version = "$Latest"
  }

  target_group_arns = [aws_lb_target_group.alb_tg_mvp.arn]
}
resource "aws_autoscaling_policy" "as_policy" {
  autoscaling_group_name    = aws_autoscaling_group.startup_asg.name
  name                      = "scalingPolicy"
  policy_type               = "TargetTrackingScaling"
  estimated_instance_warmup = 60
  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }

    target_value = 60.0
  }
}