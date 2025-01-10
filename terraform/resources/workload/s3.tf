# module "s3_cf" {
#   source = "../../modules/s3_bucket/v1"

#   bucket_name = var.s3_bucket_name

#   enable_log_bucket = false

#   enable_versioning = true

#   bucket_policy =<<EOT
#   {
#     "Version": "2008-10-17",
#     "Id": "PolicyForCloudFrontPrivateContent",
#     "Statement": [
#         {
#             "Sid": "AllowCloudFrontServicePrincipal",
#             "Effect": "Allow",
#             "Principal": {
#                 "Service": "cloudfront.amazonaws.com"
#             },
#             "Action": "s3:GetObject",
#             "Resource": "arn:aws:s3:::www.kurtwebsitetest.example/*",
#             "Condition": {
#                 "StringEquals": {
#                     "AWS:SourceArn": "arn:aws:cloudfront::609954035002:distribution/E2Z0ULSSCHP4S7"
#                 }
#             }
#         }
#     ]
#     }
#     EOT
# }
