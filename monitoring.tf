variable "alert_email" {
  description = "Email address for CloudWatch alarm notifications"
  type        = string
}

resource "aws_sns_topic" "alerts" {
  name = "aws-infra-portfolio-alerts"

  tags = {
    Name = "aws-infra-portfolio-alerts"
  }
}

resource "aws_sns_topic_subscription" "email" {
  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "email"
  endpoint  = var.alert_email
}

resource "aws_cloudwatch_metric_alarm" "alb_unhealthy_hosts" {
  alarm_name          = "aws-infra-portfolio-alb-unhealthy-hosts"
  alarm_description   = "ALB target group has one or more unhealthy targets"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  threshold           = 1
  metric_name         = "UnHealthyHostCount"
  namespace           = "AWS/ApplicationELB"
  period              = 60
  statistic           = "Maximum"

  dimensions = {
    LoadBalancer = aws_lb.main.arn_suffix
    TargetGroup  = aws_lb_target_group.app.arn_suffix
  }

  treat_missing_data = "notBreaching"

  alarm_actions = [
    aws_sns_topic.alerts.arn
  ]

  ok_actions = [
    aws_sns_topic.alerts.arn
  ]

  tags = {
    Name = "aws-infra-portfolio-alb-unhealthy-hosts"
  }
}