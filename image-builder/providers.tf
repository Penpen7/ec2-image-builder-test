terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  backend "s3" {
    bucket  = "入力してください"
    region  = "ap-northeast-1"
    key     = "image-builder.tfstate"
    profile = "入力してください"
  }
}

provider "aws" {
  region  = "ap-northeast-1"
  profile = "入力してください"
}
