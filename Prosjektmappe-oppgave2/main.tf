module "resource_group" {
  source   = "./modules/resource-group"
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

module "network" {
  source              = "./modules/network"
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  environment         = var.environment
  vnet_address_space  = var.vnet_address_space
  tags                = var.tags

  subnets = [
    {
      name = "web-subnet"
      cidr = var.web_subnet_cidr
      nsg_rules = [
        {
          name        = "allow-http-from-internet"
          priority    = 100
          direction   = "Inbound"
          protocol    = "Tcp"
          port        = 80
          source      = "*"
          destination = "*"
        },
        {
          name        = "allow-ssh-from-admin"
          priority    = 110
          direction   = "Inbound"
          protocol    = "Tcp"
          port        = 22
          source      = var.admin_source_ip
          destination = "*"
        }
      ]
    },
    {
      name = "database-subnet"
      cidr = var.database_subnet_cidr
      nsg_rules = [
        {
          name        = "allow-lb-health-probe"
          priority    = 100
          direction   = "Inbound"
          protocol    = "Tcp"
          port        = 3306
          source      = "AzureLoadBalancer"
          destination = "*"
        },
        {
          name        = "allow-mysql-from-web-subnet"
          priority    = 110
          direction   = "Inbound"
          protocol    = "Tcp"
          port        = 3306
          source      = var.web_subnet_cidr
          destination = "*"
        }
      ]
    }
  ]
}

# -----------------------------------------------
# Database VMs
# -----------------------------------------------

module "vm_db_1" {
  source              = "./modules/vm"
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  vm_name             = "vm-db-1-${var.environment}"
  subnet_id           = module.network.subnet_ids["database-subnet"]
  private_ip_address  = var.db_1_private_ip
  admin_username      = var.admin_username
  auth_type           = "ssh"
  ssh_public_key      = var.admin_ssh_public_key
  vm_size             = var.db_vm_size
  create_public_ip    = false
  image_publisher     = "Canonical"
  image_offer         = "0001-com-ubuntu-server-jammy"
  image_sku           = "22_04-lts-gen2"
  tags                = var.tags

  startup_script = templatefile("${path.module}/scripts/mysql-init.sh.tpl", {
    mysql_app_password = var.mysql_app_password
  })
}

module "vm_db_2" {
  source              = "./modules/vm"
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  vm_name             = "vm-db-2-${var.environment}"
  subnet_id           = module.network.subnet_ids["database-subnet"]
  private_ip_address  = var.db_2_private_ip
  admin_username      = var.admin_username
  auth_type           = "ssh"
  ssh_public_key      = var.admin_ssh_public_key
  vm_size             = var.db_vm_size
  create_public_ip    = false
  image_publisher     = "Canonical"
  image_offer         = "0001-com-ubuntu-server-jammy"
  image_sku           = "22_04-lts-gen2"
  tags                = var.tags

  startup_script = templatefile("${path.module}/scripts/mysql-init.sh.tpl", {
    mysql_app_password = var.mysql_app_password
  })
}

# -----------------------------------------------
# Internal load balancer (sits in front of the two DB VMs)
# -----------------------------------------------

module "loadbalancer_internal" {
  source              = "./modules/loadbalancer-internal"
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  environment         = var.environment
  subnet_id           = module.network.subnet_ids["database-subnet"]
  vnet_id             = module.network.vnet_id
  frontend_private_ip = var.lb_frontend_ip
  tags                = var.tags

  backend_ips = [
    module.vm_db_1.private_ip,
    module.vm_db_2.private_ip,
  ]

  rules = [
    {
      name           = "mysql"
      frontend_port  = 3306
      backend_port   = 3306
      protocol       = "Tcp"
      probe_protocol = "Tcp"
      probe_port     = 3306
    }
  ]
}

# -----------------------------------------------
# Web VM
# -----------------------------------------------

module "vm_web" {
  source              = "./modules/vm"
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  vm_name             = "vm-web-${var.environment}"
  subnet_id           = module.network.subnet_ids["web-subnet"]
  private_ip_address  = var.web_vm_private_ip
  admin_username      = var.admin_username
  auth_type           = "ssh"
  ssh_public_key      = var.admin_ssh_public_key
  vm_size             = var.web_vm_size
  create_public_ip    = true
  image_publisher     = "Canonical"
  image_offer         = "0001-com-ubuntu-server-jammy"
  image_sku           = "22_04-lts-gen2"
  tags                = var.tags

  startup_script = templatefile("${path.module}/scripts/web-init.sh.tpl", {
    db_host            = var.lb_frontend_ip
    mysql_app_password = var.mysql_app_password
  })
}
