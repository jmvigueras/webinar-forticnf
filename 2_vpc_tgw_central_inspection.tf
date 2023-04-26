#------------------------------------------------------------------------------------------------------------
# Create TGW
#------------------------------------------------------------------------------------------------------------
module "tgw" {
  source = "git::github.com/jmvigueras/modules//aws/tgw"

  prefix = local.prefix

  tgw_cidr    = local.tgw_cidr
  tgw_bgp-asn = local.tgw_bgp-asn
}
#------------------------------------------------------------------------------------------------------------
# Create VPC FGT_CNF attached to TGW
#------------------------------------------------------------------------------------------------------------
module "fgt_cnf_vpc" {
  source = "./modules/vpc_cnf_2az_tgw"

  prefix     = "${local.prefix}-cnf"
  admin_cidr = local.admin_cidr
  admin_port = local.admin_port
  region     = local.region

  vpc-sec_cidr = local.fgt_cnf_vpc_cidr

  tgw_id                 = module.tgw.tgw_id
  tgw_rt-association_id  = module.tgw.rt-vpc-sec-E-W_id
  tgw_rt-propagation_ids = [module.tgw.rt_vpc-spoke_id]
}
#------------------------------------------------------------------------------------------------------------
# Create VPC spokes attached to TGW
# - Default route to TGW
# - N-S traffic to VPC FGT
# - E-W traffic to VPC FGT-CNF
# - VM instance in each VPC
#------------------------------------------------------------------------------------------------------------
module "spoke_vpcs" {
  count  = length(local.vpc_central_inspection_cdirs)
  source = "./modules/vpc_spoke_2az_tgw"

  prefix     = "${local.prefix}-spoke-${count.index + 1}"
  admin_cidr = local.admin_cidr
  admin_port = local.admin_port
  region     = local.region

  vpc-spoke_cidr = local.vpc_central_inspection_cdirs[count.index]

  tgw_id                 = module.tgw.tgw_id
  tgw_rt-association_id  = module.tgw.rt_vpc-spoke_id
  tgw_rt-propagation_ids = [module.tgw.rt_default_id, module.tgw.rt-vpc-sec-N-S_id, module.tgw.rt-vpc-sec-E-W_id]
}
// Create static route N-S in TGW RouteTable Spokes
resource "aws_ec2_transit_gateway_route" "rt_spoke_vpc_default" {
  destination_cidr_block         = "0.0.0.0/0"
  transit_gateway_attachment_id  = module.fgt_vpc.vpc_tgw-att_id
  transit_gateway_route_table_id = module.tgw.rt_vpc-spoke_id
}
// Create static route E-W in RouteTable Spokes
resource "aws_ec2_transit_gateway_route" "rt_spoke_vpc_central_inspection" {
  count                          = length(local.vpc_central_inspection_cdirs)
  destination_cidr_block         = local.vpc_central_inspection_cdirs[count.index]
  transit_gateway_attachment_id  = module.fgt_cnf_vpc.vpc_tgw-att_id
  transit_gateway_route_table_id = module.tgw.rt_vpc-spoke_id
}
// Create VM in subnet vm
module "vm_spoke" {
  count  = length(local.vpc_central_inspection_cdirs)
  source = "git::github.com/jmvigueras/modules//aws/new-instance"

  prefix  = "${local.prefix}-spoke-${count.index + 1}"
  keypair = aws_key_pair.keypair.key_name

  subnet_id       = module.spoke_vpcs[count.index].subnet_az1_ids["vm"]
  security_groups = [module.spoke_vpcs[count.index].nsg_ids["vm"]]
}
