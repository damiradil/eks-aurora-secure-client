variable "aws_region" {
  type        = string
  description = "AWS region"
  default     = "us-east-2"
}

provider "aws" {
  region  = var.aws_region
  profile = "default"
}


