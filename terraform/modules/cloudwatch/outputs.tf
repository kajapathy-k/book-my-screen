output "alarm_name" {
  value = aws_cloudwatch_metric_alarm.asg_high_cpu_alarm.alarm_name
}