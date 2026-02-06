locals {
  # convenience flags
  do_s3  = var.create_s3 && var.s3_bucket_name != null
  do_ec2 = var.create_ec2 && var.ec2_name != null && var.ec2_ami_id != null && var.ec2_instance_type != null && var.subnet_id != null
}

# S3
module "s3" {
  count  = local.do_s3 ? 1 : 0
  source = "./modules/s3"

  bucket_name           = var.s3_bucket_name
  tags                  = var.tags
  versioning_enabled    = var.s3_versioning
  public_access_block   = var.s3_public_access_block
  encryption            = var.s3_encryption
  lifecycle_rules       = var.s3_lifecycle_rules
  logging               = var.s3_logging
  object_lock           = var.s3_object_lock
  object_ownership      = var.s3_object_ownership
  acl                   = var.s3_acl
}

# EC2
module "ec2" {
  count  = local.do_ec2 ? 1 : 0
  source = "./modules/ec2"

  name                   = var.ec2_name
  ami_id                 = var.ec2_ami_id
  instance_type          = var.ec2_instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = var.sg_ids
  key_name               = var.key_name
  iam_instance_profile   = var.iam_instance_profile
  root_volume_size       = var.root_volume_size
  root_volume_type       = var.root_volume_type
  enable_detailed_monitoring = var.enable_detailed_monitoring
  associate_public_ip    = var.associate_public_ip
  user_data              = var.user_data
  additional_ebs_volumes = var.additional_ebs_volumes
  tags                   = var.tags
}