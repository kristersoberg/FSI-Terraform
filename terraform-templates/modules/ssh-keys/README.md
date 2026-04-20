# Module: ssh-key

Generates an RSA 4096-bit SSH key pair and stores the private key either
locally on disk or in Azure Key Vault. The public key is output directly
for use with the vm module.

## Requirements

- For `storage_type = "keyvault"`: an existing Azure Key Vault with
  sufficient access permissions for the Terraform service principal

## Usage

### Local storage (development)

```hcl
module "ssh_key" {
  source = "github.com/YOUR-USERNAME/terraform-maler//modules/ssh-key"

  key_name       = "my-key"
  storage_type   = "local"
  local_key_path = "~/.ssh"
}

module "vm" {
  source = "github.com/YOUR-USERNAME/terraform-maler//modules/vm"

  # Pass the public key directly from the ssh-key module
  auth_type      = "ssh"
  ssh_public_key = module.ssh_key.public_key

  # ... other variables
}
```

### Key Vault storage (production)

```hcl
module "ssh_key" {
  source = "github.com/YOUR-USERNAME/terraform-maler//modules/ssh-key"

  key_name      = "my-key"
  storage_type  = "keyvault"
  keyvault_id   = "/subscriptions/.../resourceGroups/.../providers/Microsoft.KeyVault/vaults/my-vault"

  tags = {
    environment = "prod"
  }
}

module "vm" {
  source = "https://github.com/kristersoberg/FSI-Terraform/tree/main/terraform-templates/modules/ssh-keys"

  auth_type      = "ssh"
  ssh_public_key = module.ssh_key.public_key

  # ... other variables
}
```

## Connecting to a VM after deployment

```bash
ssh -i ~/.ssh/my-key.pem azureuser@<public-ip>
```

If using Key Vault, retrieve the private key first:

```bash
az keyvault secret show \
  --vault-name <vault-name> \
  --name my-key-private-key \
  --query value -o tsv > ~/.ssh/my-key.pem

chmod 600 ~/.ssh/my-key.pem
ssh -i ~/.ssh/my-key.pem azureuser@<public-ip>
```

## Additional provider required

This module uses the `tls` and `local` Terraform providers.
Add the following to your `provider.tf`:

```hcl
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.0"
    }
  }
}
```

## Variables

| Name | Required | Default | Description |
|------|----------|---------|-------------|
| `key_name` | yes | — | Name of the SSH key pair |
| `storage_type` | no | `"local"` | `"local"` or `"keyvault"` |
| `local_key_path` | no | `"~/.ssh"` | Directory to save the private key |
| `keyvault_id` | no | `null` | Required when `storage_type = "keyvault"` |
| `tags` | no | `{}` | Tags to apply to all resources |

## Outputs

| Name | Description |
|------|-------------|
| `public_key` | Public key — pass to vm module as `ssh_public_key` |
| `private_key_path` | Path to private key on disk (null if storage_type = `keyvault`) |
| `private_key_secret_id` | Key Vault secret ID (null if storage_type = `local`) |