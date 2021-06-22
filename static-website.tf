module "cloudfront_s3_website_with_domain" {
  source                 = "chgangaraju/cloudfront-s3-website/aws"
  version                = "1.2.2"
  hosted_zone            = var.primary_domain_name
  domain_name            = "blog.${var.primary_domain_name}"
  acm_certificate_domain = aws_acm_certificate.blog.domain_name
  upload_sample_file     = true
}
