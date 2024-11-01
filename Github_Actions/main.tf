#PROVIDER DETAILS

provider "aws" {
    region = "ap-southeast-1"
}

resource "aws_key_pair" "key_pair" {
    key_name = "terraformkey"
    public_key = file("~/.ssh/id_rsa.pub")
}

#Definensecurity group

resource "aws_security_group" "example_security_group" {
    name = "example_security_group"
    description = "Allow SSh and HTTP traffic"
    
    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"] #opens SSh to public
    }

    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"] #opens SSh to public
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1" # All traffic
        cidr_blocks = ["0.0.0.0/0"] #opens SSh to public
    }
}

    
#Define EC2 instance

resource "aws_instance" "terrform_demo" {

    ami = "ami-0ef1a6822965893ba"
    instance_type = "t2.micro"

    #Associate the security group with instance

    security_groups = [aws_security_group.example_security_group.name]
    
    #Use the created key pair for ssh access
    key_name = aws_key_pair.key_pair.key_name

    tags = {
        Name = "tERRAFORM_INSTANCE"
        Environment = "Development"
    }
    

}


#print instance ip address
output "aws_public_ip" {

    value = aws_instance.terrform_demo.public_ip
    description = "public ip to connect to the EC2 instance"
 }

 output "aws_private_ip" {

    value = aws_instance.terrform_demo.private_ip
    description = "private ip to connect to the EC2 instance"
 }



#output "private_key" {
#    value = aws_key_pair.key_pair.private_key
#   description = "private key to connect to the EC2 instance"
#    sensitive = true
#}