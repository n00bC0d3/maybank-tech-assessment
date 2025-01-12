module "cdn" {
  source = "../../modules/cloudfront"

  aliases = []

  comment             = "My awesome CloudFront"
  enabled             = true
  is_ipv6_enabled     = true
  price_class         = "PriceClass_All"
  retain_on_delete    = false
  wait_for_deployment = false

  create_origin_access_identity = true
  origin_access_identities = {
    s3_bucket_one = "My awesome CloudFront can access"
  }

  # logging_config = {
  #   bucket = "logs-my-cdn.s3.amazonaws.com"
  # }

  origin = {
    nlb_pub_origin = {
      domain_name = module.nlb_public.lb_dns_name
      custom_origin_config = {
        http_port              = 80
        https_port             = 443
        origin_protocol_policy = "http-only" 
        origin_ssl_protocols   = ["TLSv1", "TLSv1.1", "TLSv1.2"]
      }
    }

    s3_one = {
      # domain_name = "${module.s3_cf.bucket_name}.${var.region}.amazonaws.com"
      domain_name = "${var.s3_bucket_name}.s3.${var.region}.amazonaws.com"

      s3_origin_config = {
        origin_access_identity = "s3_bucket_one"
      }
    }

  }

#  # BONUS !! If you want to restrict your viewer based on geolocation !
#   geo_restriction = {
#       locations        = [
#         "ID",
#          "MY",
#          "SG",
#       ]
#       restriction_type = "whitelist" 
#   }

  default_cache_behavior = {
    target_origin_id           = "nlb_pub_origin"
    viewer_protocol_policy     = "allow-all"

    allowed_methods = ["GET", "HEAD", "OPTIONS"]
    cached_methods  = ["GET", "HEAD"]
    compress        = true
    query_string    = true
  }

  ordered_cache_behavior = [
    {
      path_pattern           = "/static/*"
      target_origin_id       = "s3_one"
      viewer_protocol_policy = "redirect-to-https"

      allowed_methods = ["GET", "HEAD", "OPTIONS"]
      cached_methods  = ["GET", "HEAD"]
      compress        = true
      query_string    = true
    }
  ]
  
  # viewer_certificate = {
  #   acm_certificate_arn = "arn:aws:acm:us-east-1:135367859851:certificate/1032b155-22da-4ae0-9f69-e206f825458b"
  #   ssl_support_method  = "sni-only"
  # }
}