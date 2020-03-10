resource "aws_ecr_repository" "registry" {
  name = "ping-server"

  image_scanning_configuration {
    scan_on_push = true
  }
}
