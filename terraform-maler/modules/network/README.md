# Modul: network

Oppretter et fullstendig Azure-nettverk med to subnets og NSG-regler for nettverkssegmentering.

## Hva denne malen oppretter

| Ressurs | Navn | Beskrivelse |
|---------|------|-------------|
| Virtual Network | `vnet-{environment}` | Hovednettverk som inneholder alle subnets |
| Subnet | `web-subnet` | For web-servere, tilgjengelig fra internett |
| Subnet | `db-subnet` | For databaser, kun tilgjengelig fra web-subnet |
| NSG | `web-nsg-{environment}` | Tillater HTTP (80), HTTPS (443) og SSH (22) |
| NSG | `db-nsg-{environment}` | Tillater kun MySQL (3306) fra web-subnet |

### Nettverkssegmentering

```
Internett
    │  port 80/443/22
    ▼
[web-subnet 10.0.1.0/24]  ──── port 3306 ────▶  [db-subnet 10.0.2.0/24]
    NSG: åpen for web                               NSG: blokkert for alt annet
```

Databaseserverne er **ikke** tilgjengelige fra internett – kun web-serverne kan nå dem.

## Bruk

```hcl
module "network" {
  source = "github.com/DITT-BRUKERNAVN/terraform-maler//modules/network"

  resource_group_name = "mitt-prosjekt-rg"
  location            = "norwayeast"
  environment         = "dev"
}
```

### Med egne CIDR-blokker

```hcl
module "network" {
  source = "github.com/DITT-BRUKERNAVN/terraform-maler//modules/network"

  resource_group_name = "mitt-prosjekt-rg"
  location            = "norwayeast"
  environment         = "prod"
  vnet_address_space  = "10.10.0.0/16"
  web_subnet_prefix   = "10.10.1.0/24"
  db_subnet_prefix    = "10.10.2.0/24"
  ssh_source_address  = "192.168.1.100/32"  # Begrens SSH til din IP
}
```

## Variabler

| Navn | Påkrevd | Standard | Beskrivelse |
|------|---------|----------|-------------|
| `resource_group_name` | ✅ | – | Navn på Azure resource group |
| `location` | ✅ | – | Azure-region |
| `environment` | ✅ | – | Miljønavn (dev/prod) |
| `vnet_address_space` | ❌ | `10.0.0.0/16` | CIDR for hele VNet |
| `web_subnet_prefix` | ❌ | `10.0.1.0/24` | CIDR for web-subnet |
| `db_subnet_prefix` | ❌ | `10.0.2.0/24` | CIDR for db-subnet |
| `ssh_source_address` | ❌ | `*` | IP med SSH-tilgang (anbefal din egen IP) |

## Outputs

| Navn | Beskrivelse |
|------|-------------|
| `vnet_id` | ID til VNet – brukes av andre ressurser |
| `vnet_name` | Navn på VNet |
| `web_subnet_id` | Sendes videre til `vm`-modulen for web-VM |
| `db_subnet_id` | Sendes videre til `vm`- og `loadbalancer`-modulen |

## Sikkerhetsnotater

- SSH-regelen i web-NSG er satt til `*` som standard. **I produksjon bør du sette `ssh_source_address` til din egen IP-adresse** for å unngå eksponering.
- DB-subnettet har en eksplisitt "Deny All"-regel som siste prioritet – all trafikk som ikke matcher MySQL-regelen vil bli blokkert.
