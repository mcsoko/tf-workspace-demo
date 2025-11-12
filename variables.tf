variable "region" {
  description = "AWS region to create the bucket in"
  type        = string
  default     = "us-east-1"
}

variable "bucket_name_prefix" {
  description = "Prefix for the random bucket name"
  type        = string
  default     = "tf-ws-demo-"
}
