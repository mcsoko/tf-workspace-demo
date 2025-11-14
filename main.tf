terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}


resource "random_string" "suffix" {
  length  = 6
  upper   = false
  special = false
}

variable "aws_region" {
  description = "AWS region to deploy to"
  type        = string
  default     = "us-east-1"
}

resource "aws_s3_bucket" "random_out" {
  bucket = "tf-workspace-demo-random-output-${random_string.suffix.result}"

  lifecycle_rule {
    enabled = true
    expiration {
      days = 30
    }
  }

  versioning {
    enabled = false
  }
}

data "aws_iam_policy_document" "lambda_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "lambda_exec" {
  name               = "lambda_random_writer_role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
}

data "aws_iam_policy_document" "lambda_policy" {
  statement {
    sid    = "S3Put"
    effect = "Allow"
    actions = [
      "s3:PutObject",
      "s3:PutObjectAcl",
      "s3:ListBucket"
    ]
    resources = [
      aws_s3_bucket.random_out.arn,
      "${aws_s3_bucket.random_out.arn}/*"
    ]
  }

  statement {
    sid    = "CloudWatchLogs"
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = ["arn:aws:logs:*:*:log-group:/aws/lambda/*"]
  }
}

resource "aws_iam_policy" "lambda_s3_policy" {
  name        = "lambda_s3_write_policy"
  description = "Allow lambda to put objects into S3 and write logs"

  policy = data.aws_iam_policy_document.lambda_policy.json
}

resource "aws_iam_role_policy_attachment" "attach_policy" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = aws_iam_policy.lambda_s3_policy.arn
}

data "archive_file" "lambda_zip" {
  type        = "zip"
  output_path = "${path.module}/build/random_lambda.zip"
  source_dir  = "${path.module}/lambda"
}

resource "aws_lambda_function" "random_writer" {
  filename         = data.archive_file.lambda_zip.output_path
  function_name    = "random-number-writer"
  role             = aws_iam_role.lambda_exec.arn
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.11"
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  environment {
    variables = {
      BUCKET = aws_s3_bucket.random_out.bucket
    }
  }
}

resource "aws_cloudwatch_event_rule" "every_minute" {
  name                = "every_minute_rule"
  schedule_expression = "rate(1 minute)"
}

resource "aws_cloudwatch_event_target" "lambda_target" {
  rule      = aws_cloudwatch_event_rule.every_minute.name
  target_id = "lambda_random_writer"
  arn       = aws_lambda_function.random_writer.arn
}

resource "aws_lambda_permission" "allow_cloudwatch" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.random_writer.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.every_minute.arn
}

output "lambda_function_name" {
  value = aws_lambda_function.random_writer.function_name
}

output "s3_bucket" {
  value = aws_s3_bucket.random_out.bucket
}
