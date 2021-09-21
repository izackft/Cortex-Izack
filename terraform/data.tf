data "aws_subnet_ids" "public" {
  vpc_id = var.vpc_id

  tags = {
    Name = "*Public"

    #Tier = "private"
  }
}

data "aws_availability_zones" "available" {
}

data "template_file" "user_data" {
  template = "${file("scripts/user_data.sh")}"
}