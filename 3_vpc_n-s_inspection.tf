#------------------------------------------------------------------------------------------------------------
# Create VPC for use case N-S (direct access to INET using IGW)
#------------------------------------------------------------------------------------------------------------
module "spoke_vpc_n-s" {
  source = "./modules/vpc_spoke_2az_gwlb"

  prefix     = "${local.prefix}-vpc-n-s"
  admin_cidr = local.admin_cidr
  admin_port = local.admin_port
  region     = local.region

  vpc-spoke_cidr = local.vpc_n-s_inspection_cidr

  tgw_id                 = module.tgw.tgw_id
  tgw_rt-association_id  = module.tgw.rt_vpc-spoke_id
  tgw_rt-propagation_ids = [module.tgw.rt_default_id, module.tgw.rt-vpc-sec-N-S_id, module.tgw.rt-vpc-sec-E-W_id]
}
module "vm_spoke_n-s_az1" {
  source = "git::github.com/jmvigueras/modules//aws/new-instance"

  prefix  = "${local.prefix}-spoke-n-s-az1"
  keypair = aws_key_pair.keypair.key_name

  subnet_id       = module.spoke_vpc_n-s.subnet_az1_ids["vm"]
  security_groups = [module.spoke_vpc_n-s.nsg_ids["vm"]]
}

module "vm_spoke_n-s_az2" {
  source = "git::github.com/jmvigueras/modules//aws/new-instance"

  prefix  = "${local.prefix}-spoke-n-s-az2"
  keypair = aws_key_pair.keypair.key_name

  subnet_id       = module.spoke_vpc_n-s.subnet_az2_ids["vm"]
  security_groups = [module.spoke_vpc_n-s.nsg_ids["vm"]]
}