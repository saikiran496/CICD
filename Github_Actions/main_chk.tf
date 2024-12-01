provider "aws" {
  region = "ap-southeast-1"
}

# Fetch existing key pair or create a new one
data "aws_key_pair" "existing_key" {
  key_name = "terraformkey"
}

resource "aws_key_pair" "key_pair_2" {
  count      = length(data.aws_key_pair.existing_key.*.id) == 0 ? 1 : 0
  key_name   = "terraformkey"
  public_key = file("${path.cwd}/keys/id_rsa.pub")
}

# Fetch existing security group or create a new one
data "aws_security_group" "existing_security_group" {
  filter {
    name   = "group-name"
    values = ["example_security_group"]
  }
}

resource "aws_security_group" "example_security_group_2" {
  count       = length(data.aws_security_group.existing_security_group.*.id) == 0 ? 1 : 0
  name        = "example_security_group"
  description = "Allow SSH and HTTP traffic"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # opens SSH to public
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # opens HTTP to public
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # All traffic
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Define EC2 instance
resource "aws_instance" "terraform_demo_2" {
  ami           = "ami-0ef1a6822965893ba"
  instance_type = "t2.micro"

  # Use existing or newly created security group
  vpc_security_group_ids = [
    coalesce(
      data.aws_security_group.existing_security_group.id,
      aws_security_group.example_security_group.*.id[0]
    )
  ]

  # Use existing or newly created key pair
  key_name = coalesce(
    data.aws_key_pair.existing_key.key_name,
    aws_key_pair.key_pair.*.key_name[0]
  )

  tags = {
    Name        = "TERRAFORM_INSTANCE"
    Environment = "Development"
  }
}

# Output public IP address
output "aws_public_ip_2" {
  value       = aws_instance.terraform_demo.public_ip
  description = "Public IP to connect to the EC2 instance"
}

# Output private IP address
output "aws_private_ip_2" {
  value       = aws_instance.terraform_demo.private_ip
  description = "Private IP to connect to the EC2 instance"
}
