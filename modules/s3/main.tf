locals {
  use_kms     = try(var.encryption.type, "SSE-S3") == "SSE-KMS"
  kms_key_id  = try(var.encryption.key_id, null)
}

resource "aws_s3_bucket" "this" {
  bucket = var.bucket_name

  # Object lock can only be set at bucket creation. Changing from false->true forces recreation.
  # Some AWS API semantics require this to be explicitly true when needed.
  object_lock_enabled = var.object_lock.enabled ? true : null

  tags = var.tags
}

# Object ownership / ACL
resource "aws_s3_bucket_ownership_controls" "this" {
  bucket = aws_s3_bucket.this.id
  rule {
    object_ownership = var.object_ownership
  }
}

resource "aws_s3_bucket_acl" "this" {
  count  = var.acl != null ? 1 : 0
  bucket = aws_s3_bucket.this.id
  acl    = var.acl

  depends_on = [aws_s3_bucket_ownership_controls.this]
}

# Public access block
resource "aws_s3_bucket_public_access_block" "this" {
  bucket                  = aws_s3_bucket.this.id
  block_public_acls       = try(var.public_access_block.block_public_acls, true)
  block_public_policy     = try(var.public_access_block.block_public_policy, true)
  ignore_public_acls      = try(var.public_access_block.ignore_public_acls, true)
  restrict_public_buckets = try(var.public_access_block.restrict_public_buckets, true)
}

# Versioning
resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.this.id
  versioning_configuration {
    status = var.versioning_enabled ? "Enabled" : "Suspended"
  }
}

# Encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  bucket = aws_s3_bucket.this.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = local.use_kms ? "aws:kms" : "AES256"
      kms_master_key_id = local.use_kms ? local.kms_key_id : null
    }
    bucket_key_enabled = local.use_kms ? true : null
  }
}

# Logging (optional)
resource "aws_s3_bucket_logging" "this" {
  count  = var.logging == null ? 0 : 1
  bucket = aws_s3_bucket.this.id

  target_bucket = var.logging.target_bucket
  target_prefix = try(var.logging.target_prefix, "")
}

# Lifecycle rules (optional)
resource "aws_s3_bucket_lifecycle_configuration" "this" {
  count  = length(var.lifecycle_rules) > 0 ? 1 : 0
  bucket = aws_s3_bucket.this.id

  dynamic "rule" {
    for_each = var.lifecycle_rules
    content {
      id     = rule.value.id
      status = rule.value.enabled ? "Enabled" : "Disabled"

      dynamic "filter" {
        for_each = rule.value.filter == null ? [] : [rule.value.filter]
        content {
          prefix = try(filter.value.prefix, null)

          dynamic "and" {
            for_each = (try(filter.value.tags, null) != null && try(filter.value.prefix, null) != null) ? [1] : []
            content {
              prefix = try(filter.value.prefix, null)
              tags   = try(filter.value.tags, null)
            }
          }

          # If only tags provided (no prefix)
          dynamic "tag" {
            for_each = (try(filter.value.tags, null) != null && try(filter.value.prefix, null) == null) ? [for k, v in filter.value.tags : { key = k, value = v }] : []
            content {
              key   = tag.value.key
              value = tag.value.value
            }
          }
        }
      }

      dynamic "transition" {
        for_each = try(rule.value.transitions, [])
        content {
          days          = transition.value.days
          storage_class = transition.value.storage_class
        }
      }

      dynamic "noncurrent_version_transition" {
        for_each = try(rule.value.noncurrent_version_transitions, [])
        content {
          noncurrent_days = noncurrent_version_transition.value.days
          storage_class   = noncurrent_version_transition.value.storage_class
        }
      }

      dynamic "expiration" {
        for_each = rule.value.expiration == null ? [] : [rule.value.expiration]
        content {
          days = try(expiration.value.days, null)
        }
      }
    }
  }
}

# Object lock configuration (optional; requires bucket enablement at creation)
resource "aws_s3_bucket_object_lock_configuration" "this" {
  count  = var.object_lock.enabled ? 1 : 0
  bucket = aws_s3_bucket.this.id

  rule {
    default_retention {
      mode  = var.object_lock.mode
      days  = try(var.object_lock.days, null)
      years = try(var.object_lock.years, null)
    }
  }
}