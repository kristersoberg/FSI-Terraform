#variables.tf

variable "subid" {
	description = "Subscription ID"
	type        = string
	default	  = "SETT INN SUBSCRIPTION ID HER!!!!"
	#Hvis default ikke er satt henter den fra terraform.tfvars

}

variable "lokasjon" {
	description = "Azure regionen hvor ressursene skal opprettes"
	type        = string
	default     = "Norway East"
}

variable "ressurs_gruppe_navn" {
	description = "Navnet på ressursgruppa"
	type        = string
	#default	  = "Ressurs_Gruppe_1"
	#Hvis default ikke er satt henter den fra terraform.tfvars

}

variable "vnet_navn" {
	description = "Navnet på nettverket"
	type        = string
	#default	  = "Net1"
	#Hvis default ikke er satt henter den fra terraform.tfvars

}

variable "ip_range" {
	description = "Adresseområde for Net1"
	type        = list(string)
	#default     = ["192.168.100.0/24"]
	#Hvis default ikke er satt henter den fra terraform.tfvars
}

variable "subnet_navn" {
	description = "Subnettnavn tilgjengelig for Net1"
	type = list(string)
	#default = ["Net1_1", "Net1_2"]
	#Hvis default ikke er satt henter den fra terraform.tfvars

}

variable "subnet_ranges" {
	description = "Subnettranges tilgjengelig for Net1"
	type = list(string)
	#default = ["192.168.100.0/25", "192.168.100.128/25"]
	#Hvis default ikke er satt henter den fra terraform.tfvars

}