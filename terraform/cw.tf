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