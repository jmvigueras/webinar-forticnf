output "subnet_az1_cidrs" {
  value = {
    tgw  = aws_subnet.subnet-az1-tgw.cidr_block
    gwlb = aws_subnet.subnet-az1-gwlb.cidr_block
  }
}

output "subnet_az2_cidrs" {
  value = {
    tgw  = aws_subnet.subnet-az2-tgw.cidr_block
    gwlb = aws_subnet.subnet-az2-gwlb.cidr_block
  }
}

output "subnet_az1_ids" {
  value = {
    tgw  = aws_subnet.subnet-az1-tgw.id
    gwlb = aws_subnet.subnet-az1-gwlb.id
  }
}

output "subnet_az2_ids" {
  value = {
    tgw  = aws_subnet.subnet-az2-tgw.id
    gwlb = aws_subnet.subnet-az2-gwlb.id
  }
}

output "routes_ids" {
  value = {
    tgw  = aws_route_table.rt-tgw-az1.id
    gwlb = aws_route_table.rt-gwlb.id
  }
}

output "vpc-sec_id" {
  value = aws_vpc.vpc-sec.id
}

output "nsg_ids" {
  value = {
    allow_all = aws_security_group.nsg-vpc-sec-allow-all.id
  }
}

output "vpc_tgw-att_id" {
  value = aws_ec2_transit_gateway_vpc_attachment.tgw-att-vpc-sec.id
}