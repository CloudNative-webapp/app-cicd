variable "AWS_REGION" {
  description = "Aws region"
  type        = string
}

variable "domainName" {
  description = "Domain name"
  type        = string
}

variable "aws_profile" {
  description = "Aws profile"
  type        = string
}

variable "username_iam" {
  description = "Aws user name"
  type        = string
}

variable "AWS_ACCOUNT_ID" {
  description = "Aws account ID"
  type        = string
}

variable "S3_BucketName" {
  description = "S3 Bucket Name"
  type        = string
}

variable "CODE_DEPLOY_APPLICATION_NAME" {
  description = "code deploy application name"
  type        = string
}

variable "s3bucketNameImage" {
  description = "S3 Bucket Name image"
  type        = string
}