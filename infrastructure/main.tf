terraform {
  required_providers {
    proxmox = {
      source  = "Telmate/proxmox"
      version = "2.9.14"
    }
  }
}

variable "disk_ids" {
  description = "List of disk IDs to pass through to TrueNAS"
  type        = list(string)
  nullable    = false
}