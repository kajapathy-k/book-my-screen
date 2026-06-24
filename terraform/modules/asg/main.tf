################################################################################
# Launch Template - BookMyScreen
################################################################################

resource "aws_launch_template" "bms_launch_template" {
  name_prefix   = "bms-launchtemplate-"
  image_id      = var.ami_id
  instance_type = "t2.micro"
  key_name      = var.key_pair_name

  vpc_security_group_ids = [
    var.application_sg_id
  ]

  monitoring {
    enabled = true
  }

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name        = "bms-instance"
      Project     = "BookMyScreen"
      Environment = "Dev"
    }
  }

  tags = {
    Name        = "bms-launchtemplate"
    Project     = "BookMyScreen"
    Environment = "Dev"
  }
}

################################################################################
# Auto Scaling Group
################################################################################

resource "aws_autoscaling_group" "bms_asg" {

  name = "bms-asg"

  min_size         = 0
  max_size         = 2
  desired_capacity = 0

  health_check_type         = "ELB"
  health_check_grace_period = 300

  vpc_zone_identifier = var.private_subnet_ids

  target_group_arns = [
    var.target_group_arn
  ]

  launch_template {
    id      = aws_launch_template.bms_launch_template.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "bms-asg-instance"
    propagate_at_launch = true
  }

  tag {
    key                 = "Project"
    value               = "BookMyScreen"
    propagate_at_launch = true
  }

  tag {
    key                 = "Environment"
    value               = "Dev"
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }
}

################################################################################
# Target Tracking Scaling Policy
################################################################################

resource "aws_autoscaling_policy" "cpu_target_tracking" {

  name                   = "bms-cpu-target-tracking"
  autoscaling_group_name = aws_autoscaling_group.bms_asg.name

  policy_type = "TargetTrackingScaling"

  target_tracking_configuration {

    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }

    target_value = 50.0

    disable_scale_in = false
  }
}