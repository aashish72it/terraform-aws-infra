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

  # S3 advanced
  s3_bucket_name = "prod-artifacts"
  s3_versioning  = true
  s3_public_access_block = {
    block_public_acls       = true
    block_public_policy     = true
    ignore_public_acls      = true
    restrict_public_buckets = true
  }
  s3_encryption = {
    type   = "SSE-KMS"
    key_id = "alias/ak-org-kms"
  }
  s3_object_lock = {
    enabled = true
    mode    = "GOVERNANCE"
    days    = 7
  }
  s3_lifecycle_rules = [
    {
      id      = "transitions"
      enabled = true
      filter  = { prefix = "" }
      transitions = [
        { days = 30,  storage_class = "STANDARD_IA" },
        { days = 120, storage_class = "GLACIER" }
      ]
      expiration = { days = 730 }
    }
  ]
  s3_logging = {
    target_bucket = "ak-central-logs"
    target_prefix = "s3/ak-prod-artifacts-123456/"
  }
  s3_object_ownership = "BucketOwnerEnforced"

  # EC2 advanced
  ec2_name                = "ak-bastion"
  ec2_ami_id              = "ami-0c02fb55956c7d316"
  ec2_instance_type       = "t3.small"
  subnet_id               = "subnet-xxxxxxxx"
  sg_ids                  = ["sg-xxxxxxxx"]
  key_name                = "ak-key"
  iam_instance_profile    = "EC2-SSM-Managed"
  enable_detailed_monitoring = true
  associate_public_ip     = true
  user_data               = <<-EOT
    #cloud-config
    packages:
      - htop
      - jq
  EOT
  additional_ebs_volumes = [
    {
      device_name = "/dev/xvdb"
      size        = 50
      type        = "gp3"
      throughput  = 125
    }
  ]

  tags = {
    Owner            = "Aashish"
    Env              = "prod"
    DataClassification = "Internal"
    CostCenter       = "1234"
  }
}