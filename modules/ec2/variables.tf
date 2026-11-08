variable "ami_id" {
  type = string
}

variable "instance_count" {
  type = number
}

variable "name_prefix" {
  type = string
}

variable "instance_type" {
  type = string
}

variable "key_name" {
  type = string
}

variable "security_group_ids" {
  type = list(string)
}

variable "root_volume_size" {
  type = number
}
