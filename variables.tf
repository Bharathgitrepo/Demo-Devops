variable "aws_region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "ap-south-1"
}

variable "project_name" {
  description = "Project / VPC name prefix"
  type        = string
  default     = "dev"
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnets" {
  description = "Public subnet CIDRs (one per AZ)"
  type        = list(string)
  default     = [
    "10.0.1.0/24",
    "10.0.2.0/24",
    "10.0.3.0/24",
  ]
}

variable "private_subnets" {
  description = "Private subnet CIDRs (one per AZ)"
  type        = list(string)
  default     = [
    "10.0.11.0/24",
    "10.0.12.0/24",
    "10.0.13.0/24",
  ]
}

variable "azs" {
  description = "Availability Zones to use"
  type        = list(string)
  default     = [
    "ap-south-1a",
    "ap-south-1b",
    "ap-south-1c",
  ]
}

variable "tags" {
  description = "Global tags"
  type        = map(string)
  default = {
    Environment = "dev"
    Terraform   = "true"
  }
}
