output "hostname" {
  value       = join("", aws_route53_record.www.*.fqdn)
  description = "DNS hostname"
}