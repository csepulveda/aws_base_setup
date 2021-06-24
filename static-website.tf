module "aws_static_website" {
  source = "git::https://github.com/csepulveda/terraform-aws-static-website.git"

  website-domain-main     = "csepulveda.io"
  website-domain-redirect = "blog.csepulveda.io"
}
