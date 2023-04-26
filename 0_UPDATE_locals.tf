locals {
  #-----------------------------------------------------------------------------------------------------
  # General variables
  #-----------------------------------------------------------------------------------------------------
  prefix = "sec-day"
  region = {
    id  = "eu-west-1"
    az1 = "eu-west-1a"
    az2 = "eu-west-1c"
  }

  #-----------------------------------------------------------------------------------------------------
  # VPC spokes
  #-----------------------------------------------------------------------------------------------------
  vpc_central_inspection_cdirs = ["172.20.100.0/24", "172.20.150.0/24"]
  vpc_n-s_inspection_cidr      = "172.20.200.0/24"

  spoke_sdwan_cidrs = ["192.168.0.0/16"]

  #-----------------------------------------------------------------------------------------------------
  # FGT SDWAN N-S
  #-----------------------------------------------------------------------------------------------------
  admin_port = "8443"
  admin_cidr = "${chomp(data.http.my-public-ip.body)}/32"

  fgt_instance_type = "c6i.large"
  fgt_build         = "build1396"
  fgt_license_type  = "payg"
  sdwan_fgt_passive = false

  fgt_vpc_cidr = "172.20.0.0/24"

  onramp = {
    id      = "onramp"
    cidr    = local.fgt_vpc_cidr
    bgp-asn = local.hub["bgp-asn_spoke"]
  }
  hubs = [
    {
      id                = local.hub["id"]
      bgp-asn           = local.hub["bgp-asn_hub"]
      public-ip         = module.fgt_hub.fgt_active_eip_public
      hub-ip            = cidrhost(local.hub["vpn_cidr"], 1)
      site-ip           = "" // set to "" if VPN mode-cfg is enable
      hck-srv-ip        = cidrhost(local.hub["vpn_cidr"], 1)
      vpn_psk           = module.fgt_hub_config.vpn_psk
      cidr              = local.hub["cidr"]
      ike-version       = local.hub["ike-version"]
      network_id        = local.hub["network_id"]
      dpd-retryinterval = local.hub["dpd-retryinterval"]
    }
  ]

  #-----------------------------------------------------------------------------------------------------
  # FGT CNF E-W
  #-----------------------------------------------------------------------------------------------------
  fgt_cnf_vpc_cidr = "172.20.10.0/24"

  #-----------------------------------------------------------------------------------------------------
  # FGT HUB
  #-----------------------------------------------------------------------------------------------------
  hub_vpc_cidr    = "192.168.0.0/24"
  hub_fgt_passive = false

  hub = {
    id                = "HUB"
    bgp-asn_hub       = "65000"
    bgp-asn_spoke     = "65000"
    vpn_cidr          = "10.10.10.0/24"
    vpn_psk           = "secret-key-123"
    cidr              = local.hub_vpc_cidr
    ike-version       = "2"
    network_id        = "1"
    dpd-retryinterval = "5"
    mode-cfg          = true
  }

  #-----------------------------------------------------------------------------------------------------
  # TGW
  #-----------------------------------------------------------------------------------------------------
  tgw_bgp-asn     = "65515"
  tgw_cidr        = ["172.20.50.0/24"]
  tgw_inside_cidr = ["169.254.100.0/29", "169.254.101.0/29"]
}