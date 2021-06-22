module "aws_static_website" {
  source = "cloudmaniac/static-website/aws"

  website-domain-main     = "csepulveda.io"
  website-domain-redirect = "blog.csepulveda.io"
}
