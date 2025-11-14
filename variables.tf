variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "s3_bucket_name" {
  description = "Name of the S3 bucket to create. If empty, Terraform will generate one with a random suffix."
  type        = string
  default     = ""
}
