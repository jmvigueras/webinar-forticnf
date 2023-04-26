#---------------------------------------------------------------------------
# - Create TGW attachment
# - Associate to RT
# - Propagate to RT
#---------------------------------------------------------------------------
resource "aws_ec2_transit_gateway_vpc_attachment" "tgw-att-vpc" {
  subnet_ids         = [aws_subnet.subnet-vpc-az1-tgw.id, aws_subnet.subnet-vpc-az2-tgw.id]
  transit_gateway_id = var.tgw_id
  vpc_id             = aws_vpc.vpc.id

  transit_gateway_default_route_table_association = false
  transit_gateway_default_route_table_propagation = false

  tags = {
    Name = "${var.prefix}-tgw-att-vpc"
  }
}
# Create route table association
resource "aws_ec2_transit_gateway_route_table_association" "tgw-att-vpc-sec_association" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.tgw-att-vpc.id
  transit_gateway_route_table_id = var.tgw_rt-association_id
}
# Create route propagation if route table id provided
resource "aws_ec2_transit_gateway_route_table_propagation" "tgw-att-vpc_propagation" {
  count                          = length(var.tgw_rt-propagation_ids)
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.tgw-att-vpc.id
  transit_gateway_route_table_id = var.tgw_rt-propagation_ids[count.index]
}
#-------------------------------------------------------------------------------------------------------------
# VM routes
#-------------------------------------------------------------------------------------------------------------
# TableRoute ready to change 0.0.0.0/0 route to GWLBe
resource "aws_route_table" "rt_spoke_vm" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = var.admin_cidr
    gateway_id = aws_internet_gateway.igw-vpc.id
  }
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw-vpc.id
  }
  route {
    cidr_block         = "192.168.0.0/16"
    transit_gateway_id = var.tgw_id
  }
  route {
    cidr_block         = "172.16.0.0/12"
    transit_gateway_id = var.tgw_id
  }
  route {
    cidr_block         = "10.0.0.0/8"
    transit_gateway_id = var.tgw_id
  }
  tags = {
    Name           = "${var.prefix}-rt-vm"
    update-route-1 = "0.0.0.0/0 to CNF GWLBe"
    add-route-2    = "${cidrsubnet(var.vpc-spoke_cidr, 3, 0)}to CNF GWLBe AZ1"
    add-route-3    = "${cidrsubnet(var.vpc-spoke_cidr, 3, 4)}to CNF GWLBe AZ1"
  }
}
# Route tables associations
resource "aws_route_table_association" "ra_spoke_vm_az1" {
  subnet_id      = aws_subnet.subnet-vpc-az1-vm.id
  route_table_id = aws_route_table.rt_spoke_vm.id
}
resource "aws_route_table_association" "ra_spoke_vm_az2" {
  subnet_id      = aws_subnet.subnet-vpc-az2-vm.id
  route_table_id = aws_route_table.rt_spoke_vm.id
}
#-------------------------------------------------------------------------------------------------------------
# IGW routes
#-------------------------------------------------------------------------------------------------------------
# Route table IGW (ready to add VM subnet range point to GWLBe)
resource "aws_route_table" "rt_spoke_igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name          = "${var.prefix}-rt-igw"
    add-route-az1 = "${cidrsubnet(var.vpc-spoke_cidr, 3, 0)} vm az1 cidr to CNF GWLBe"
    add-route-az2 = "${cidrsubnet(var.vpc-spoke_cidr, 3, 4)} vm az2 cidr to CNF GWLBe"
  }
}
# Route tables associations
resource "aws_route_table_association" "ra_spoke_igw" {
  gateway_id     = aws_internet_gateway.igw-vpc.id
  route_table_id = aws_route_table.rt_spoke_igw.id
}
#-------------------------------------------------------------------------------------------------------------
# GWLBe routes
#-------------------------------------------------------------------------------------------------------------
# Route table IGW (ready to add VM subnet range point to GWLBe)
resource "aws_route_table" "rt_spoke_gwlb" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw-vpc.id
  }

  tags = {
    Name = "${var.prefix}-rt-gwlb"
  }
}
# Route tables associations
resource "aws_route_table_association" "ra_spoke_gwlb_az1" {
  subnet_id      = aws_subnet.subnet-vpc-az1-gwlb.id
  route_table_id = aws_route_table.rt_spoke_gwlb.id
}
resource "aws_route_table_association" "ra_spoke_gwlb_az2" {
  subnet_id      = aws_subnet.subnet-vpc-az2-gwlb.id
  route_table_id = aws_route_table.rt_spoke_gwlb.id
}
#-------------------------------------------------------------------------------------------------------------
# TGW routes
#-------------------------------------------------------------------------------------------------------------
# Route table Transit Gateway endpoints
resource "aws_route_table" "rt_spoke_tgw_az1" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${var.prefix}-rt-tgw-az1"
  }
}
resource "aws_route_table" "rt_spoke_tgw_az2" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${var.prefix}-rt-tgw-az2"
  }
}
# Route tables associations
resource "aws_route_table_association" "ra_spoke_tgw_az1" {
  subnet_id      = aws_subnet.subnet-vpc-az1-tgw.id
  route_table_id = aws_route_table.rt_spoke_tgw_az1.id
}
resource "aws_route_table_association" "ra_spoke_tgw_az2" {
  subnet_id      = aws_subnet.subnet-vpc-az2-tgw.id
  route_table_id = aws_route_table.rt_spoke_tgw_az1.id
}