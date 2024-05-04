
terraform {
  backend "s3" {
    bucket = "online-retail-terraform-state"
    key    = "global/s3/terraform.tfstate"
    region = "us-east-1"
    dynamo_table = "online-retail-terraform-state"
    encrypt = true
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
}
