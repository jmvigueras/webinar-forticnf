##############################################################################################################
# Create VPC SEC and Subnets
# - VPC security
# - Subnets AZ1: mgmt, public, private, TGW, GWLB
# - Subnets AZ1: mgmt, public, private, TGW, GWLB
##############################################################################################################
resource "aws_vpc" "vpc-sec" {
  cidr_block           = var.vpc-sec_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "${var.prefix}-vpc-sec"
  }
}

# IGW
resource "aws_internet_gateway" "igw-vpc-sec" {
  vpc_id = aws_vpc.vpc-sec.id
  tags = {
    Name = "${var.prefix}-igw"
  }
}

resource "aws_subnet" "subnet-az1-tgw" {
  vpc_id            = aws_vpc.vpc-sec.id
  cidr_block        = local.subnet_az1_tgw_cidr
  availability_zone = var.region["az1"]
  tags = {
    Name = "${var.prefix}-subnet-az1-tgw"
  }
}

resource "aws_subnet" "subnet-az1-gwlb" {
  vpc_id            = aws_vpc.vpc-sec.id
  cidr_block        = local.subnet_az1_gwlb_cidr
  availability_zone = var.region["az1"]
  tags = {
    Name                     = "${var.prefix}-subnet-az1-gwlb"
    fortigatecnf_subnet_type = "endpoint"
  }
}

resource "aws_subnet" "subnet-az2-tgw" {
  vpc_id            = aws_vpc.vpc-sec.id
  cidr_block        = local.subnet_az2_tgw_cidr
  availability_zone = var.region["az2"]
  tags = {
    Name = "${var.prefix}-subnet-az2-tgw"
  }
}

resource "aws_subnet" "subnet-az2-gwlb" {
  vpc_id            = aws_vpc.vpc-sec.id
  cidr_block        = local.subnet_az2_gwlb_cidr
  availability_zone = var.region["az2"]
  tags = {
    Name                     = "${var.prefix}-subnet-az2-gwlb"
    fortigatecnf_subnet_type = "endpoint"
  }
}