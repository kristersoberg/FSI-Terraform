location             = "norwayeast"
environment          = "dev"
resource_group_name  = "rg-webdb-dev"

vnet_address_space   = "10.0.0.0/16"
web_subnet_cidr      = "10.0.1.0/24"
database_subnet_cidr = "10.0.2.0/24"
lb_frontend_ip    = "10.0.2.10"
web_vm_private_ip = "10.0.1.10"
db_1_private_ip   = "10.0.2.21"
db_2_private_ip   = "10.0.2.22"

admin_username = "azureuser"
web_vm_size    = "Standard_B2s_v2"
db_vm_size     = "Standard_B2s_v2"

tags = {
  project     = "webdb"
  environment = "dev"
  managed_by  = "terraform"
}
