# Security Groups
## Need to create 4 of them as our Security Groups are linked to a VPC
resource "aws_security_group" "nsg-vpc-sec-allow-all" {
  name        = "${var.prefix}-nsg-vpc-sec-allow-all"
  description = "Allow all"
  vpc_id      = aws_vpc.vpc-sec.id

  ingress {
    description = "Allow all"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    description = "Allow all"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.prefix}-nsg-private"
  }
}