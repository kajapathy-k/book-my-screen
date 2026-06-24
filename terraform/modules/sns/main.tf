################################################################################
# SNS Topic for BookMyScreen Alerts
################################################################################

resource "aws_sns_topic" "bookmyscreen_alerts" {
  name = "bookmyscreen-alerts"

  tags = {
    Name        = "bookmyscreen-alerts"
    Project     = "BookMyScreen"
    Environment = "Dev"
  }
}

resource "aws_sns_topic_subscription" "email_alert" {
  topic_arn = aws_sns_topic.bookmyscreen_alerts.arn
  protocol  = "email"
  endpoint  = var.alert_email
}