terraform {
  required_providers {
    aws = { source = "hashicorp/aws", version = ">= 5.0" }
    random = { source = "hashicorp/random", version = ">= 3.0" }
    archive = { source = "hashicorp/archive", version = ">= 2.0" }
  }
}

provider "aws" {
  region = var.region
}

resource "random_id" "bucket_suffix" {
  byte_length = 4
}

resource "aws_s3_bucket" "this" {
  bucket = lower("${var.bucket_name_prefix}${random_id.bucket_suffix.hex}")

  tags = {
    Name = "tf-workspace-demo"
    Env  = "demo"
  }
}

resource "aws_s3_bucket_public_access_block" "this" {
  bucket = aws_s3_bucket.this.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}