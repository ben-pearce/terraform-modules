resource "proxmox_virtual_environment_container" "jellyfin_ffmpeg" {
  node_name = "pve"
  vm_id     = 1000
  tags      = ["internal", "jammy", "lxc", "ubuntu"]

  clone {
    node_name = "pve"
    datastore_id = "local"
    vm_id = proxmox_virtual_environment_container.ubuntu_jammy_template.id
  }

  cpu {
    cores = 16
  }

  memory {
    dedicated = 12288
  }

  features {
    fuse  = true
    mount = ["nfs"]
  }

  network_interface {
    name        = "eth0"
    vlan_id     = 10
    mac_address = "02:00:00:00:10:00"
  }

  operating_system {
    template_file_id = proxmox_virtual_environment_file.ubuntu_container_template.id
    type             = "ubuntu"
  }

  disk {
    datastore_id = "local-lvm"
    size         = 8
  }

  provisioner "local-exec" {
    command = "ansible-playbook -u ubuntu --private-key ${var.private_key_file} ansible-playbooks/jellyfin_ffmpeg.yml"
  }
}