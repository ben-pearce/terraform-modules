terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.57.0"
    }
  }
}

variable "proxmox_api_url" {
  type     = string
  nullable = false
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

variable "private_key_file" {
  type     = string
  nullable = false
}

variable "public_key_file" {
  type     = string
  nullable = false
}

variable "default_user" {
  type     = string
  nullable = false
  default  = "ubuntu"
}

provider "proxmox" {
  endpoint = var.proxmox_api_url
  username = var.proxmox_user
  password = var.proxmox_password
  ssh {
    agent = true
  }
}

module "infrastructure" {
  source           = "./modules/infrastructure"
  truenas_disk_ids = var.truenas_disk_ids
}

module "servers" {
  source           = "./modules/servers"
  default_user     = var.default_user
  private_key_file = var.private_key_file
  public_key_file  = var.public_key_file

  depends_on = [ module.infrastructure ]
}

module "containers" {
  source           = "./modules/containers"
  private_key_file = var.private_key_file
  public_key_file  = var.public_key_file

  depends_on = [ module.infrastructure ]
}