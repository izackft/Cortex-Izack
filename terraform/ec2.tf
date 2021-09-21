provider "aws" {
  region  = local.region
  profile = var.profile_aws
}

terraform {
  required_version = ">=0.14"
  backend "s3" {
  }
}

locals {
  availability_zone = "${local.region}e"
  name              = "CASE"
  region            = "us-east-1"
  tags = {
    Owner       = "Cortex"
    Environment = "dev"
  }
}

################################################################################
# Supporting Resources
################################################################################


data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-*"]
  }
}

module "security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 4.0"

  name        = local.name
  description = "Security group for example usage with EC2 instance"
  vpc_id      = var.vpc_id

  # Open to CIDRs blocks (rule or from_port+to_port+protocol+description)
  ingress_with_cidr_blocks = [
    {
      rule        = "postgresql-tcp"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      rule        = "ssh-tcp"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      from_port   = 8081
      to_port     = 8081
      protocol    = "tcp"
      description = "Service name"
      cidr_blocks = "0.0.0.0/0"
    },
  ]
  egress_rules        = ["all-all"]

  tags = local.tags
}

################################################################################
# EC2 Module
################################################################################

module "ec2" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 3.0"

  name = local.name

  ami               = data.aws_ami.ubuntu.id
  instance_type     = "t2.micro"
  key_name = "cortex"
  #availability_zone = local.availability_zone
  #user_data = "${data.template_file.user_data.rendered}"
/*   user_data = <<-EOF
    #cloud-config
cloud_final_modules:
- [users-groups, once]
users:
  - name: ubuntu
    ssh-authorized-keys: 
    - ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDw2vM2mQAGFjyxsrToC6pT2fjGCHgjmCDadoDPcekvOYGBQude2otfdSzhr4TySQ8oqAtVEFwftldgoIj+XwONJhFTJYSiAk6pz/62NbaA8TVFxCeVGP9mYdqdu+iboVH+Txj25Ke/7Cx/wS3nADOZwvALpzVLVDuvansfJ2JUr527Ux/y06UD2vhayWCosXrYrqI9aSiXMXCDsHFYGJSqASLP+yLxsUNA1llG2PfFzrhaxfLB/ISgYxWYgXF9hzvojCzs3eHvwT2SwjRPDLOvbp9oQ+f82I3X2dD48f5gwtckz2SMumENYdec4MOjScvDOfFB4Di0ypbAanq5Mq4h izack@darksoul

  EOF */
  # subnet_id         = data.aws_subnet_ids.public.ids[0]
  #subnet_id = element(data.aws_subnet_ids.public, 0)
  # subnet_id                   = element(module.vpc.private_subnets, 0)
  subnet_id = "subnet-79225a46"
  vpc_security_group_ids      = [module.security_group.security_group_id]
  associate_public_ip_address = true

  tags = local.tags
}

resource "aws_volume_attachment" "this" {
  device_name = "/dev/sdh"
  volume_id   = aws_ebs_volume.this.id
  instance_id = module.ec2.id
}

resource "aws_ebs_volume" "this" {
  availability_zone = local.availability_zone
  size              = 10

  tags = local.tags
}




/* runcmd:
 - [ sudo sh, -c, "echo "deb http://apt.postgresql.org/pub/repos/apt/ `lsb_release -cs`-pgdg main" >> /etc/apt/sources.list.d/pgdg.list" ]
 - [sudo sh, -c, "timedatectl set-timezone America/Sao_Paulo"] */