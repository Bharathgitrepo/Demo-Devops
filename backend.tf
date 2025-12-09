terraform {
  # Make sure you're on a new enough Terraform version
  # S3 native locking is GA in recent 1.10+/1.11+ releases
  required_version = ">= 1.10.0"

  backend "s3" {
    bucket = "dev-terraform-state-bucket"
    key    = "dev/terraform.tfstate"
    region = "ap-south-1"

    encrypt = true

    # ✅ New native S3 locking mechanism
    use_lockfile = true
  }
}
