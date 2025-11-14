# Terraform Lambda random writer demo

This repo provisions:
- An S3 bucket
- An IAM role and policy for Lambda
- A Python 3.11 Lambda function that writes a random number to S3
- A CloudWatch Events (EventBridge) schedule to run the function every minute

Files:
- `main.tf` - Terraform config
- `lambda/` - Lambda function source

To run locally with Terraform CLI:
1. terraform init
2. terraform apply
# tf-workspace-demo