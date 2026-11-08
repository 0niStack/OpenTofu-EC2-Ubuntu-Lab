data "aws_vpc" "default" {
  default = true
}

module "key_pair" {
  source = "./modules/key-pair"

  key_name        = var.key_name
  public_key_path = var.public_key_path
}

module "security_group" {
  source = "./modules/security-group"

  name          = "${var.name_prefix}-sg"
  vpc_id        = data.aws_vpc.default.id
  ssh_cidrs     = var.ssh_allowed_cidrs
  all_tcp_cidrs = var.all_tcp_allowed_cidrs
}

module "ec2" {
  source = "./modules/ec2"

  ami_id             = var.ami_id
  instance_count     = var.instance_count
  name_prefix        = var.name_prefix
  instance_type      = var.instance_type
  key_name           = module.key_pair.key_name
  security_group_ids = [module.security_group.id]
  root_volume_size   = var.root_volume_size
}
