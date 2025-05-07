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
  alarm_name                = "EC2-CPUUtilization"
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
  alarm_name                = "EC2-MemoryUsage"
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
  alarm_name                = "RDS-CPUUtilization"
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
# Provides a CloudWatch Dashboard resource
resource "aws_cloudwatch_dashboard" "startup_dashboard" {
  dashboard_name = "my-dashboard"

  dashboard_body = jsonencode({
    "widgets" : [
      {
        "height" : 6,
        "width" : 6,
        "y" : 0,
        "x" : 6,
        "type" : "metric",
        "properties" : {
          "view" : "gauge",
          "metrics" : [
            ["CWAgent", "MEM_USAGE_PERCENT", "InstanceId", "i-0c3955ed1a09a7352", "AutoScalingGroupName", "terraform-20250401173614910900000001", "ImageId", "ami-0edccc416bb0405e8", "InstanceType", "t2.micro"]
          ],
          "region" : "eu-west-1",
          "yAxis" : {
            "left" : {
              "min" : 1,
              "max" : 100
            }
          },
          "title" : "EC2-MEM_USAGE_PERCENT"
        }
      },
      {
        "height" : 6,
        "width" : 12,
        "y" : 5,
        "x" : 12,
        "type" : "metric",
        "properties" : {
          "sparkline" : true,
          "view" : "timeSeries",
          "metrics" : [
            ["AWS/ApplicationELB", "RequestCount", "LoadBalancer", "app/mvp-alb/8df537cbd1c7a66b", { "region" : "eu-west-1" }],
            [".", "ConsumedLCUs", ".", ".", { "region" : "eu-west-1" }]
          ],
          "region" : "eu-west-1",
          "stacked" : false,
          "setPeriodToTimeRange" : false,
          "liveData" : false,
          "period" : 300,
          "title" : "ALB- ConsumedLCUs, RequestCount"
        }
      },
      {
        "height" : 6,
        "width" : 6,
        "y" : 0,
        "x" : 0,
        "type" : "metric",
        "properties" : {
          "metrics" : [
            ["AWS/EC2", "CPUUtilization", { "visible" : false, "region" : "eu-west-1" }],
            [".", ".", "InstanceId", "i-0c3955ed1a09a7352", { "region" : "eu-west-1" }]
          ],
          "view" : "timeSeries",
          "stacked" : false,
          "region" : "eu-west-1",
          "period" : 300,
          "stat" : "Average",
          "title" : "EC2-CPUUtilization"
        }
      },
      {
        "height" : 5,
        "width" : 12,
        "y" : 0,
        "x" : 12,
        "type" : "metric",
        "properties" : {
          "view" : "singleValue",
          "stacked" : false,
          "metrics" : [
            ["AWS/AutoScaling", "GroupInServiceCapacity", "AutoScalingGroupName", "terraform-20250401173614910900000001", { "region" : "eu-west-1" }]
          ],
          "region" : "eu-west-1",
          "period" : 300,
          "yAxis" : {
            "left" : {
              "min" : 1,
              "max" : 5
            }
          },
          "title" : "ASG-GroupInServiceCapacity"
        }
      },
      {
        "type" : "metric",
        "x" : 0,
        "y" : 6,
        "width" : 12,
        "height" : 5,
        "properties" : {
          "view" : "singleValue",
          "stacked" : false,
          "metrics" : [
            ["AWS/RDS", "CPUUtilization", "DBInstanceIdentifier", "terraform-20241125065503498700000004", { "period" : 60 }],
            [".", "DatabaseConnections", ".", ".", { "period" : 60 }],
            [".", "FreeableMemory", ".", ".", { "period" : 60 }],
            [".", "FreeStorageSpace", ".", ".", { "period" : 60 }]
          ],
          "region" : "eu-west-1",
          "title" : "RDS- CPUUtilization, DatabaseConnections, FreeStorageSpace, FreeableMemory"
        }
      }
    ]
  })
}