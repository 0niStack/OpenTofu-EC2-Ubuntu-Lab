variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "ami_id" {
  description = "Ubuntu 24.04 LTS AMI (us-east-1, build 20261023)"
  type        = string
  default     = "ami-0d6dd9e8265d48906"
}

variable "instance_count" {
  description = "Number of VMs to create"
  type        = number
  default     = 3

  validation {
    condition     = var.instance_count >= 1 && var.instance_count <= 10
    error_message = "instance_count must be between 1 and 10."
  }
}

variable "name_prefix" {
  description = "Name prefix, VMs are named <prefix>-1, <prefix>-2, ..."
  type        = string
  default     = "lab"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.medium"
}

variable "root_volume_size" {
  description = "Root volume size in GiB"
  type        = number
  default     = 30
}

variable "key_name" {
  description = "Name of the key pair created in AWS"
  type        = string
  default     = "my-imported-key"
}

variable "public_key_path" {
  description = "Path to the existing public key to import"
  type        = string
  default     = "~/.ssh/id_ed25519.pub"
}

variable "ssh_allowed_cidrs" {
  description = "CIDRs allowed to reach SSH (22)"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "all_tcp_allowed_cidrs" {
  description = "CIDRs allowed to reach all TCP ports (0-65535)"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "tags" {
  description = "Default tags applied to all resources"
  type        = map(string)
  default = {
    ManagedBy = "OpenTofu"
    Project   = "opentofu-ec2-ubuntu"
  }
}
