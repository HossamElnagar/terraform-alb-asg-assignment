# ---------------------------------------
# VPC
# ---------------------------------------
resource "aws_vpc" "main" {
  cidr_block       = var.vpc_cidr
  instance_tenancy = "default"

  tags = {
    Name = var.vpc_name
  }
}

# ---------------------------------------
# Internet Gateway
# ---------------------------------------
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.vpc_name}-igw"
  }
}

# ---------------------------------------
# Public Subnets
# ---------------------------------------
resource "aws_subnet" "public_subnet_1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "eu-west-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.vpc_name}-public-1"
  }
}

resource "aws_subnet" "public_subnet_2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "eu-west-1b"
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.vpc_name}-public-2"
  }
}

# ---------------------------------------
# Route Table
# ---------------------------------------
resource "aws_route_table" "public_rt" {

  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "${var.vpc_name}-public-rt"
  }
}

resource "aws_route_table_association" "public_assoc_1" {
  subnet_id      = aws_subnet.public_subnet_1.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "public_assoc_2" {
  subnet_id      = aws_subnet.public_subnet_2.id
  route_table_id = aws_route_table.public_rt.id
}

# ---------------------------------------
# ALB Security Group
# ---------------------------------------
resource "aws_security_group" "alb_sg" {

  name        = "alb-sg"
  description = "Allow HTTP traffic from internet"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# ---------------------------------------
# EC2 Security Group
# ---------------------------------------
resource "aws_security_group" "ec2_sg" {

  name        = "ec2-sg"
  description = "Allow HTTP only from ALB"
  vpc_id      = aws_vpc.main.id

  ingress {

    from_port = 80
    to_port   = 80
    protocol  = "tcp"

    security_groups = [
      aws_security_group.alb_sg.id
    ]
  }

  ingress {

    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["YOUR_PUBLIC_IP/32"]
  }

  egress {

    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# ---------------------------------------
# EC2 Instance
# ---------------------------------------
resource "aws_instance" "web_server" {

  ami           = data.aws_ami.amazon_linux.id
  instance_type = "t2.micro"

  subnet_id = aws_subnet.public_subnet_1.id

  vpc_security_group_ids = [
    aws_security_group.ec2_sg.id
  ]

  associate_public_ip_address = true

  user_data = base64encode(
    templatefile("${path.module}/../user_data.sh", {
      html_content = file("${path.root}/../index.html")
    })
  )

  tags = {
    Name = "${var.vpc_name}-web-server"
  }
}

# ---------------------------------------
# ALB Module
# ---------------------------------------
module "my_custom_alb" {

  source = "./MODULES/alb"

  alb_name = "production-alb"

  vpc_id = aws_vpc.main.id

  subnets = [
    aws_subnet.public_subnet_1.id,
    aws_subnet.public_subnet_2.id
  ]

  security_groups = [
    aws_security_group.alb_sg.id
  ]

  target_groups = {
    web-server-tg = {
      port     = 80
      protocol = "HTTP"
    }
  }
}

# ---------------------------------------
# Attach EC2 to Target Group
# ---------------------------------------
resource "aws_lb_target_group_attachment" "web_attachment" {
  target_group_arn = module.my_custom_alb.target_group_arns["web-server-tg"]
  target_id = aws_instance.web_server.id
  port = 80
}