terraform {
  required_providers {
    proxmox = {
      source = "bpg/proxmox"
      version = "0.56.1"
    }
  }
}

resource "random_password" "ubuntu_vm_password" {
  length           = 16
  override_special = "_%@"
  special          = true
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
}

resource "proxmox_virtual_environment_file" "ubuntu_cloud_image" {
  content_type = "iso"
  datastore_id = "local"
  node_name    = "pve"

  source_file {
    path = "https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img"
  }
}

resource "proxmox_virtual_environment_file" "ubuntu_cloud_image_noble" {
  content_type = "iso"
  datastore_id = "local"
  node_name    = "pve"

  source_file {
    path = "https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img"
  }
}


resource "proxmox_virtual_environment_file" "debian_cloud_image" {
  content_type = "iso"
  datastore_id = "local"
  node_name    = "pve"

  source_file {
    path      = "https://cloud.debian.org/images/cloud/bookworm/latest/debian-12-generic-amd64.qcow2"
    file_name = "debian-12-generic-amd64.img"
  }
}

resource "proxmox_virtual_environment_file" "cloud_config" {
  content_type = "snippets"
  datastore_id = "local"
  node_name    = "pve"

  source_raw {
    data = file("${path.module}/snippets/ubuntu.cloud-config.yaml")
    file_name = "ubuntu.cloud-config.yaml"
  }
}

resource "proxmox_virtual_environment_file" "cloud_config_vdb" {
  content_type = "snippets"
  datastore_id = "local"
  node_name    = "pve"

  source_raw {
    data = file("${path.module}/snippets/ubuntu-vdb.cloud-config.yaml")
    file_name = "ubuntu-vdb.cloud-config.yaml"
  }
}

resource "proxmox_virtual_environment_vm" "ubuntu_jammy_template" {
  name        = "ubuntu-jammy-template"
  tags        = ["cloud-image", "jammy", "ubuntu"]

  node_name = "pve"
  vm_id     = 9001
  bios      = "ovmf"

  template  = true
  started   = false

  agent {
    enabled = true
  }

  startup {
    order      = "1"
    up_delay   = "60"
    down_delay = "60"
  }

  cpu {
    cores = 2
    type  = "host"
  }

  memory {
    dedicated = 2048
    floating  = 2048
  }

  efi_disk {
    datastore_id      = "local-lvm"
    file_format       = "raw"
    type              = "4m"
    pre_enrolled_keys = true
  }

  disk {
    datastore_id = "local-lvm"
    file_id      = proxmox_virtual_environment_file.ubuntu_cloud_image.id
    interface    = "virtio0"
    iothread     = true
    discard      = "on"
    size         = 2
  }

  initialization {
    ip_config {
      ipv4 {
        address = "dhcp"
      }
    }

    user_account {
      keys     = [trimspace(file(var.public_key_file))]
      password = random_password.ubuntu_vm_password.result
      username = var.default_user
    }

    vendor_data_file_id = proxmox_virtual_environment_file.cloud_config.id
    interface = "scsi0"
  }

  network_device {
    bridge = "vmbr0"
  }

  operating_system {
    type = "l26"
  }

  tpm_state {
    version = "v2.0"
  }

  lifecycle {
    ignore_changes = [ initialization ]
  }
}

resource "proxmox_virtual_environment_vm" "debian_bookworm_template" {
  name        = "debian-bookworm-template"
  tags        = ["bookworm", "cloud-image", "debian"]

  node_name = "pve"
  vm_id     = 9002
  bios      = "ovmf"

  template  = true
  started   = false

  agent {
    enabled = true
  }

  startup {
    order      = "1"
    up_delay   = "60"
    down_delay = "60"
  }

  cpu {
    cores = 2
    type  = "host"
  }

  memory {
    dedicated = 2048
    floating  = 2048
  }

  efi_disk {
    datastore_id      = "local-lvm"
    file_format       = "raw"
    type              = "4m"
    pre_enrolled_keys = true
  }

  disk {
    datastore_id = "local-lvm"
    file_id      = proxmox_virtual_environment_file.debian_cloud_image.id
    interface    = "virtio0"
    iothread     = true
    discard      = "on"
    size         = 2
  }

  initialization {
    ip_config {
      ipv4 {
        address = "dhcp"
      }
    }

    user_account {
      keys     = [trimspace(file(var.public_key_file))]
      password = random_password.ubuntu_vm_password.result
      username = var.default_user
    }

    vendor_data_file_id = proxmox_virtual_environment_file.cloud_config.id
    interface = "scsi0"
  }

  network_device {
    bridge = "vmbr0"
  }

  operating_system {
    type = "l26"
  }

  tpm_state {
    version = "v2.0"
  }

  lifecycle {
    ignore_changes = [ initialization ]
  }
}

resource "proxmox_virtual_environment_vm" "ubuntu_noble_template" {
  name        = "ubuntu-noble-template"
  tags        = ["cloud-image", "noble", "ubuntu"]

  node_name = "pve"
  vm_id     = 9004
  bios      = "ovmf"

  template  = true
  started   = false

  agent {
    enabled = true
  }

  startup {
    order      = "1"
    up_delay   = "60"
    down_delay = "60"
  }

  cpu {
    cores = 2
    type  = "host"
  }

  memory {
    dedicated = 2048
    floating  = 2048
  }

  efi_disk {
    datastore_id      = "local-lvm"
    file_format       = "raw"
    type              = "4m"
    pre_enrolled_keys = true
  }

  disk {
    datastore_id = "local-lvm"
    file_id      = proxmox_virtual_environment_file.ubuntu_cloud_image_noble.id
    interface    = "virtio0"
    iothread     = true
    discard      = "on"
    size         = 3
  }

  initialization {
    ip_config {
      ipv4 {
        address = "dhcp"
      }
    }

    user_account {
      keys     = [trimspace(file(var.public_key_file))]
      password = random_password.ubuntu_vm_password.result
      username = var.default_user
    }

    vendor_data_file_id = proxmox_virtual_environment_file.cloud_config.id
    interface = "scsi0"
  }

  network_device {
    bridge = "vmbr0"
  }

  operating_system {
    type = "l26"
  }

  tpm_state {
    version = "v2.0"
  }

  lifecycle {
    ignore_changes = [ initialization ]
  }
}

output "ubuntu_vm_password" {
  value     = random_password.ubuntu_vm_password.result
  sensitive = true
}