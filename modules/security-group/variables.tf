variable "name" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "ssh_cidrs" {
  type = list(string)
}

variable "all_tcp_cidrs" {
  type = list(string)
}
