terraform {
  required_providers {
    proxmox = {
      source = "bpg/proxmox"
      version = "0.40.0"
    }
  }
}

variable "private_key_file" {
  type     = string
  nullable = false
}

variable "public_key_file" {
  type     = string
  nullable = false
}

resource "random_password" "ubuntu_lxc_password" {
  length           = 16
  override_special = "_%@"
  special          = true
}

resource "proxmox_virtual_environment_file" "ubuntu_container_template" {
  content_type = "vztmpl"
  datastore_id = "local"
  node_name    = "pve"

  source_file {
    path = "http://download.proxmox.com/images/system/ubuntu-22.04-standard_22.04-1_amd64.tar.zst"
  }
}

resource "proxmox_virtual_environment_container" "lxc_ubuntu_jammy_template" {
  node_name = "pve"
  vm_id     = 9003
  tags      = ["internal", "jammy", "lxc", "ubuntu"]

  template  = true
  started   = false

  initialization {
    hostname = "lxc-ubuntu-jammy-template"

    ip_config {
      ipv4 {
        address = "dhcp"
      }
    }

    user_account {
      keys     = [trimspace(file(var.public_key_file))]
      password = random_password.ubuntu_lxc_password.result
    }
  }

  network_interface {
    name = "eth0"
  }

  operating_system {
    template_file_id = proxmox_virtual_environment_file.ubuntu_container_template.id
    type             = "ubuntu"
  }

  disk {
    datastore_id = "local-lvm"
    size         = 8
  }

  lifecycle {
    ignore_changes = [ description ]
  }

  # Can't automate yet :(
  # lxc.cgroup2.devices.allow: c 226:0 rwm
  # lxc.cgroup2.devices.allow: c 226:128 rwm
  # lxc.cgroup2.devices.allow: c 29:0 rwm
  # lxc.mount.entry: /dev/dri dev/dri none bind,optional,create=dir
  # lxc.mount.entry: /dev/fb0 dev/fb0 none bind,optional,create=file

}