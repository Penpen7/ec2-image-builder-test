resource "aws_imagebuilder_image_pipeline" "this" {
  name = var.name
  # AMIを作成するためのレシピ
  image_recipe_arn = aws_imagebuilder_image_recipe.this.arn
  # AMIを作成するためのインフラ構成
  infrastructure_configuration_arn = aws_imagebuilder_infrastructure_configuration.this.arn
  # AMIを作成した後の配布設定
  distribution_configuration_arn = aws_imagebuilder_distribution_configuration.this.arn
}

resource "aws_imagebuilder_image_recipe" "this" {
  name = var.name
  # ベースとなるAMI
  parent_image      = var.parent_image
  working_directory = "/tmp"
  version           = "1.0.0"

  block_device_mapping {
    device_name = "/dev/sda1"
    no_device   = false

    ebs {
      delete_on_termination = true
      encrypted             = false
      volume_size           = 16
      volume_type           = "gp2"
    }
  }

  # コンポーネントのarnを指定
  component {
    component_arn = aws_imagebuilder_component.this.arn
  }

  # SSMを配布するAMIから削除するかどうか
  # defaultだとtrueのはず
  systems_manager_agent {
    uninstall_after_build = false
  }
}

resource "aws_imagebuilder_component" "this" {
  name     = var.name
  platform = "Linux"
  version  = "1.0.0"
  data = file(
    var.component_build_path
  )
}

resource "aws_imagebuilder_infrastructure_configuration" "this" {
  name = var.name
  # AMIを作成するためのEC2につけるIAMロール
  instance_profile_name = aws_iam_instance_profile.image_builder.name
  # AMIを作成するためのEC2のインスタンスタイプ
  instance_types = [var.instance_type]
  # AMIを作成するためのEC2につけるセキュリティグループ
  security_group_ids = [aws_security_group.this.id]
  # AMIを作成するためのEC2につけるサブネット
  subnet_id = aws_subnet.public.id
  # 異常終了時にインスタンスを削除するかどうか
  # パイプラインが失敗しデバッグしたい時はfalseにしてインスタンスを残すようにした方が良い
  terminate_instance_on_failure = false

  lifecycle {
    ignore_changes = [instance_metadata_options, logging]
  }
}

resource "aws_imagebuilder_distribution_configuration" "this" {
  name = var.name

  dynamic "distribution" {
    for_each = var.regions
    content {
      ami_distribution_configuration {
        name = "${var.name}{{imagebuilder:buildDate}}"
        ami_tags = {
          Name = "${var.name}"
        }
        target_account_ids = [
          data.aws_caller_identity.current.account_id,
        ]
        launch_permission {
          user_ids = var.ami_share_ids
        }
      }
      region = distribution.value
    }
  }
}

data "aws_caller_identity" "current" {}


resource "aws_iam_instance_profile" "image_builder" {
  name = "${var.name}-EC2ImageBuilderRole"
  role = aws_iam_role.image_builder.name
}

resource "aws_iam_role" "image_builder" {
  name        = "${var.name}-EC2ImageBuilderRole"
  description = "Allows EC2 instances to call AWS services on your behalf."
  path        = "/"
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/EC2InstanceProfileForImageBuilder",
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  ]
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json
}

data "aws_iam_policy_document" "ec2_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
    effect = "Allow"
  }
}
