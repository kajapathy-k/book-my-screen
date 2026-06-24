################################################################################
# CloudWatch Alarm for ASG CPU Utilization
################################################################################

resource "aws_cloudwatch_metric_alarm" "asg_high_cpu_alarm" {
  alarm_name          = "bookmyscreen-asg-high-cpu-alert"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 300
  statistic           = "Average"
  threshold           = 50

  alarm_description = "Send SNS notification when ASG CPU exceeds 50%"

  dimensions = {
    AutoScalingGroupName = var.asg_name
  }

  alarm_actions = [
    var.sns_topic_arn
  ]

  tags = {
    Name        = "bookmyscreen-asg-high-cpu-alert"
    Project     = "BookMyScreen"
    Environment = "Dev"
  }
}