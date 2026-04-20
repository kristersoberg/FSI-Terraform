# Modul: loadbalancer

Oppretter en intern Azure Load Balancer (Standard SKU) som fordeler trafikk mellom flere backend-servere og automatisk ruter rundt servere som er nede.

## Hva denne malen oppretter

| Ressurs | Navn | Beskrivelse |
|---------|------|-------------|
| Load Balancer | `lb-{lb_name}-{environment}` | Intern Azure LB (Standard SKU) |
| Backend pool | `backend-pool` | Gruppe av backend-servere |
| Health probe | `health-probe` | Sjekker om serverne svarer på `backend_port` |
| LB-regel | `lb-rule` | Videresender trafikk til sunne servere |

## Hvordan det fungerer

```
Web-VM
  │  kobler til lb_ip:3306
  ▼
[Lastbalanserer 10.0.2.100]
  │  health probe: er server oppe?
  ├──▶ DB VM 1 (10.0.2.4) ✅ svarer → får trafikk
  └──▶ DB VM 2 (10.0.2.5) ❌ nede  → hoppes over
```

Health proben sjekker hvert 5. sekund. Hvis en server ikke svarer på 2 påfølgende sjekker, tas den ut av rotasjonen automatisk.

## Bruk

```hcl
module "loadbalancer" {
  source = "github.com/DITT-BRUKERNAVN/terraform-maler//modules/loadbalancer"

  resource_group_name = "mitt-prosjekt-rg"
  location            = "norwayeast"
  environment         = "dev"
  lb_name             = "database"

  # Outputs fra network-modulen
  subnet_id  = module.network.db_subnet_id
  vnet_id    = module.network.vnet_id

  # Outputs fra vm-modulen (liste med private IP-er)
  backend_ips = [
    module.db_vm_1.private_ip,
    module.db_vm_2.private_ip
  ]

  frontend_ip  = "10.0.2.100"  # Fast IP innenfor db-subnet
  backend_port = 3306           # MySQL
}
```

## Variabler

| Navn | Påkrevd | Standard | Beskrivelse |
|------|---------|----------|-------------|
| `resource_group_name` | ✅ | – | Navn på Azure resource group |
| `location` | ✅ | – | Azure-region |
| `environment` | ✅ | – | Miljønavn |
| `subnet_id` | ✅ | – | Subnet-ID fra network-modulen |
| `vnet_id` | ✅ | – | VNet-ID fra network-modulen |
| `backend_ips` | ✅ | – | Liste med private IP-er fra vm-modulen |
| `lb_name` | ❌ | `internal` | Navn-del i ressursnavnet |
| `frontend_ip` | ❌ | `10.0.2.100` | Fast privat IP til LB |
| `backend_port` | ❌ | `3306` | Port som lastbalanseres |

## Outputs

| Navn | Beskrivelse |
|------|-------------|
| `lb_ip` | Privat IP til LB – web-VM bruker denne som database-host |
| `lb_id` | ID til lastbalansereren |
| `backend_pool_id` | ID til backend-poolen |

## Dataflyten mellom moduler

```
network-modul
  ├── output: db_subnet_id  ──▶ loadbalancer-modul (subnet_id)
  └── output: vnet_id       ──▶ loadbalancer-modul (vnet_id)

vm-modul (db_vm_1 og db_vm_2)
  └── output: private_ip    ──▶ loadbalancer-modul (backend_ips)

loadbalancer-modul
  └── output: lb_ip         ──▶ web-VM bruker denne som DB_HOST
```
