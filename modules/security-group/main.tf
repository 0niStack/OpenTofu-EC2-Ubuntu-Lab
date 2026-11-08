resource "aws_security_group" "this" {
  name        = var.name
  description = "SSH and all TCP ports"
  vpc_id      = var.vpc_id

  tags = {
    Name = var.name
  }
}

resource "aws_vpc_security_group_ingress_rule" "ssh" {
  for_each = toset(var.ssh_cidrs)

  security_group_id = aws_security_group.this.id
  description       = "SSH"
  cidr_ipv4         = each.value
  ip_protocol       = "tcp"
  from_port         = 22
  to_port           = 22
}

resource "aws_vpc_security_group_ingress_rule" "all_tcp" {
  for_each = toset(var.all_tcp_cidrs)

  security_group_id = aws_security_group.this.id
  description       = "All TCP ports"
  cidr_ipv4         = each.value
  ip_protocol       = "tcp"
  from_port         = 0
  to_port           = 65535
}

resource "aws_vpc_security_group_egress_rule" "all" {
  security_group_id = aws_security_group.this.id
  description       = "Allow all outbound"
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}
