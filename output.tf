# Output
output "fgt_onramp" {
  value = {
    fgt-1_mgmt   = "https://${module.fgt.fgt_active_eip_mgmt}:${local.admin_port}"
    fgt-2_mgmt   = local.sdwan_fgt_passive ? module.fgt.fgt_passive_eip_mgmt : ""
    fgt-1_public = module.fgt.fgt_active_eip_public
    username     = "admin"
    fgt-1_pass   = module.fgt.fgt_active_id
    fgt-2_pass   = local.sdwan_fgt_passive ? module.fgt.fgt_passive_id[0] : ""
    admin_cidr   = "${chomp(data.http.my-public-ip.response_body)}/32"
    api_key      = module.fgt_config.api_key
  }
}

output "fgt_hub" {
  value = {
    fgt-1_mgmt   = "https://${module.fgt_hub.fgt_active_eip_mgmt}:${local.admin_port}"
    fgt-2_mgmt   = local.hub_fgt_passive ? module.fgt_hub.fgt_passive_eip_mgmt : ""
    fgt-1_public = module.fgt_hub.fgt_active_eip_public
    username     = "admin"
    fgt-1_pass   = module.fgt_hub.fgt_active_id
    fgt-2_pass   = local.hub_fgt_passive ? module.fgt_hub.fgt_passive_id[0] : ""
    admin_cidr   = "${chomp(data.http.my-public-ip.response_body)}/32"
    api_key      = module.fgt_hub_config.api_key
  }
}

output "faz" {
  value = {
    faz_mgmt = "https://${module.faz.eip_public}"
    faz_pass = module.faz.id
  }
}

output "fmg" {
  value = {
    fmg_mgmt = "https://${module.fmg.eip_public}"
    fmg_pass = module.fmg.id
  }
}

output "vm_spoke_central_mgmt" {
  value = module.vm_spoke.*.vm
}

output "vm_spoke_n-s_az1" {
  value = module.vm_spoke_n-s_az1.vm
}

output "vm_spoke_n-s_az2" {
  value = module.vm_spoke_n-s_az2.vm
}

output "vm_hub" {
  value = module.vm_hub.vm
}

output "UPDATE_routes_to_CNF_GWLBe" {
  value = {
    vpc_cnf_tgw = module.fgt_cnf_vpc.routes_ids["tgw"]
    vpc_n-s_vm  = module.spoke_vpc_n-s.routes_ids["vm"]
    vpc_n-s_igw = module.spoke_vpc_n-s.routes_ids["igw"]
  }
}