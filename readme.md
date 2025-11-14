# tf-workspace-demo

This demo creates an AWS Lambda that runs every minute, generates a random number, and writes it to an S3 bucket. The project contains Terraform configuration and the Lambda Python code.

How it works:
- Terraform provisions an S3 bucket, IAM role and policy, a Lambda function (packaged locally via the archive provider), and an EventBridge rule that triggers the Lambda every minute.

To run locally:
1. Install Terraform 1.5+.
2. Configure AWS credentials in environment or via a credential helper.
3. terraform init && terraform apply
# tf-workspace-demo