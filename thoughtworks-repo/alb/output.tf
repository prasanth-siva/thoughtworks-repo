output "dns_name" {
  description = "The DNS name of the load balancer."
  value = element(
    concat(
      aws_lb.Alb.*.dns_name,
      [""],
    ),
    0,
  )
}

output "load_balancer_id" {
  description = "The ID and ARN of the load balancer we created."
  value = element(
    concat(
      aws_lb.Alb.*.id,
      [""],
    ),
    0,
  )
}

output "target_group_arns" {
  description = "ARNs of the target groups. Useful for passing to your Auto Scaling group."
  value = concat(aws_lb_target_group.main.*.arn, [""])[0]
}

output "target_group_arns2" {
  description = "ARNs of the target groups. Useful for passing to your Auto Scaling group."
  value = concat(aws_lb_target_group.main.*.arn, [""])[1]
}

output "target_group_names" {
  description = "Name of the target group. Useful for passing to your CodeDeploy Deployment Group."
  value = concat(aws_lb_target_group.main.*.name)
}


output "http_tcp_listener_arns" {
  description = "The ARN of the TCP and HTTP load balancer listeners created."
  value = slice(
    concat(
      aws_lb_listener.frontend_http_tcp.*.arn,
    ),
    0,
    var.http_tcp_listeners_count,
  )
}

output "https_tcp_listener_ids" {
  value = slice(
    concat(
      aws_lb_listener.frontend_https.*.id,
    ),
    0,
    var.https_listeners_count,
  )
}

output "http_tcp_listener_ids" {
  depends_on  = [aws_lb_listener.frontend_https, aws_lb_listener.frontend_https_no_logs, ]
  description = "The IDs of the TCP and HTTP load balancer listeners created."
  value = slice(
    concat(
      aws_lb_listener.frontend_http_tcp.*.id,
    ),
    0,
    var.http_tcp_listeners_count,
  )
}

