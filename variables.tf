variable "aws_region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "us-east-1"
}

variable "s3_bucket_prefix" {
  description = "Prefix used to build the S3 bucket name"
  type        = string
  default     = "tf-demo-random-numbers"
}
