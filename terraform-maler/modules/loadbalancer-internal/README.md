# Module: loadbalancer-internal

Creates an internal Azure Load Balancer with a static private frontend IP,
a backend pool, health probes, and load balancing rules.
Traffic is distributed across all healthy backends using round-robin.

## Requirements

- An existing resource group
- A subnet ID to place the load balancer in
- The VNet ID the backends belong to
- Private IP addresses of the backend VMs

## Usage

```hcl
module "lb_internal" {
  source = "github.com/YOUR-USERNAME/terraform-maler//modules/loadbalancer-internal"

  resource_group_name = "my-rg"
  location            = "norwayeast"
  environment         = "dev"

  subnet_id           = module.network.subnet_ids["db"]
  vnet_id             = module.network.vnet_id
  frontend_private_ip = "10.0.2.100"

  backend_ips = [
    module.db_vm_1.private_ip,
    module.db_vm_2.private_ip
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

  tags = {
    environment = "dev"
  }
}
```

## Health probes

Each rule has its own health probe. The probe checks whether the backend
is responding on `probe_port` every 5 seconds. A backend is removed from
rotation after 2 consecutive failed checks, and re-added once it starts
responding again.

| probe_protocol | Use when |
|----------------|----------|
| `Tcp` | Any TCP service (MySQL, PostgreSQL, etc.) |
| `Http` | HTTP services — probe expects a 200 response |
| `Https` | HTTPS services — probe expects a 200 response |

## Frontend IP

The frontend IP must be a static private IP within the subnet CIDR.
Make sure the address is not already in use by another resource.

Example: if `subnet_id` points to a subnet with CIDR `10.0.2.0/24`,
a valid frontend IP would be `10.0.2.100`.

## Variables

| Name | Required | Default | Description |
|------|----------|---------|-------------|
| `resource_group_name` | yes | — | Resource group to deploy into |
| `location` | yes | — | Azure region |
| `environment` | yes | — | Used in resource names |
| `subnet_id` | yes | — | Subnet the load balancer will be placed in |
| `vnet_id` | yes | — | VNet the backends belong to |
| `frontend_private_ip` | yes | — | Static private IP for the frontend |
| `backend_ips` | yes | — | List of backend private IP addresses |
| `rules` | yes | — | List of load balancing rules |
| `tags` | no | `{}` | Tags to apply to all resources |

## Rules object

| Field | Description |
|-------|-------------|
| `name` | Unique name for the rule |
| `frontend_port` | Port the load balancer listens on |
| `backend_port` | Port traffic is forwarded to on the backend |
| `protocol` | `"Tcp"` or `"Udp"` |
| `probe_protocol` | `"Tcp"`, `"Http"` or `"Https"` |
| `probe_port` | Port the health probe checks |

## Outputs

| Name | Description |
|------|-------------|
| `lb_id` | Resource ID of the load balancer |
| `frontend_ip` | Private IP address of the frontend |
| `backend_pool_id` | ID of the backend address pool |