terraform {
  required_providers {
    proxmox = {
      source = "bpg/proxmox"
      version = "0.73.0"
    }
  }
}

resource "proxmox_virtual_environment_file" "truenas_iso" {
  content_type = "iso"
  datastore_id = "local"
  node_name    = "pve"

  source_file {
    path = "https://download-core.sys.truenas.net/13.0/STABLE/U6.1/x64/TrueNAS-13.0-U6.1.iso"
  }
}

resource "proxmox_virtual_environment_file" "proxmox_backup_server_iso" {
  content_type = "iso"
  datastore_id = "local"
  node_name    = "pve"

  source_file {
    path = "https://enterprise.proxmox.com/iso/proxmox-backup-server_3.2-1.iso"
  }
}
