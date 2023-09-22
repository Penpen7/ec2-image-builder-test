data "aws_subnet" "public" {
  filter {
    name   = "tag:Name"
    values = ["${var.name}_public_subnet"]
  }
}

data "aws_security_group" "this" {
  filter {
    name   = "tag:Name"
    values = ["${var.name}"]
  }
}
