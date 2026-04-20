# Module: loadbalancer-external

Creates an internet-facing Azure Load Balancer with a static public frontend IP,
a backend pool, health probes, and load balancing rules.
Traffic is distributed across all healthy backends using round-robin.

## Requirements

- An existing resource group
- The VNet ID the backends belong to
- Private IP addresses of the backend VMs

## Usage

```hcl
module "lb_external" {
  source = "https://github.com/kristersoberg/FSI-Terraform/tree/main/terraform-maler/modules/loadbalancer-external"

  resource_group_name = "my-rg"
  location            = "norwayeast"
  environment         = "dev"

  vnet_id     = module.network.vnet_id

  backend_ips = [
    module.web_vm_1.private_ip,
    module.web_vm_2.private_ip
  ]

  rules = [
    {
      name           = "http"
      frontend_port  = 80
      backend_port   = 80
      protocol       = "Tcp"
      probe_protocol = "Http"
      probe_port     = 80
    },
    {
      name           = "https"
      frontend_port  = 443
      backend_port   = 443
      protocol       = "Tcp"
      probe_protocol = "Https"
      probe_port     = 443
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
| `Tcp` | Any TCP service |
| `Http` | HTTP services — probe expects a 200 response |
| `Https` | HTTPS services — probe expects a 200 response |

## Frontend IP

The public IP is automatically created and named `pip-lb-{environment}`.
It uses the Standard SKU, which means the address is always static —
Azure assigns it on first deployment and it does not change.

The assigned address is available via the `frontend_ip` output after deployment:

```bash
terraform output frontend_ip
```

## Variables

| Name | Required | Default | Description |
|------|----------|---------|-------------|
| `resource_group_name` | yes | — | Resource group to deploy into |
| `location` | yes | — | Azure region |
| `environment` | yes | — | Used in resource names |
| `vnet_id` | yes | — | VNet the backends belong to |
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
| `frontend_ip` | Public IP address of the load balancer |
| `public_ip_id` | Resource ID of the public IP |
| `backend_pool_id` | ID of the backend address pool |