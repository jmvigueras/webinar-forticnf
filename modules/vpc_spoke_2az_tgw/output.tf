output "subnet_az1_cidrs" {
  value = {
    vm  = aws_subnet.subnet-vpc-az1-vm.cidr_block
    tgw = aws_subnet.subnet-vpc-az1-tgw.cidr_block
  }
}

output "subnet_az2_cidrs" {
  value = {
    vm  = aws_subnet.subnet-vpc-az2-vm.cidr_block
    tgw = aws_subnet.subnet-vpc-az2-tgw.cidr_block
  }
}

output "subnet_az1_ids" {
  value = {
    vm  = aws_subnet.subnet-vpc-az1-vm.id
    tgw = aws_subnet.subnet-vpc-az1-tgw.id
  }
}

output "subnet_az2_ids" {
  value = {
    vm  = aws_subnet.subnet-vpc-az2-vm.id
    tgw = aws_subnet.subnet-vpc-az2-tgw.id
  }
}

output "routes_ids" {
  value = {
    vm = aws_route_table.rt_spoke_vm.id
  }
}

output "nsg_ids" {
  value = {
    vm = aws_security_group.nsg-vpc-vm.id
  }
}

output "vpc_id" {
  value = aws_vpc.vpc.id
}

output "vpc_cidr" {
  value = aws_vpc.vpc.cidr_block
}

output "vpc_igw_id" {
  value = aws_internet_gateway.igw-vpc.id
}

output "vpc_tgw-att_id" {
  value = aws_ec2_transit_gateway_vpc_attachment.tgw-att-vpc.id
}