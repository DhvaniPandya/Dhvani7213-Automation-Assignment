module "rgroup" {
  source   = "./modules/rgroup"
  rg_name  = "assignment1-RG-7213"
  location = "canadacentral"
  tags     = local.common_tags
}

module "network" {
  source       = "./modules/network"
  rg_name      = module.rgroup.rg_name
  location     = module.rgroup.location_name
  vnet         = "vnet1"
  vnet_space   = ["10.0.0.0/16"]
  subnet       = "subnet"
  subnet_space = ["10.0.0.0/24"]
  nsg          = "nsg1"
  tags         = local.common_tags
  depends_on   = [module.rgroup]
}

module "vmlinux" {
  source = "./modules/vmlinux"
  linux-name = {
    "assign7213-linux1" = "Standard_B1s"
    "assign7213-linux2" = "Standard_B1s"
  }
  linux_avset = "linux-avs"
  rg_name     = module.rgroup.rg_name
  location    = module.rgroup.location_name
  linux_vm_id = module.vmlinux.linux_vm_id
  subnet_id   = module.network.subnet_id
  depends_on  = [module.network]
  tags        = local.common_tags
}

module "vmwindows" {
  source       = "./modules/vmwindows"
  windows_avs  = "windows-avs"
  windows_name = "Windows7213"
  rg_name      = module.rgroup.rg_name
  location     = module.rgroup.location_name
  subnet_id    = module.network.subnet_id
  depends_on   = [module.network]
  tags         = local.common_tags
}

module "datadisk" {
  source           = "./modules/datadisk"
  location         = module.rgroup.location_name
  rg_name          = module.rgroup.rg_name
  linux_name       = module.vmlinux.linux_vm_hostname
  linux_id         = module.vmlinux.linux_vm_id
  windows_datadisk = "assignment-7213-datadisk3-win"
  windows_id       = module.vmwindows.Windows_VM_Id
  tags             = local.common_tags
  depends_on = [
    module.vmwindows,
    module.vmlinux
  ]
}

module "loadbalancer" {
  source            = "./modules/loadbalancer"
  lb_name           = "assignment-7213-loadBalancer"
  public_ip_lb_name = "assignment-7213-publicip-loadbalancer"
  location          = module.rgroup.location_name
  rg_name           = module.rgroup.rg_name
  subnet_id         = module.network.subnet_id
  linux_nic         = module.vmlinux.linux_nic
  windows_nic       = module.vmwindows.Windows_vm_nic
  tags              = local.common_tags
  depends_on = [
    module.vmlinux,
    module.vmwindows
  ]

}

module "common" {
  source                  = "./modules/common"
  recovery_service_vault_name  = "assignemnt-7213-vault"
  log_analytics_workspace_name = "assignment-7213-workspace"
  storage_account_name         = "assignment7213storage"
  location                = module.rgroup.location_name
  rg_name                 = module.rgroup.rg_name
  tags                    = local.common_tags
  depends_on = [
    module.rgroup
  ]

}

module "database" {
  source         = "./modules/database"
  db_server_name = "assignment-7213-db-server"
  db_name        = "assignment-7213-postgre_serverDB"
  location       = module.rgroup.location_name
  rg_name        = module.rgroup.rg_name
  tags           = local.common_tags
  depends_on = [
    module.loadbalancer
  ]

}
