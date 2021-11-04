provider "aws" {
  region                  = var.AWS_REGION
  shared_credentials_file = "/Users/harshikag/.aws/creds"
  profile                 = var.aws_profile
}