resource "aws_acm_certificate" "blog" {
  domain_name       = "blog.${var.primary_domain_name}"
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}
