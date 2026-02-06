# terraform-aws-infra

A thin orchestration module with two submodules:

- `modules/s3` – Create an S3 bucket with versioning, encryption (SSE‑S3 or SSE‑KMS), lifecycle transitions (STANDARD_IA / ONEZONE_IA / GLACIER), public access block, optional server access logging, and optional **Object Lock** (GOVERNANCE or COMPLIANCE). [2](https://registry.terraform.io/providers/hashicorp/aws/latest)  

- `modules/ec2` – Create a single EC2 instance with sane defaults, additional EBS volumes, tagging, and optional detailed monitoring. [2](https://registry.terraform.io/providers/hashicorp/aws/latest)


## Requirements

- Terraform `>= 1.6.0`
- AWS Provider `>= 5.0` (this module uses modern S3 resources such as `aws_s3_bucket_*` family and current EC2 arguments). [2](https://registry.terraform.io/providers/hashicorp/aws/latest)

## Usage

See [`examples/basic`](examples/basic/main.tf) and [`examples/complete`](examples/complete/main.tf).

```hcl
module "infra" {
  source  = "aashish72it/aws-infra/aws"
  version = "0.1.0"

  s3_bucket_name = "demo-bucket-1234567890"
  ec2_name          = "demo-ec2"
  ec2_ami_id        = "ami-xxxxxxxx"
  ec2_instance_type = "t3.micro"
  subnet_id         = "subnet-xxxxxxxx"
  sg_ids            = ["sg-xxxxxxxx"]

  tags = {
    Owner = "Aashish"
    Env   = "dev"
  }
}

<pre>

terraform-aws-infra/
├── .github/
│   ├── .tf-module-config.json
│   ├── .tf-module-manifest.json
│   └── workflows/
│       └── aws-tf-module.yml
├── LICENSE
├── README.md
├── main.tf
├── variables.tf
├── outputs.tf
├── versions.tf
├── examples/
│   ├── basic/
│   │   └── main.tf
│   └── complete/
│       └── main.tf
└── modules/
    ├── s3/
    │   ├── main.tf
    │   ├── variables.tf
    │   ├── outputs.tf
    │   └── README.md
    └── ec2/
        ├── main.tf
        ├── variables.tf
        ├── outputs.tf
        └── README.md

</pre>
