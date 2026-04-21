# Web + MySQL High Availability — Azure Terraform Deployment

This project deploys a web service backed by two MySQL database VMs behind an internal load balancer on Azure, using Terraform.

## Architecture

```
Internet
    │
    ▼ port 80
Web VM (nginx → Flask)       web-subnet  10.0.1.0/24
    │
    │ port 3306
    ▼
Internal Load Balancer       database-subnet  10.0.2.0/24
    ├── MySQL VM 1
    └── MySQL VM 2
```

- The web VM is publicly reachable on port 80. SSH access is restricted to a configurable admin IP.
- The database VMs have no public IP and accept only MySQL traffic from the web subnet.

---

## Prerequisites

- [Terraform](https://developer.hashicorp.com/terraform/install) >= 1.5.0
- [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli)
- PowerShell (Windows)

---

## Step 1 — Generate an SSH key pair

```powershell
ssh-keygen -t rsa -b 4096 -f "$env:USERPROFILE\.ssh\fsi-project"
```

Keep the private key (`fsi-project`) on your machine. You will need the public key (`fsi-project.pub`) in the next step:

```powershell
Get-Content "$env:USERPROFILE\.ssh\fsi-project.pub"
```

---

## Step 2 — Create your secrets file

Copy the example file and fill in your values:

```powershell
Copy-Item secrets.tfvars.example secrets.tfvars
```

Open `secrets.tfvars` and fill in:

| Variable | How to find it |
|----------|---------------|
| `subscription_id` | Run `az account show` after logging in |
| `tenant_id` | Run `az account show` after logging in |
| `admin_ssh_public_key` | Output of `Get-Content "$env:USERPROFILE\.ssh\fsi-project.pub"` |
| `mysql_app_password` | Choose a strong password |
| `admin_source_ip` | Your public IP in CIDR notation — see below |

Find your public IP:

```powershell
(Invoke-WebRequest -Uri "https://api.ipify.org").Content
```

Use the result as `admin_source_ip`, e.g. `"1.2.3.4/32"`.

> `secrets.tfvars` is gitignored and must never be committed.

---

## Step 3 — Log in to Azure

```powershell
az login
az account show
```

If you have multiple subscriptions, set the correct one:

```powershell
az account set --subscription "<subscription-id>"
```

---

## Step 4 — Deploy

```powershell
cd C:\Path\To\FSI-Terraform\Prosjektmappe-oppgave2

terraform init
terraform validate
terraform plan -var-file="secrets.tfvars"
terraform apply -var-file="secrets.tfvars"
```

Type `yes` when prompted. Terraform will print the web VM's public IP when complete.

> **Note:** If the apply fails with `SkuNotAvailable`, the selected VM size is out of capacity in your region. Check what is available and update `terraform.tfvars`:
> ```powershell
> az vm list-skus --location norwayeast --resource-type virtualMachines --output table | findstr /i "Standard_B"
> ```
> Update `web_vm_size` and `db_vm_size` in `terraform.tfvars`, then re-run apply.

---

## Step 5 — Verify

Wait **3–5 minutes** after apply completes. The VMs run their setup scripts on first boot — MySQL and nginx are not immediately ready.

Open a browser and navigate to:

```
http://<web_public_ip>
```

You should see a page showing messages fetched from the MySQL database, including which database VM responded.

**Verifying high availability**

Reboot one of the database VMs via the Azure Portal or the Azure CLI, and keep the web page open — it should continue to respond, served by the remaining VM.

```powershell
az vm restart --resource-group rg-webdb-dev --name vm-db-1-dev
```

Check the VM's power status before and after:

```powershell
az vm get-instance-view `
  --resource-group rg-webdb-dev `
  --name vm-db-1-dev `
  --query "instanceView.statuses[1].displayStatus"
```

---

## Optional — Troubleshoot the web VM

SSH into the web VM:

```powershell
ssh -i "$env:USERPROFILE\.ssh\fsi-project" azureuser@<web_public_ip>
```

Useful commands once connected:

```bash
# Is nginx running?
sudo systemctl status nginx

# Is the Flask app running?
sudo systemctl status webapp

# Has cloud-init finished?
sudo cloud-init status

# Is nginx listening on port 80?
sudo ss -tlnp | grep 80

# Is Flask listening on port 5000?
sudo ss -tlnp | grep 5000

# Full cloud-init log
sudo tail -50 /var/log/cloud-init-output.log
```

---

## Clean up

To remove all Azure resources created by this project:

```powershell
terraform destroy -var-file="secrets.tfvars"
```

Type `yes` when prompted.
