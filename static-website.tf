module "cloudfront_s3_website_with_domain" {
    source                 = "chgangaraju/cloudfront-s3-website/aws"
    version                = "1.2.2"
    hosted_zone            = "csepulveda.io" 
    domain_name            = "blog.csepulveda.io"
    acm_certificate_domain = "*.csepulveda.io"
    upload_sample_file     = true
}
