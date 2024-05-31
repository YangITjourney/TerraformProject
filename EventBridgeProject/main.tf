provider "aws" {
  region = "us-east-1"
}

resource "aws_sns_topic" "ec2_stop_notice" {
  name = "EC2stopnotice"
}

resource "aws_sns_topic_subscription" "email_subscription" {
  topic_arn = aws_sns_topic.ec2_stop_notice.arn
  protocol  = "email"
  endpoint  = "yiyanghsu@gmail.com"
}

resource "aws_cloudwatch_event_rule" "ec2_stop_rule" {
  name                = "EC2StopRule"
  description         = "Rule for EC2 instance state change to stopping"

  event_pattern = jsonencode(
      {
          "source": ["aws.ec2"],
          "detail-type": ["EC2 Instance State-change Notification"],
          "detail": {
                  "state": ["stopping"]
            }
      })
}

resource "aws_cloudwatch_event_target" "sns_target" {
  target_id = "SnsTarget"
  rule      = aws_cloudwatch_event_rule.ec2_stop_rule.name
  arn       = aws_sns_topic.ec2_stop_notice.arn
    # Input transformer configuration
  input_transformer {
    input_paths = {
      time = "$.time"
      instance = "$.detail.instance-id"
      state = "$.detail.state"
    }
    input_template = "\"Instance <instance> is in <state> at <time>\""
  }

}