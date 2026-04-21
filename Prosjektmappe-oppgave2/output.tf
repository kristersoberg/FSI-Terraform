output "web_public_ip" {
  description = "Public IP of the web VM — open this in a browser to verify the setup"
  value       = module.vm_web.public_ip
}

output "web_ssh" {
  description = "SSH command to connect to the web VM"
  value       = "ssh -i ~/.ssh/fsi-project ${var.admin_username}@${module.vm_web.public_ip}"
}

output "db_1_private_ip" {
  description = "Private IP of database VM 1"
  value       = module.vm_db_1.private_ip
}

output "db_2_private_ip" {
  description = "Private IP of database VM 2"
  value       = module.vm_db_2.private_ip
}

output "lb_frontend_ip" {
  description = "Internal load balancer frontend IP (what Flask connects to)"
  value       = var.lb_frontend_ip
}
