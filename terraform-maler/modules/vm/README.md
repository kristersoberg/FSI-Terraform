# Modul: vm

Oppretter en Linux VM (Ubuntu 20.04) i Azure med valgfri offentlig IP og støtte for oppstartsskript.

## Hva denne malen oppretter

| Ressurs | Navn | Beskrivelse |
|---------|------|-------------|
| Linux VM | `{vm_name}` | Ubuntu 20.04 LTS |
| Nettverkskort (NIC) | `nic-{vm_name}` | Kobler VM til subnet |
| Offentlig IP | `pip-{vm_name}` | Kun hvis `create_public_ip = true` |

## Bruk

### Web-server (med offentlig IP)

```hcl
module "web_vm" {
  source = "github.com/DITT-BRUKERNAVN/terraform-maler//modules/vm"

  resource_group_name = "mitt-prosjekt-rg"
  location            = "norwayeast"
  vm_name             = "web-vm"
  admin_username      = "azureuser"
  admin_password      = var.admin_password
  subnet_id           = module.network.web_subnet_id  # Output fra network-modulen
  create_public_ip    = true
  vm_role             = "web"

  startup_script = <<-EOF
    #!/bin/bash
    apt-get update -y
    apt-get install -y python3-pip python3-flask
    # Legg til din applikasjonsinstallasjon her
  EOF
}
```

### Database-server (kun privat IP)

```hcl
module "db_vm" {
  source = "github.com/DITT-BRUKERNAVN/terraform-maler//modules/vm"

  resource_group_name = "mitt-prosjekt-rg"
  location            = "norwayeast"
  vm_name             = "db-vm-1"
  admin_username      = "azureuser"
  admin_password      = var.admin_password
  subnet_id           = module.network.db_subnet_id  # Output fra network-modulen
  create_public_ip    = false
  vm_role             = "database"

  startup_script = <<-EOF
    #!/bin/bash
    apt-get update -y
    DEBIAN_FRONTEND=noninteractive apt-get install -y mysql-server
    sed -i 's/bind-address.*/bind-address = 0.0.0.0/' /etc/mysql/mysql.conf.d/mysqld.cnf
    systemctl restart mysql
  EOF
}
```

## Variabler

| Navn | Påkrevd | Standard | Beskrivelse |
|------|---------|----------|-------------|
| `resource_group_name` | ✅ | – | Navn på Azure resource group |
| `location` | ✅ | – | Azure-region |
| `vm_name` | ✅ | – | Navn på VM-en |
| `admin_password` | ✅ | – | Passord for admin-brukeren |
| `subnet_id` | ✅ | – | Subnet-ID fra network-modulen |
| `vm_size` | ❌ | `Standard_B1s` | Azure VM-størrelse |
| `admin_username` | ❌ | `azureuser` | Admin-brukernavn |
| `create_public_ip` | ❌ | `false` | Gir VM en offentlig IP |
| `startup_script` | ❌ | `""` | Bash-script ved oppstart |
| `vm_role` | ❌ | `general` | Rolle-tag for Azure-portalen |

## Outputs

| Navn | Beskrivelse |
|------|-------------|
| `vm_id` | VM-ID – brukes av loadbalancer-modulen |
| `private_ip` | Privat IP – brukes som input til loadbalancer-modulen |
| `public_ip` | Offentlig IP (null hvis `create_public_ip = false`) |
| `nic_id` | ID til nettverkskortet |

## Dataflyten mellom moduler

Denne modulen avhenger av `network`-modulen og leverer data videre til `loadbalancer`-modulen:

```
network-modul
  └── output: web_subnet_id / db_subnet_id
        └──▶ vm-modul (subnet_id)
               └── output: private_ip
                     └──▶ loadbalancer-modul
```

## Støttede VM-størrelser

| Størrelse | vCPU | RAM | Anbefalt bruk |
|-----------|------|-----|---------------|
| `Standard_B1s` | 1 | 1 GB | Utvikling/test |
| `Standard_B2s` | 2 | 4 GB | Lett produksjon |
| `Standard_B4ms` | 4 | 16 GB | Produksjon |
