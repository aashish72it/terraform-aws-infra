variable "create_s3" {
  description = "Create the S3 bucket submodule."
  type        = bool
  default     = true
}

variable "create_ec2" {
  description = "Create the EC2 submodule."
  type        = bool
  default     = true
}

# ---------- Common ----------
variable "tags" {
  description = "Tags to apply to all resources created by submodules."
  type        = map(string)
  default     = {}
}

# ---------- S3 (passed through) ----------
variable "s3_bucket_name" {
  description = "Global unique bucket name."
  type        = string
  default     = null
}

variable "s3_versioning" {
  description = "Enable bucket versioning."
  type        = bool
  default     = true
}

variable "s3_public_access_block" {
  description = "Public access block settings."
  type = object({
    block_public_acls       = optional(bool, true)
    block_public_policy     = optional(bool, true)
    ignore_public_acls      = optional(bool, true)
    restrict_public_buckets = optional(bool, true)
  })
  default = {}
}

variable "s3_encryption" {
  description = <<EOT
Server-side encryption configuration:
  type: "SSE-S3" or "SSE-KMS"
  key_id: required if type == "SSE-KMS" (KMS key ID or alias)
EOT
  type = object({
    type   = optional(string, "SSE-S3")
    key_id = optional(string)
  })
  default = {}
}

variable "s3_object_lock" {
  description = <<EOT
Object Lock configuration:
  enabled = true|false
  mode    = "GOVERNANCE" or "COMPLIANCE"
  days    = optional(number)
  years   = optional(number)
NOTE: Enabling Object Lock requires setting it at bucket creation and cannot be disabled later.
EOT
  type = object({
    enabled = bool
    mode    = optional(string)
    days    = optional(number)
    years   = optional(number)
  })
  default = {
    enabled = false
  }
}

variable "s3_lifecycle_rules" {
  description = <<EOT
List of lifecycle rules. Each rule example:
{
  id      = "transition-to-ia"
  enabled = true
  filter  = { prefix = "" } # or { tags = { "key" = "value" } }
  transitions = [
    { days = 30, storage_class = "STANDARD_IA" },
    { days = 90, storage_class = "GLACIER" }
  ]
  noncurrent_version_transitions = [
    { days = 30, storage_class = "STANDARD_IA" }
  ]
  expiration = { days = 365 }
}
EOT
  type = list(object({
    id      = string
    enabled = bool
    filter  = optional(object({
      prefix = optional(string)
      tags   = optional(map(string))
    }))
    transitions = optional(list(object({
      days          = number
      storage_class = string
    })), [])
    noncurrent_version_transitions = optional(list(object({
      days          = number
      storage_class = string
    })), [])
    expiration = optional(object({
      days = optional(number)
    }))
  }))
  default = []
}

variable "s3_logging" {
  description = "Access logging configuration for the S3 bucket."
  type = object({
    target_bucket = string
    target_prefix = optional(string, "")
  })
  default = null
}

variable "s3_object_ownership" {
  description = "S3 Object Ownership: BucketOwnerEnforced (default), BucketOwnerPreferred, ObjectWriter."
  type        = string
  default     = "BucketOwnerEnforced"
  validation {
    condition     = contains(["BucketOwnerEnforced", "BucketOwnerPreferred", "ObjectWriter"], var.s3_object_ownership)
    error_message = "Invalid object ownership."
  }
}

variable "s3_acl" {
  description = "Optional canned ACL (only if not using BucketOwnerEnforced). Example: private, log-delivery-write."
  type        = string
  default     = null
}

# ---------- EC2 (passed through) ----------
variable "ec2_name" {
  type        = string
  description = "Name tag for the instance."
  default     = null
}

variable "ec2_ami_id" {
  type        = string
  description = "AMI ID for the instance."
  default     = null
}

variable "ec2_instance_type" {
  type        = string
  description = "Instance type (e.g., t3.small)."
  default     = null
}

variable "subnet_id" {
  type        = string
  description = "Subnet ID for the instance."
  default     = null
}

variable "sg_ids" {
  type        = list(string)
  description = "List of security group IDs."
  default     = []
}

variable "key_name" {
  type        = string
  description = "EC2 key pair name."
  default     = null
}

variable "iam_instance_profile" {
  type        = string
  description = "IAM instance profile name to attach."
  default     = null
}

variable "root_volume_size" {
  type        = number
  description = "Root EBS volume size (GiB)."
  default     = 30
}

variable "root_volume_type" {
  type        = string
  description = "Root EBS volume type (e.g., gp3)."
  default     = "gp3"
}

variable "enable_detailed_monitoring" {
  type        = bool
  description = "Enable detailed monitoring."
  default     = false
}

variable "associate_public_ip" {
  type        = bool
  description = "Associate a public IP address."
  default     = false
}

variable "user_data" {
  type        = string
  description = "Cloud-init/User data (raw)."
  default     = null
}

variable "additional_ebs_volumes" {
  description = "Additional EBS volumes to attach."
  type = list(object({
    device_name = string
    size        = number
    type        = optional(string, "gp3")
    iops        = optional(number)
    throughput  = optional(number)
    delete_on_termination = optional(bool, true)
    encrypted   = optional(bool, true)
    kms_key_id  = optional(string)
  }))
  default = []
}