resource "aws_s3_bucket" "state_terraform" {
  bucket = "teste-terraform-cortex"
  acl    = "private"

  versioning {
    enabled = true
  }

  lifecycle {
    prevent_destroy = true
  }

  tags = {
    "Name"          = "Remote Terraform state store"

  }
}