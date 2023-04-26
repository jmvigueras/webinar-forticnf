#------------------------------------------------------------------------------
# Create FGT cluster onramp
# - Create FGT onramp config (FGCP Active-Passive)
# - Create FGT instance
# - Create FGT VPC, subnets, NI and SG
#------------------------------------------------------------------------------
# Create FGT config
module "fgt_config" {
  source = "git::github.com/jmvigueras/modules//aws/fgt-config"

  admin_cidr     = local.admin_cidr
  admin_port     = local.admin_port
  rsa-public-key = trimspace(tls_private_key.ssh.public_key_openssh)
  api_key        = trimspace(random_string.api_key.result)

  subnet_active_cidrs  = module.fgt_vpc.subnet_az1_cidrs
  subnet_passive_cidrs = module.fgt_vpc.subnet_az1_cidrs
  fgt-active-ni_ips    = module.fgt_vpc.fgt-active-ni_ips
  fgt-passive-ni_ips   = module.fgt_vpc.fgt-passive-ni_ips

  fgt_active_extra-config  = join("\n", data.template_file.fgt_active_extra-config.*.rendered)
  fgt_passive_extra-config = join("\n", data.template_file.fgt_passive_extra-config.*.rendered)

  config_fgcp  = true
  config_spoke = true
  config_fmg   = false
  config_faz   = false

  fmg_ip = module.fmg.ni_ips["private"]
  faz_ip = module.faz.ni_ips["private"]
  hubs   = local.hubs
  spoke  = local.onramp

  vpc-spoke_cidr = concat(local.vpc_central_inspection_cdirs, [module.fgt_vpc.subnet_az1_cidrs["bastion"]], [local.vpc_n-s_inspection_cidr])
}
# Create data template extra-config fgt
data "template_file" "fgt_active_extra-config" {
  count    = length(local.vpc_central_inspection_cdirs)
  template = file("./templates/fgt_extra-config.tpl")
  vars = {
    external_ip   = module.fgt_vpc.fgt-active-ni_ips["public"]
    mapped_ip     = module.vm_spoke[count.index].vm["private_ip"]
    external_port = "${80 + count.index}"
    mapped_port   = "80"
    public_port   = "port2"
    private_port  = "port3"
    suffix        = "${80 + count.index}"
  }
}
data "template_file" "fgt_passive_extra-config" {
  count    = length(local.vpc_central_inspection_cdirs)
  template = file("./templates/fgt_extra-config.tpl")
  vars = {
    external_ip   = module.fgt_vpc.fgt-passive-ni_ips["public"]
    mapped_ip     = module.vm_spoke[count.index].vm["private_ip"]
    external_port = "${80 + count.index}"
    mapped_port   = "80"
    public_port   = "port2"
    private_port  = "port3"
    suffix        = "${80 + count.index}"
  }
}
# Create FGT
module "fgt" {
  source = "git::github.com/jmvigueras/modules//aws/fgt-ha"

  prefix        = "${local.prefix}-sdwan"
  region        = local.region
  instance_type = local.fgt_instance_type
  keypair       = aws_key_pair.keypair.key_name

  license_type = local.fgt_license_type
  fgt_build    = local.fgt_build

  fgt-active-ni_ids  = module.fgt_vpc.fgt-active-ni_ids
  fgt-passive-ni_ids = module.fgt_vpc.fgt-passive-ni_ids
  fgt_config_1       = module.fgt_config.fgt_config_1
  fgt_config_2       = module.fgt_config.fgt_config_2

  fgt_passive = local.sdwan_fgt_passive
}
# Create VPC FGT
module "fgt_vpc" {
  source = "git::github.com/jmvigueras/modules//aws/vpc-fgt-2az_tgw"

  prefix     = "${local.prefix}-sdwan"
  admin_cidr = local.admin_cidr
  admin_port = local.admin_port
  region     = local.region

  vpc-sec_cidr = local.fgt_vpc_cidr

  tgw_id                = module.tgw.tgw_id
  tgw_rt-association_id = module.tgw.rt-vpc-sec-N-S_id
  tgw_rt-propagation_id = module.tgw.rt_vpc-spoke_id
}
