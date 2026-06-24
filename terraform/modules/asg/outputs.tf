output "asg_name" {
  value = aws_autoscaling_group.bms_asg.name
}

output "launch_template_id" {
  value = aws_launch_template.bms_launch_template.id
}