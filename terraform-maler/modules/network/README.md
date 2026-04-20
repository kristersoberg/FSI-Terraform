# Module: network

Creates a virtual network with one or more subnets. Each subnet gets its own
Network Security Group with user-defined rules. A deny-all inbound rule is
automatically added to every NSG as the last rule.

## Requirements

- An existing resource group

## Usage

```hcl
module "network" {
  source = "https://github.com/kristersoberg/FSI-Terraform/tree/main/terraform-maler/modules/network"

  resource_group_name = "my-rg"
  location            = "norwayeast"
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
        },
        {
          name        = "allow-ssh"
          priority    = 110
          direction   = "Inbound"
          protocol    = "Tcp"
          port        = 22
          source      = "your-ip/32"
          destination = "*"
        }
      ]
    },
    {
      name = "db"
      cidr = "10.0.2.0/24"
      nsg_rules = [
        {
          name        = "allow-mysql"
          priority    = 100
          direction   = "Inbound"
          protocol    = "Tcp"
          port        = 3306
          source      = "10.0.1.0/24"
          destination = "*"
        }
      ]
    }
  ]

  tags = {
    environment = "dev"
  }
}
```

## NSG rules

Each rule in `nsg_rules` creates an **Allow** rule in the NSG.
A **Deny all inbound** rule is automatically added at priority 4096 —
any traffic not matched by your rules will be blocked.

| Field | Description |
|-------|-------------|
| `name` | Unique name for the rule within the NSG |
| `priority` | Between 100–4095. Lower number = evaluated first |
| `direction` | `"Inbound"` or `"Outbound"` |
| `protocol` | `"Tcp"`, `"Udp"` or `"*"` |
| `port` | Single port number |
| `source` | Source IP, CIDR or `"*"` |
| `destination` | Destination IP, CIDR or `"*"` |

## Accessing subnet IDs in other modules

This module outputs a map of subnet names to IDs.
Reference a specific subnet like this:

```hcl
subnet_id = module.network.subnet_ids["web"]
subnet_id = module.network.subnet_ids["db"]
```

## Variables

| Name | Required | Default | Description |
|------|----------|---------|-------------|
| `resource_group_name` | yes | — | Resource group to deploy into |
| `location` | yes | — | Azure region |
| `environment` | yes | — | Used in resource names |
| `vnet_address_space` | yes | — | CIDR block for the VNet |
| `subnets` | yes | — | List of subnets with NSG rules |
| `tags` | no | `{}` | Tags to apply to all resources |

## Outputs

| Name | Description |
|------|-------------|
| `vnet_id` | Resource ID of the virtual network |
| `vnet_name` | Name of the virtual network |
| `subnet_ids` | Map of subnet name to subnet ID |
| `nsg_ids` | Map of subnet name to NSG ID |