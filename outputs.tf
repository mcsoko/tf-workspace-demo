output "bucket_id" {
  description = "The name of the created S3 bucket"
  value       = aws_s3_bucket.this.id
}

output "lambda_name" {
  description = "The name of the writer lambda"
  value       = aws_lambda_function.writer.function_name
}
