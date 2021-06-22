
resource "aws_route53_zone" "primary" {
  name = var.primary_domain_name
}

output "prymary_dns_registers" {
  value = aws_route53_zone.primary.name_servers
}
