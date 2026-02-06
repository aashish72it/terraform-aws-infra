terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

module "infra" {
  source = "../../"

  # S3
  s3_bucket_name = "demo-bucket"
  s3_versioning  = true

  # EC2
  ec2_name          = "demo-ec2"
  ec2_ami_id        = "ami-0c02fb55956c7d316"
  ec2_instance_type = "t3.micro"
  subnet_id         = "subnet-xxxxxxxx"
  sg_ids            = ["sg-xxxxxxxx"]

  tags = {
    Owner = "Aashish"
    Env   = "dev"
  }
}