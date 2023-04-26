#---------------------------------------------------------------------------
# - Create TGW attachment
# - Associate to RT
# - Propagate to RT
#---------------------------------------------------------------------------
# Attachment to TGW
resource "aws_ec2_transit_gateway_vpc_attachment" "tgw-att-vpc-sec" {
  subnet_ids             = [aws_subnet.subnet-az1-tgw.id, aws_subnet.subnet-az2-tgw.id]
  transit_gateway_id     = var.tgw_id
  vpc_id                 = aws_vpc.vpc-sec.id
  # appliance_mode_support = "enable"

  transit_gateway_default_route_table_association = false
  transit_gateway_default_route_table_propagation = false

  tags = {
    Name = "${var.prefix}-tgw-att-vpc-sec"
  }
}
# Create route table association
resource "aws_ec2_transit_gateway_route_table_association" "tgw-att-vpc-sec_association" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.tgw-att-vpc-sec.id
  transit_gateway_route_table_id = var.tgw_rt-association_id
}
# Create route propagation if route table id provided
resource "aws_ec2_transit_gateway_route_table_propagation" "tgw-att-vpc_propagation" {
  count                          = length(var.tgw_rt-propagation_ids)
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.tgw-att-vpc-sec.id
  transit_gateway_route_table_id = var.tgw_rt-propagation_ids[count.index]
}
#---------------------------------------------------------------------------
# Route subnet TGW
#---------------------------------------------------------------------------
# Create route tgw AZ1
resource "aws_route_table" "rt-tgw-az1" {
  vpc_id = aws_vpc.vpc-sec.id

  tags = {
    Name      = "${var.prefix}-rt-tgw-az1"
    add-route = "add 0.0.0.0/0 to CNF GWLBe"
  }
}
# Create route tgw AZ2
resource "aws_route_table" "rt-tgw-az2" {
  vpc_id = aws_vpc.vpc-sec.id

  tags = {
    Name      = "${var.prefix}-rt-tgw-az2"
    add-route = "add 0.0.0.0/0 to CNF GWLBe"
  }
}
# Route table associations AZ1
resource "aws_route_table_association" "ra-subnet-az1-tgw" {
  subnet_id      = aws_subnet.subnet-az1-tgw.id
  route_table_id = aws_route_table.rt-tgw-az1.id
}
# Route table associations AZ2
resource "aws_route_table_association" "ra-subnet-az2-tgw" {
  subnet_id      = aws_subnet.subnet-az2-tgw.id
  route_table_id = aws_route_table.rt-tgw-az1.id
}
#---------------------------------------------------------------------------
# Route subnet GWLB
#---------------------------------------------------------------------------
# Route subnet gwlb
resource "aws_route_table" "rt-gwlb" {
  vpc_id = aws_vpc.vpc-sec.id
  route {
    cidr_block         = "0.0.0.0/0"
    transit_gateway_id = var.tgw_id
  }
  tags = {
    Name = "${var.prefix}-rt-gwlb"
  }
}
# Route table associations AZ1
resource "aws_route_table_association" "ra-subnet-az1-gwlb" {
  subnet_id      = aws_subnet.subnet-az1-gwlb.id
  route_table_id = aws_route_table.rt-gwlb.id
}
# Route table associations AZ2
resource "aws_route_table_association" "ra-subnet-az2-gwlb" {
  subnet_id      = aws_subnet.subnet-az2-gwlb.id
  route_table_id = aws_route_table.rt-gwlb.id
}



