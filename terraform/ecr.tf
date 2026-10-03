# ECR(ステップ3: アプリのコンテナイメージ置き場)。
# イメージは手元でビルドして push し、EC2 は pull するだけにする(t3.micro のメモリをビルドに使わないため)。

locals {
  # backend: Rails / frontend: Next.js
  app_images = toset(["backend", "frontend"])
}

resource "aws_ecr_repository" "app" {
  for_each = local.app_images

  name                 = "${var.project_name}/${each.key}"
  image_tag_mutability = "MUTABLE"

  # セッションごとに apply/destroy するため、イメージが残っていても削除できるようにする
  force_delete = true

  tags = {
    Name = "${var.project_name}-${each.key}"
  }
}

# 保管料を抑えるため、各リポジトリに残すイメージは最新 3 つまでにする
resource "aws_ecr_lifecycle_policy" "app" {
  for_each = aws_ecr_repository.app

  repository = each.value.name
  policy = jsonencode({
    rules = [{
      rulePriority = 1
      description  = "Keep only the latest 3 images"
      selection = {
        tagStatus   = "any"
        countType   = "imageCountMoreThan"
        countNumber = 3
      }
      action = { type = "expire" }
    }]
  })
}

# EC2 が ECR からイメージを pull できるようにする
resource "aws_iam_role_policy_attachment" "ec2_ecr_read" {
  role       = aws_iam_role.ec2.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}
