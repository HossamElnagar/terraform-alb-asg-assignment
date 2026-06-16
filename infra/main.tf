# 1. Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.vpc_name}-igw"
  }
}

# 2. الـ VPC الأساسي
resource "aws_vpc" "main" {
  cidr_block       = var.vpc_cidr
  instance_tenancy = "default" 
  
  tags = {
    Name = var.vpc_name
  }
}

# 3. Subnets
resource "aws_subnet" "public_subnet_1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "eu-west-1a"
  
  tags = {
    Name = "${var.vpc_name}-public-1"
  }
}

resource "aws_subnet" "public_subnet_2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.2.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "eu-west-1b"
  tags = {
    Name = "${var.vpc_name}-public-2"
  }
}

# 4. Route Table
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

# 5. Route Table Association (تم ربط الشبكتين)
resource "aws_route_table_association" "public_assoc_1" {
  subnet_id      = aws_subnet.public_subnet_1.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "public_assoc_2" {
  subnet_id      = aws_subnet.public_subnet_2.id
  route_table_id = aws_route_table.public_rt.id
}

# 6. Security Group
resource "aws_security_group" "web_sg" {
  name        = "allow_web_traffic"
  description = "Allow SSH and HTTP traffic"
  vpc_id      = aws_vpc.main.id
  
  ingress {
    description = "HTTP from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] 
  }

  ingress {
    description = "HTTPS from anywhere"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH from anywhere"
    from_port   = 22
    to_port     = 22
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

# 7. EC2 Instance
resource "aws_instance" "web_server" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.public_subnet_1.id

  vpc_security_group_ids = [aws_security_group.web_sg.id]
  user_data              = file("init-script.sh")
  
  tags = {
    Name = "${var.vpc_name}-web-server"
  }
}

# 8. Load Balancer Module
module "my_custom_alb" {
  source = "./MODULES/alb"

  alb_name = "production-alb"
  vpc_id   = aws_vpc.main.id
  subnets  = [aws_subnet.public_subnet_1.id, aws_subnet.public_subnet_2.id]

  target_groups = {
    "web-server-tg" = {
      port      = 80
      protocol  = "HTTP"
      target_id = aws_instance.web_server.id
    }
  }
}

# 9. S3 Bucket Configuration
resource "aws_s3_bucket" "web_bucket" {
  bucket = "hossam-bucket-2026" 
}

resource "aws_s3_bucket_website_configuration" "web_config" {
  bucket = aws_s3_bucket.web_bucket.id

  index_document {
    suffix = "index.html"
  }
}

resource "aws_s3_object" "html_file" {
  bucket       = aws_s3_bucket.web_bucket.id
  key          = "index.html"
  source       = "${path.root}/../index.html" 
  content_type = "text/html"
}

# 10. ALB Listener HTTP (Redirect to S3)
resource "aws_lb_listener" "http" {
  load_balancer_arn = module.my_custom_alb.alb_arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      host        = aws_s3_bucket_website_configuration.web_config.website_endpoint
      port        = "80"
      protocol    = "HTTP"
      status_code = "HTTP_301"
    }
  }
}