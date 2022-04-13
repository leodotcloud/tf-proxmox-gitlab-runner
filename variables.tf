variable "proxmox_api_url" {
  type        = string
  sensitive   = true
  description = "Please enter Proxmox API URL"
}

variable "proxmox_api_token_id" {
  type      = string
  sensitive = true
}

variable "proxmox_api_token_secret" {
  type      = string
  sensitive = true
}

variable "use_insecure_connection" {
  type        = bool
  description = "Ignore self signed certificates"
  default     = false
}

variable "proxmox_host" {
  type        = string
  description = "Please specify the host in the proxmox data center to use for creating this VM"
}

variable "proxmox_vm_template" {
  type        = string
  description = "cloud-init ready template name"
}

variable "proxmox_storage" {
  type        = string
  description = "Storage to use for vm"
}

variable "ssh_private_key" {
  type    = string
  default = "~/.ssh/id_ed25519"
}

variable "ssh_public_key" {
  type    = string
  default = "~/.ssh/id_ed25519.pub"
}

variable "vm_name_prefix" {
  type    = string
}

variable "vm_username" {
  type    = string
  default = "ubuntu"
}

variable "vm_count" {
  type    = number
  default = 1
}

variable "vm_sockets" {
  type    = number
  default = 1
}

variable "vm_cores" {
  type    = number
  default = 2
}

variable "vm_memory" {
  type    = number
  default = 2048
}

variable "vm_disk" {
  type    = string
  default = "10G"
}

variable "registration_token" {
  type = string
  description = "GitLab Registration Token for the runner to use"
}
