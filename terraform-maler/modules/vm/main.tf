# =============================================
# PUBLIC IP (optional)
# =============================================

resource "azurerm_public_ip" "this" {
  count               = var.create_public_ip ? 1 : 0
  name                = "pip-${var.vm_name}"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = var.tags
}

# =============================================
# NETWORK INTERFACE
# =============================================

resource "azurerm_network_interface" "this" {
  name                = "nic-${var.vm_name}"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = var.create_public_ip ? azurerm_public_ip.this[0].id : null
  }

  tags = var.tags
}

# =============================================
# VIRTUAL MACHINE
# =============================================

resource "azurerm_linux_virtual_machine" "this" {
  name                            = var.vm_name
  resource_group_name             = var.resource_group_name
  location                        = var.location
  size                            = var.vm_size
  admin_username                  = var.admin_username
  disable_password_authentication = var.auth_type == "ssh"

  network_interface_ids = [azurerm_network_interface.this.id]

  admin_password = var.auth_type == "password" ? var.admin_password : null

  dynamic "admin_ssh_key" {
    for_each = var.auth_type == "ssh" ? [1] : []
    content {
      username   = var.admin_username
      public_key = var.ssh_public_key
    }
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = var.os_disk_type
  }

  source_image_reference {
    publisher = var.image_publisher
    offer     = var.image_offer
    sku       = var.image_sku
    version   = "latest"
  }

  custom_data = var.startup_script != "" ? base64encode(var.startup_script) : null

  tags = var.tags
}

# =============================================
# DATA DISKS (optional)
# =============================================

resource "azurerm_managed_disk" "this" {
  count                = length(var.data_disks)
  name                 = "disk-${var.vm_name}-${count.index + 1}"
  location             = var.location
  resource_group_name  = var.resource_group_name
  storage_account_type = var.data_disks[count.index].type
  create_option        = "Empty"
  disk_size_gb         = var.data_disks[count.index].size_gb

  tags = var.tags
}

resource "azurerm_virtual_machine_data_disk_attachment" "this" {
  count              = length(var.data_disks)
  managed_disk_id    = azurerm_managed_disk.this[count.index].id
  virtual_machine_id = azurerm_linux_virtual_machine.this.id
  lun                = count.index
  caching            = "ReadWrite"
}

# =============================================
# INPUT VALIDATION
# =============================================

locals {
  validate_password = (
    var.auth_type == "password" && var.admin_password == null
    ? tobool("admin_password must be set when auth_type is 'password'")
    : true
  )
  validate_ssh = (
    var.auth_type == "ssh" && var.ssh_public_key == null
    ? tobool("ssh_public_key must be set when auth_type is 'ssh'")
    : true
  )
}