Terraform demo: deploy a Lambda that writes a random number to S3 every minute.

Files:
- main.tf, variables.tf, outputs.tf: Terraform configuration
- lambda/: Python lambda handler

To run locally: configure AWS credentials in environment, then:

  terraform init
  terraform apply
# tf-workspace-demo