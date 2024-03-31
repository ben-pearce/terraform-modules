resource "proxmox_virtual_environment_vm" "sparks" {
  name        = "sparks"
  tags        = ["internal", "jammy", "ubuntu"]

  node_name = "pve"
  vm_id     = 104
  bios      = "ovmf"

  clone {
    vm_id = proxmox_virtual_environment_vm.ubuntu_jammy_template.id
  }

  cpu {
    cores = 16
    type  = "host"
  }

  memory {
    dedicated = 32768
    floating  = 32768
  }

  disk {
    datastore_id = "local-lvm"
    file_id      = proxmox_virtual_environment_file.ubuntu_cloud_image.id
    interface    = "virtio0"
    iothread     = true
    discard      = "on"
    size         = 120
  }

  network_device {
    bridge      = "vmbr0"
    vlan_id     = 10
    mac_address = "02:00:00:00:01:04"
  }

  network_device {
    bridge      = "vmbr0"
    vlan_id     = 10
    mac_address = "02:00:00:01:01:04"
  }

  provisioner "local-exec" {
    command = "ansible-playbook -u ${var.default_user} --private-key ${var.private_key_file} ansible-playbooks/sparks.yml"
  }

  depends_on = [ proxmox_virtual_environment_vm.barbie ]
}
