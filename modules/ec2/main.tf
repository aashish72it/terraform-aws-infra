locals {
  user_data_b64 = var.user_data == null ? null : base64encode(var.user_data)
}

resource "aws_instance" "this" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = var.vpc_security_group_ids
  key_name                    = var.key_name
  iam_instance_profile        = var.iam_instance_profile
  monitoring                  = var.enable_detailed_monitoring
  associate_public_ip_address = var.associate_public_ip
  user_data_base64            = local.user_data_b64

  tags = merge(var.tags, { Name = var.name })

  root_block_device {
    volume_size = var.root_volume_size
    volume_type = var.root_volume_type
  }

  dynamic "ebs_block_device" {
    for_each = var.additional_ebs_volumes
    content {
      device_name           = ebs_block_device.value.device_name
      volume_size           = ebs_block_device.value.size
      volume_type           = try(ebs_block_device.value.type, "gp3")
      iops                  = try(ebs_block_device.value.iops, null)
      throughput            = try(ebs_block_device.value.throughput, null)
      delete_on_termination = try(ebs_block_device.value.delete_on_termination, true)
      encrypted             = try(ebs_block_device.value.encrypted, true)
      kms_key_id            = try(ebs_block_device.value.kms_key_id, null)
    }
  }
}