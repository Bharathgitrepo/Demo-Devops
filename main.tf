provider "aws" {
  region = "ap-south-1"
}

resource "aws_s3_bucket" "demo_bucket" {
  bucket = "bharath-demo-bucket-unique-anil"
}

resource "aws_s3_bucket_versioning" "demo_versioning" {
  bucket = aws_s3_bucket.demo_bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}
