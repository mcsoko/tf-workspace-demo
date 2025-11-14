output "lambda_function_name" {
  description = "Lambda function name"
  value       = aws_lambda_function.random_writer.function_name
}
