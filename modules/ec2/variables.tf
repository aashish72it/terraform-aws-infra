variable "name" {
  type        = string
  description = "Name tag for the instance."
}

variable "ami_id" {
  type        = string
  description = "AMI ID to launch."
}

variable "instance_type" {
  type        = string
  description = "Instance type (e.g., t3.small)."
}

variable "subnet_id" {
  type        = string
  description = "Subnet ID."
}

variable "vpc_security_group_ids" {
  type        = list(string)
  description = "Security group IDs."
  default     = []
}

variable "key_name" {
  type        = string
  description = "Key pair name."
  default     = null
}

variable "iam_instance_profile" {
  type        = string
  description = "IAM instance profile name."
  default     = null
}

variable "root_volume_size" {
  type        = number
  description = "Root EBS size (GiB)."
  default     = 30
}

variable "root_volume_type" {
  type        = string
  description = "Root EBS type (e.g., gp3)."
  default     = "gp3"
}

variable "enable_detailed_monitoring" {
  type        = bool
  description = "Enable detailed monitoring."
  default     = false
}

variable "associate_public_ip" {
  type        = bool
  description = "Associate public IP."
  default     = false
}

variable "user_data" {
  type        = string
  description = "User data (raw)."
  default     = null
}

variable "additional_ebs_volumes" {
  description = "Extra EBS volumes to attach."
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

variable "tags" {
  type        = map(string)
  description = "Tags to apply."
  default     = {}
}