# To get information about an AWS Cloudwatch Log Group

data "aws_cloudwatch_log_group" "startup" {
  name = "/startup/app"
}

# CloudWatch Log Metric Filter resource
resource "aws_cloudwatch_log_metric_filter" "log_metric" {
  name           = "startup_log_metric"
  pattern        = "\"PUT /media/user_images/\""
  log_group_name = data.aws_cloudwatch_log_group.startup.name

  metric_transformation {
    name      = "UploadCount"
    namespace = "StartupApp"
    value     = "1"
    unit      = "Count"
  }
}
# Provides a CloudWatch Metric Alarm resource for EC2
resource "aws_cloudwatch_metric_alarm" "startup_ec2_cpu" {
  alarm_name                = "ec2-cpu-threshold"
  comparison_operator       = "GreaterThanThreshold"
  evaluation_periods        = 2
  metric_name               = "CPUUtilization"
  namespace                 = "AWS/EC2"
  period                    = 120
  statistic                 = "Average"
  threshold                 = 70
  alarm_actions             = [aws_sns_topic.email_notification.arn]
  ok_actions                = [aws_sns_topic.email_notification.arn]
  alarm_description         = "This metric monitors EC2 cpu utilization"
  insufficient_data_actions = []
}

resource "aws_cloudwatch_metric_alarm" "startup_ec2_mem" {
  alarm_name                = "ec2-memory-threshold"
  comparison_operator       = "GreaterThanThreshold"
  evaluation_periods        = 2
  metric_name               = "MEM_USAGE_PERCENT"
  namespace                 = "CWAgent"
  period                    = 120
  statistic                 = "Average"
  threshold                 = 70
  alarm_actions             = [aws_sns_topic.email_notification.arn]
  ok_actions                = [aws_sns_topic.email_notification.arn]
  alarm_description         = "This metric monitors EC2 memory utilization"
  insufficient_data_actions = []
}

resource "aws_cloudwatch_metric_alarm" "startup_rds_cpu" {
  alarm_name                = "rds-cpu-threshold"
  comparison_operator       = "GreaterThanThreshold"
  evaluation_periods        = 2
  metric_name               = "CPUUtilization"
  namespace                 = "AWS/RDS"
  period                    = 120
  statistic                 = "Average"
  threshold                 = 70
  alarm_actions             = [aws_sns_topic.email_notification.arn]
  ok_actions                = [aws_sns_topic.email_notification.arn]
  alarm_description         = "This metric monitors RDS CPU utilization"
  insufficient_data_actions = []
}

# Provides an SNS topic resource
resource "aws_sns_topic" "email_notification" {
  name = "email-notification-topic"
}