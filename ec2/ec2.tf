resource "aws_instance" "server" {
  count                  = var.server_count
  ami                    = data.aws_ami.server.id
  instance_type          = "t2.small"
  subnet_id              = data.aws_subnet.public.id
  vpc_security_group_ids = [data.aws_security_group.this.id]
  iam_instance_profile   = aws_iam_instance_profile.this.name
  tags = {
    "Name" = "${var.name}-${count.index}"
  }
  associate_public_ip_address = true

  lifecycle {
    ignore_changes = [
      associate_public_ip_address,
      user_data
    ]
  }
}

data "aws_ami" "server" {
  owners      = ["self"]
  name_regex  = "^${var.name}.*"
  most_recent = true
}
