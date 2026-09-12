resource "aws_ecr_repository" "app" {
  name                 = "aws-infra-portfolio-app"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name = "aws-infra-portfolio-app"
  }
}
