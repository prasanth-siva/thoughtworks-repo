resource "aws_lb" "Alb" {
  name                       = "Mediawiki-prod-alb"
  internal                   = false
  load_balancer_type         = "application"
  security_groups            = var.security_groups 
  subnets                    = var.subnets
  enable_deletion_protection = false
  ip_address_type            = var.ip_address_type
  tags = merge(
    var.tags,
    {
      "Name" = var.load_balancer_name
    },
  )

 count = var.create_alb ? 1 : 0
 
}

resource "aws_lb_target_group" "main" {
  name     = var.target_groups[count.index]["name"]
  vpc_id   = var.vpc_id
  port     = var.target_groups[count.index]["backend_port"]
  protocol = "HTTP"
  target_type = "instance"


  health_check {
    interval = lookup(
      var.target_groups[count.index],
      "health_check_interval",
      var.target_groups_defaults["health_check_interval"],
    )
    path = lookup(
      var.target_groups[count.index],
      "health_check_path",
      var.target_groups_defaults["health_check_path"],
    )
    port = lookup(
      var.target_groups[count.index],
      "health_check_port",
      var.target_groups_defaults["health_check_port"],
    )
    healthy_threshold = lookup(
      var.target_groups[count.index],
      "health_check_healthy_threshold",
      var.target_groups_defaults["health_check_healthy_threshold"],
    )
    unhealthy_threshold = lookup(
      var.target_groups[count.index],
      "health_check_unhealthy_threshold",
      var.target_groups_defaults["health_check_unhealthy_threshold"],
    )
    timeout = lookup(
      var.target_groups[count.index],
      "health_check_timeout",
      var.target_groups_defaults["health_check_timeout"],
    )
    protocol = upper(
      lookup(
        var.target_groups[count.index],
        "healthcheck_protocol",
        var.target_groups[count.index]["backend_protocol"],
      ),
    )
    matcher = lookup(
      var.target_groups[count.index],
      "health_check_matcher",
      var.target_groups_defaults["health_check_matcher"],
    )
  }

  stickiness {
    type = "lb_cookie"
    cookie_duration = lookup(
      var.target_groups[count.index],
      "cookie_duration",
      var.target_groups_defaults["cookie_duration"],
    )
    enabled = lookup(
      var.target_groups[count.index],
      "stickiness_enabled",
      var.target_groups_defaults["stickiness_enabled"],
    )
  }

  tags = merge(
    var.tags,
    {
      "Name" = var.target_groups[count.index]["name"]
    },
  )

  count      = var.create_alb ? var.target_groups_count : 0

  lifecycle {
    create_before_destroy = true
  }

}  

resource "aws_lb_listener" "frontend_http_tcp" {
  load_balancer_arn = element(
    concat(aws_lb.Alb.*.arn),
    0,
  )
  port     = var.http_tcp_listeners[count.index]["port"]
  protocol = var.http_tcp_listeners[count.index]["protocol"]
  count             = var.create_alb ? var.http_tcp_listeners_count : 0

  default_action {
    target_group_arn = aws_lb_target_group.main[lookup(var.http_tcp_listeners[count.index], "target_group_index", 0)].id
    type             = "forward"
  }
}

resource "aws_lb_listener" "frontend_https" {
  load_balancer_arn = element(
    concat(aws_lb.Alb.*.arn),
    0,
  )
  port            = var.https_listeners[count.index]["port"]
  protocol        = "HTTPS"
  certificate_arn = var.https_listeners[count.index]["certificate_arn"]
  ssl_policy = lookup(
    var.https_listeners[count.index],
    "ssl_policy",
    var.listener_ssl_policy_default,
  )
  count = var.create_alb && var.logging_enabled ? var.https_listeners_count : 0

  default_action {
    target_group_arn = aws_lb_target_group.main[lookup(var.https_listeners[count.index], "target_group_index", 0)].id
    type             = "forward"
  }
}

resource "aws_lb_listener_certificate" "https_listener" {
  listener_arn    = aws_lb_listener.frontend_https[var.extra_ssl_certs[count.index]["https_listener_index"]].arn
  certificate_arn = var.extra_ssl_certs[count.index]["certificate_arn"]
  count           = var.create_alb && var.logging_enabled ? var.extra_ssl_certs_count : 0
}


