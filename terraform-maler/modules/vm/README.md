# Module: vm

Creates a virtual machine in Azure with a network interface, 
optional public IP, and optional extra data disks.

## Requirements

- An existing resource group
- A subnet ID to place the VM in

## Usage

```hcl
module "example" {
  source = "github.com/kristersoberg/FSI-Terraform/terraform-maler//modules/vm"

  # Required
  resource_group_name = "my-rg"
  location            = "norwayeast"
  vm_name             = "my-vm"
  subnet_id           = "<subnet-id>"
  admin_username      = "azureuser"

  # OS image — see image reference below
  image_publisher     = "Canonical"
  image_offer         = "0001-com-ubuntu-server-focal"
  image_sku           = "20_04-lts"

  # Authentication — choose one
  auth_type           = "ssh"
  ssh_public_key      = file("~/.ssh/id_rsa.pub")
  # auth_type         = "password"
  # admin_password    = var.admin_password

  # Optional
  vm_size             = "Standard_B1s"
  create_public_ip    = false
  os_disk_type        = "Standard_LRS"

  startup_script = <<-EOF
    #!/bin/bash
    apt-get update -y
    apt-get install -y nginx
  EOF

  data_disks = [
    { size_gb = 64, type = "Premium_LRS" }
  ]

  tags = {
    environment = "dev"
  }
}
```

## Authentication

Set `auth_type` to either `"ssh"` or `"password"`, then provide the matching credential.

- `auth_type = "ssh"` — provide `ssh_public_key`. Password login will be disabled.
- `auth_type = "password"` — provide `admin_password`. Never hardcode this value — 
  use a variable and set it via `terraform.tfvars` or the environment:
  `export TF_VAR_<variable_name>="your-value"`

## Variables

| Name | Required | Default | Description |
|------|----------|---------|-------------|
| `resource_group_name` | yes | — | Resource group to deploy into |
| `location` | yes | — | Azure region |
| `vm_name` | yes | — | Name of the VM |
| `subnet_id` | yes | — | Subnet the VM will be placed in |
| `admin_username` | yes | — | Administrator username |
| `image_publisher` | yes | — | OS image publisher |
| `image_offer` | yes | — | OS image offer |
| `image_sku` | yes | — | OS image SKU |
| `auth_type` | no | `"ssh"` | `"ssh"` or `"password"` |
| `ssh_public_key` | no | `null` | Required if `auth_type = "ssh"` |
| `admin_password` | no | `null` | Required if `auth_type = "password"` |
| `vm_size` | no | `"Standard_B1s"` | Azure VM size |
| `create_public_ip` | no | `false` | Attach a public IP to the VM |
| `os_disk_type` | no | `"Standard_LRS"` | OS disk type |
| `startup_script` | no | `""` | Bash script to run on first boot |
| `data_disks` | no | `[]` | List of extra disks to attach |
| `tags` | no | `{}` | Tags to apply to all resources |

## Outputs

| Name | Description |
|------|-------------|
| `vm_id` | Resource ID of the VM |
| `vm_name` | Name of the VM |
| `private_ip` | Private IP address |
| `public_ip` | Public IP address (null if `create_public_ip = false`) |
| `nic_id` | Network interface ID |
| `data_disk_ids` | List of attached data disk IDs |

## OS image reference

| OS | publisher | offer | sku |
|----|-----------|-------|-----|
| Ubuntu 20.04 | `Canonical` | `0001-com-ubuntu-server-focal` | `20_04-lts` |
| Ubuntu 22.04 | `Canonical` | `0001-com-ubuntu-server-jammy` | `22_04-lts` |
| Debian 11 | `Debian` | `debian-11` | `11-gen2` |
| Debian 12 | `Debian` | `debian-12` | `12-gen2` |

To find other images: `az vm image list --output table`