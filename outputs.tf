output "s3_bucket_name" {
  description = "S3 bucket created for random writer"
  value       = aws_s3_bucket.random_bucket.bucket
}

output "lambda_function_name" {
  description = "Lambda function name"
  value       = aws_lambda_function.random_writer.function_name
}
