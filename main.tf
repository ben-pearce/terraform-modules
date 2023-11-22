terraform {
  required_providers {
    proxmox = {
      source  = "Telmate/proxmox"
      version = "2.9.14"
    }
  }
}

variable "proxmox_api_url" {
  type     = string
  nullable = false
}

variable "proxmox_api_token_id" {
  type    = string
  default = null
}

variable "proxmox_api_token_secret" {
  type    = string
  default = null
}

variable "proxmox_user" {
  type    = string
  default = null
}

variable "proxmox_password" {
  type    = string
  default = null
}

variable "truenas_disk_ids" {
  type     = list(string)
  nullable = false
}

variable "template_name" {
  default = "ubuntu-jammy-template"
}

variable "lxc_template_name" {
  default = "lxc-ubuntu-jammy-template"
}

provider "proxmox" {
  pm_api_url          = var.proxmox_api_url
  pm_user             = var.proxmox_user
  pm_password         = var.proxmox_password
  pm_api_token_id     = var.proxmox_api_token_id
  pm_api_token_secret = var.proxmox_api_token_secret
}

resource "null_resource" "cloud_init" {
  provisioner "local-exec" {
    command = "ansible-playbook ansible-playbooks/pve.yml; sleep 5;"
  }
}

module "infrastructure" {
  source     = "./infrastructure"
  disk_ids   = var.truenas_disk_ids
  depends_on = [null_resource.cloud_init]
}

module "servers" {
  source        = "./servers"
  template_name = var.template_name
  depends_on    = [null_resource.cloud_init]
}