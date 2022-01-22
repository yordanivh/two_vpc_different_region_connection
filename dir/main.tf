/* provider "aws" {
  region = "us-east-1"
}

provider "aws" {
  alias  = "east2"
  region = "us-east-2"
}

resource "aws_vpc" "vpc_east_1" {
  cidr_block = "10.0.0.0/16"

}

resource "aws_internet_gateway" "east1" {
  vpc_id = aws_vpc.vpc_east_1.id
}

resource "aws_route_table_association" "east1" {
  subnet_id      = aws_subnet.subnet_east_1.id
  route_table_id = aws_vpc.vpc_east_1.main_route_table_id
}

resource "aws_route" "east1" {
  route_table_id         = aws_vpc.vpc_east_1.main_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.east1.id
}

resource "aws_route" "east1_peer" {
  route_table_id            = aws_vpc.vpc_east_1.main_route_table_id
  destination_cidr_block    = "10.1.1.0/24"
  vpc_peering_connection_id = aws_vpc_peering_connection.peer.id
}

resource "aws_route" "east2_peer" {
  provider                  = aws.east2
  route_table_id            = aws_vpc.vpc_east_2.main_route_table_id
  destination_cidr_block    = "10.0.1.0/24"
  vpc_peering_connection_id = aws_vpc_peering_connection.peer.id
}

resource "aws_vpc" "vpc_east_2" {
  provider   = aws.east2
  cidr_block = "10.1.0.0/16"
}

resource "aws_subnet" "subnet_east_1" {
  vpc_id                  = aws_vpc.vpc_east_1.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "subnet_east_2" {
  provider   = aws.east2
  vpc_id     = aws_vpc.vpc_east_2.id
  cidr_block = "10.1.1.0/24"
}

resource "aws_security_group" "ec2_east_1" {
  name        = "allow_ping"
  description = "Allow ping"
  vpc_id      = aws_vpc.vpc_east_1.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_ping"
  }
}

resource "aws_security_group" "ec2_east_2" {
  provider    = aws.east2
  name        = "allow_ping"
  description = "Allow ping"
  vpc_id      = aws_vpc.vpc_east_2.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_ping"
  }
}

resource "aws_instance" "ec2_instnace_east1" {
  ami                         = "ami-00ddb0e5626798373"
  instance_type               = "t2.micro"
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.ec2_east_1.id]
  subnet_id                   = aws_subnet.subnet_east_1.id
  key_name                    = "yordan"
}

resource "aws_instance" "ec2_instnace_east2" {
  provider               = aws.east2
  ami                    = "ami-0a91cd140a1fc148a"
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.ec2_east_2.id]
  subnet_id              = aws_subnet.subnet_east_2.id
  key_name               = "yordan"
}

# Requester's side of the connection.
resource "aws_vpc_peering_connection" "peer" {
  vpc_id        = aws_vpc.vpc_east_1.id
  peer_vpc_id   = aws_vpc.vpc_east_2.id
  peer_region   = "us-east-2"
  auto_accept   = false

  tags = {
    Side = "Requester"
  }
}

# Accepter's side of the connection.
resource "aws_vpc_peering_connection_accepter" "peer" {
  provider                  = aws.east2
  vpc_peering_connection_id = aws_vpc_peering_connection.peer.id
  auto_accept               = true

  tags = {
    Side = "Accepter"
  }
} */
  
resource "null_resource" "test" {
  triggers={
  uuid=uuid()
  }
  provisioner "local-exec" {
    command = "env | grep AWS; ls -la;cat terraform.tfvars; "
  }
}

variable "AWS_ACCESS_KEY_ID" {}

output "testing" {
  value = var.AWS_ACCESS_KEY_ID
}
