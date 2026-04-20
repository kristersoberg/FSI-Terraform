# Module: resource-group

Creates an Azure resource group with an optional delete lock.

## Usage

```hcl
module "rg" {
  source = "https://github.com/kristersoberg/FSI-Terraform/tree/main/terraform-templates/modules/resource-group"

  name     = "my-rg"
  location = "norwayeast"
  lock     = false

  tags = {
    environment = "dev"
  }
}
```

## Delete lock

When `lock = true`, a `CanNotDelete` lock is placed on the resource group.
This prevents the resource group and all resources inside it from being
deleted — even by administrators — until the lock is removed.

To remove the lock, set `lock = false` and run `terraform apply` before
running `terraform destroy`.

## Variables

| Name | Required | Default | Description |
|------|----------|---------|-------------|
| `name` | yes | — | Name of the resource group |
| `location` | yes | — | Azure region |
| `lock` | no | `false` | Protect against accidental deletion |
| `tags` | no | `{}` | Tags to apply to the resource group |

## Outputs

| Name | Description |
|------|-------------|
| `name` | Name of the resource group |
| `id` | Resource ID of the resource group |
| `location` | Location of the resource group |