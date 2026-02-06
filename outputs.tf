output "s3_bucket_name" {
  description = "Name of the S3 bucket."
  value       = try(module.s3[0].bucket_name, null)
}

output "s3_bucket_arn" {
  description = "ARN of the S3 bucket."
  value       = try(module.s3[0].bucket_arn, null)
}

output "ec2_instance_id" {
  description = "ID of the EC2 instance."
  value       = try(module.ec2[0].instance_id, null)
}

output "ec2_public_ip" {
  description = "Public IP of the EC2 instance (if any)."
  value       = try(module.ec2[0].public_ip, null)
}