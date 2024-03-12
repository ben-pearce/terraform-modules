resource "proxmox_virtual_environment_container" "jellyfin_ffmpeg" {
  node_name   = "pve"
  vm_id       = 1000
  tags        = ["internal", "jammy", "lxc", "ubuntu"]

  initialization {
    hostname = "jellyfin-ffmpeg"

    ip_config {
      ipv4 {
        address = "dhcp"
      }
    }
  }

  clone {
    node_name     = "pve"
    datastore_id  = "local-lvm"
    vm_id         = proxmox_virtual_environment_container.lxc_ubuntu_jammy_template.id
  }

  startup {
    order      = "3"
    up_delay   = "60"
    down_delay = "60"
  }

  cpu {
    cores = 16
  }

  memory {
    dedicated = 12288
  }

  network_interface {
    name        = "eth0"
    vlan_id     = 10
    mac_address = "02:00:00:00:10:00"
  }

  disk {
    datastore_id = "local-lvm"
    size         = 8
  }

  provisioner "local-exec" {
    command = "ansible-playbook -u ubuntu --private-key ${var.private_key_file} ansible-playbooks/jellyfin_ffmpeg.yml"
  }
}