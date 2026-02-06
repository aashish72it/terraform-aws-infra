# S3 Submodule

Creates an S3 bucket with optional versioning, encryption (SSE-S3 / SSE-KMS), public access block, lifecycle transitions (STANDARD_IA, ONEZONE_IA, GLACIER, etc.), and optional Object Lock (Governance or Compliance).

**Important:** Object Lock must be enabled at **bucket creation** and cannot be disabled later. Changing from disabled → enabled will force a bucket replacement. (See AWS provider docs for S3 resources.) [2](https://registry.terraform.io/providers/hashicorp/aws/latest)