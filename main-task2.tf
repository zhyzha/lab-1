#storing tf-file in S3 bucket
terraform {
    backend "s3" {
        bucket  = "lab-devops-for-storing-tffiles"
        key     = "project1-vpc-ec2.tfstate"
        region  = "us-east-1"
        encrypt = true

    }
}

#creating an VPC, subnets, igw
resource "aws_vpc" "vpc1" {
    cidr_block = "192.168.0.0/16"
    tags = {
      Owner = "zhyldyz"
    }
}
#igw
resource "aws_internet_gateway" "vpc1_igw" {
    vpc_id = aws_vpc.vpc1.id

    tags = {
      Owner = "zhyldyz"
    }

    depends_on = [aws_vpc.vpc1]  
}
# 2 public subnets
resource "aws_subnet" "public_subnet1" {
    vpc_id = aws_vpc.vpc1.id
    cidr_block = "192.168.1.0/24"
    availability_zone = "us-east-1a"
    tags = {
      Owner = "zhyldyz"
    }
    depends_on = [aws_vpc.vpc1]

}
resource "aws_subnet" "public_subnet2" {
    vpc_id = aws_vpc.vpc1.id
    cidr_block = "192.168.2.0/24"
    availability_zone = "us-east-1b"
    tags = {
      Owner = "zhyldyz"
    }
    depends_on = [aws_vpc.vpc1]
}

resource "aws_default_route_table" "internet_gateway_rt" {
    default_route_table_id = aws_vpc.vpc1.main_route_table_id

# open the traffic
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.vpc1_igw.id
    }

     route {
    ipv6_cidr_block = "::/0"
    gateway_id      = aws_internet_gateway.vpc1_igw.id
  }

    tags = {
        Owner = "zhyldyz"
    }

    depends_on = [aws_vpc.vpc1]
}
resource "aws_route_table_association" "internet_gateway1" {
    subnet_id = aws_subnet.public_subnet1.id

    route_table_id = aws_vpc.vpc1.main_route_table_id

}

#creating a sg to allow the traffic
resource "aws_security_group" "web_sg" {
  name   = "HTTP and SSH"
  vpc_id = aws_vpc.vpc1.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
}
#deploying 2 instances - 1 in each subnet 
resource "aws_instance" "instance1" {
  ami           = "ami-00826dc7e0af75de2"
  instance_type = "t2.micro"
  key_name      = "awskey"

  subnet_id                   = aws_subnet.public_subnet1.id
  vpc_security_group_ids      = [aws_security_group.web_sg.id]
  associate_public_ip_address = true

  tags = {
    "Name" : "Zhyldyz"
  }
}

resource "aws_instance" "instance2" {
  ami           = "ami-00826dc7e0af75de2"
  instance_type = "t2.micro"
  key_name      = "awskey"

  subnet_id                   = aws_subnet.public_subnet2.id
  vpc_security_group_ids      = [aws_security_group.web_sg.id]
  associate_public_ip_address = true

  tags = {
    "Name" : "Zhyldyz2"
  }
}