
resource "aws_route53_zone" "primary" {
  name = "csepulveda.io"
}

output "prymary_dns_registers" {
  value = aws_route53_zone.primary.name_servers
}
