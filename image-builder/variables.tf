variable "vpc_cidr_block" {
  default = "10.0.0.0/16"
}

variable "public_subnet_cidr_block" {
  default = "10.0.0.0/24"
}

variable "name" {
  default = "image-builder-test"
}

variable "parent_image" {
  # ubuntu 22.04
  default = "ami-0d52744d6551d851e"
}

variable "instance_type" {
  default = "t2.small"
}

variable "component_build_path" {
  default = "./files/build.yml"
}

variable "regions" {
  default = ["us-east-1", "ap-northeast-1"]
}

variable "ami_share_ids" {
  default = []
}
