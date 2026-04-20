# Terraform templates for Azure

A set of reusable Terraform modules for building infrastructure in Azure.
The modules are designed to be combined — outputs from one module feed
directly into inputs of another.

## Modules

| Module | Description |
|--------|-------------|
| [resource-group](./modules/resource-group/) | Resource group with optional delete lock |
| [network](./modules/network/) | VNet, subnets, and NSG rules |
| [vm](./modules/vm/) | Linux VM with optional public IP and data disks |
| [loadbalancer-internal](./modules/loadbalancer-internal/) | Internal load balancer with static private IP |
| [loadbalancer-external](./modules/loadbalancer-external/) | Internet-facing load balancer with public IP |
| [ssh-key](./modules/ssh-key/) | SSH key pair with local or Key Vault storage |

## Requirements

- [Terraform](https://developer.hashicorp.com/terraform/install) >= 1.3.0
- [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli)
- An active Azure subscription

## Getting started

### 1. Log in to Azure

```bash
az login
az account set --subscription "YOUR-SUBSCRIPTION-ID"
```

### 2. Reference a module in your project

```hcl
module "rg" {
  source = "github.com/YOUR-USERNAME/terraform-maler//modules/resource-group"

  name     = "my-rg"
  location = "norwayeast"
}

module "ssh_key" {
  source = "github.com/YOUR-USERNAME/terraform-maler//modules/ssh-key"

  key_name = "my-key"
}

module "network" {
  source = "github.com/YOUR-USERNAME/terraform-maler//modules/network"

  resource_group_name = module.rg.name
  location            = module.rg.location
  environment         = "dev"
  vnet_address_space  = "10.0.0.0/16"

  subnets = [
    {
      name = "web"
      cidr = "10.0.1.0/24"
      nsg_rules = [
        {
          name        = "allow-http"
          priority    = 100
          direction   = "Inbound"
          protocol    = "Tcp"
          port        = 80
          source      = "*"
          destination = "*"
        }
      ]
    }
  ]
}

module "vm" {
  source = "github.com/YOUR-USERNAME/terraform-maler//modules/vm"

  resource_group_name = module.rg.name
  location            = module.rg.location
  vm_name             = "web-vm"
  subnet_id           = module.network.subnet_ids["web"]
  admin_username      = "azureuser"
  auth_type           = "ssh"
  ssh_public_key      = module.ssh_key.public_key

  image_publisher     = "Canonical"
  image_offer         = "0001-com-ubuntu-server-focal"
  image_sku           = "20_04-lts"

  create_public_ip    = true
}
```

### 3. Deploy

```bash
terraform init
terraform plan
terraform apply
```

### 4. Clean up

```bash
terraform destroy
```

## How the modules connect

```
resource-group
  └── name, location ──▶ all other modules

ssh-key
  └── public_key ──▶ vm (ssh_public_key)

network
  ├── subnet_ids["web"] ──▶ vm (subnet_id)
  ├── subnet_ids["db"]  ──▶ vm (subnet_id)
  └── vnet_id           ──▶ loadbalancer-internal / loadbalancer-external (vnet_id)

vm
  └── private_ip ──▶ loadbalancer-internal / loadbalancer-external (backend_ips)
```

## Security notes

- NSG rules are user-defined. A deny-all inbound rule is automatically
  added to every NSG as the last rule.
- SSH key authentication is recommended over password authentication.
- Use `lock = true` on the resource group in production environments.
- Never commit `terraform.tfvars` or private keys to version control.
  Add the following to your `.gitignore`:

```
.terraform/
*.tfstate
*.tfstate.backup
*.tfvars
*.pem
.terraform.lock.hcl
```