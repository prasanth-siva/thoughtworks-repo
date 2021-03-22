resource "aws_autoscaling_group" "autoscaling_group" { 
  name = var.name
  min_size = var.min_size
  max_size = var.max_size
  desired_capacity = var.desired_capacity
  protect_from_scale_in = var.protect_scalein
  default_cooldown = var.cooldown
  launch_template {
    id      = var.launch_template_id
    version = "$Latest"
  }
  vpc_zone_identifier = [var.az1, var.az2]
  health_check_grace_period = 60
  tags = var.tags
  termination_policies = [var.termination_policies]
  provisioner "local-exec" {
    when = destroy
    command = "sudo pip install --upgrade s3transfer botocore boto3 awscli >> /dev/null"
    on_failure = "continue"
  }
  provisioner "local-exec" {
    when = destroy
    command = "aws configure set region us-east-1 && aws autoscaling update-auto-scaling-group --auto-scaling-group-name ${self.name} --min-size 0 --max-size 0 --desired-capacity 0 >> /tmp/$ASG_NAME.log && INSTANCES=$(aws autoscaling describe-auto-scaling-groups --auto-scaling-group-names ${self.name} --query 'AutoScalingGroups[*].Instances[*].InstanceId' --output text) && aws autoscaling set-instance-protection --instance-ids $INSTANCES --auto-scaling-group-name ${self.name} --no-protected-from-scale-in >> /tmp/$ASG_NAME.log"
    on_failure = "continue"
  }
  lifecycle {
    ignore_changes = [
      desired_capacity, min_size, max_size,
    ]          
 }
}

resource "aws_autoscaling_policy" "scaling_policy" {
  # ... other configuration ...

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }

    target_value = 60.0
  }

  target_tracking_configuration {
    customized_metric_specification {
      metric_dimension {
        name  = "CPU"
        value = "CPU"
      }

      metric_name = "AVGCPU"
      namespace   = "AVGCPU"
      statistic   = "Average"
    }

    target_value = 60.0
  }
}

output "autoscaling_group_arn" {
  value = aws_autoscaling_group.autoscaling_group.arn
}

output "autoscaling_group_name" {
  value = aws_autoscaling_group.autoscaling_group.name
}