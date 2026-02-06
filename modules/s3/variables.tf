variable "bucket_name" {
  type        = string
  description = "Globally unique bucket name."
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply."
  default     = {}
}

variable "versioning_enabled" {
  type        = bool
  description = "Enable bucket versioning."
  default     = true
}

variable "public_access_block" {
  description = "Public access block settings."
  type = object({
    block_public_acls       = optional(bool, true)
    block_public_policy     = optional(bool, true)
    ignore_public_acls      = optional(bool, true)
    restrict_public_buckets = optional(bool, true)
  })
  default = {}
}

variable "encryption" {
  description = "Server-side encryption config (SSE-S3 or SSE-KMS)."
  type = object({
    type   = optional(string, "SSE-S3")
    key_id = optional(string)
  })
  default = {}
  validation {
    condition     = var.encryption.type == null || contains(["SSE-S3", "SSE-KMS"], var.encryption.type)
    error_message = "encryption.type must be SSE-S3 or SSE-KMS."
  }
  validation {
    condition     = !(try(var.encryption.type, "SSE-S3") == "SSE-KMS" && try(var.encryption.key_id, "") == "")
    error_message = "encryption.key_id is required when encryption.type is SSE-KMS."
  }
}

variable "lifecycle_rules" {
  description = "Lifecycle rules array."
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

variable "logging" {
  description = "Access logging target (bucket must exist)."
  type = object({
    target_bucket = string
    target_prefix = optional(string, "")
  })
  default = null
}

variable "object_lock" {
  description = "Object Lock configuration."
  type = object({
    enabled = bool
    mode    = optional(string)
    days    = optional(number)
    years   = optional(number)
  })
  default = {
    enabled = false
  }
  validation {
    condition     = var.object_lock.enabled == false || (var.object_lock.mode != null && contains(["GOVERNANCE", "COMPLIANCE"], var.object_lock.mode))
    error_message = "object_lock.mode must be GOVENANCE or COMPLIANCE when enabled."
  }
  validation {
    condition     = var.object_lock.enabled == false || ( (try(var.object_lock.days, null) != null) != (try(var.object_lock.years, null) != null) ? true : true )
    error_message = "Specify either 'days' or 'years' for default retention (optional)."
  }
}

variable "object_ownership" {
  description = "Object ownership mode (BucketOwnerEnforced, BucketOwnerPreferred, ObjectWriter)."
  type        = string
  default     = "BucketOwnerEnforced"
  validation {
    condition     = contains(["BucketOwnerEnforced", "BucketOwnerPreferred", "ObjectWriter"], var.object_ownership)
    error_message = "Invalid object ownership setting."
  }
}

variable "acl" {
  description = "Optional canned ACL (only valid when not using BucketOwnerEnforced)."
  type        = string
  default     = null
}