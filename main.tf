
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.0"
    }
  }
  required_version = ">= 1.5.0"
}

provider "aws" {
  region = var.aws_region
}

resource "aws_s3_bucket" "numbers" {
  bucket = local.bucket_name
  force_destroy = true

  tags = {
    Name = "random-number-bucket"
    ManagedBy = "terraform"
  }
}

resource "random_id" "bucket_suffix" {
  byte_length = 4
}

locals {
  bucket_name = "${var.s3_bucket_prefix}-${random_id.bucket_suffix.hex}"
}

data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "${path.module}/lambda"
  output_path = "${path.module}/build/lambda.zip"
}

resource "aws_iam_role" "lambda_exec" {
  name = "lambda_exec_random_number"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_policy" "lambda_s3_write" {
  name        = "lambda_s3_write_policy"
  description = "Allow lambda to put objects into the numbers bucket and write logs"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:PutObject",
          "s3:PutObjectAcl"
        ],
        Resource = ["${aws_s3_bucket.numbers.arn}/*"]
      },
      {
        Effect = "Allow",
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach_basic" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = aws_iam_policy.lambda_s3_write.arn
}

resource "aws_lambda_function" "random_writer" {
  filename         = data.archive_file.lambda_zip.output_path
  function_name    = "random-number-writer"
  role             = aws_iam_role.lambda_exec.arn
  handler          = "handler.lambda_handler"
  runtime          = "python3.11"
  source_code_hash = filebase64sha256(data.archive_file.lambda_zip.output_path)

  environment {
    variables = {
      BUCKET = aws_s3_bucket.numbers.bucket
    }
  }
}

resource "aws_cloudwatch_event_rule" "every_minute" {
  name                = "every_minute_rule"
  schedule_expression = "rate(1 minute)"
}

resource "aws_cloudwatch_event_target" "lambda_target" {
  rule      = aws_cloudwatch_event_rule.every_minute.name
  target_id = "lambda-target"
  arn       = aws_lambda_function.random_writer.arn
}

resource "aws_lambda_permission" "allow_events" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.random_writer.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.every_minute.arn
}

output "s3_bucket" {
  description = "Name of the S3 bucket that receives number files"
  value       = aws_s3_bucket.numbers.bucket
}
