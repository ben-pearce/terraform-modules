resource "proxmox_virtual_environment_vm" "barbie" {
  name                = "barbie"
  reboot_after_update = true
  tags                = ["internal", "noble", "ubuntu"]

  node_name = "pve"
  vm_id     = 105
  bios      = "ovmf"

  clone {
    vm_id = proxmox_virtual_environment_vm.ubuntu_noble_template.id
  }

  startup {
    order      = "2"
    up_delay   = "60"
    down_delay = "60"
  }

  cpu {
    cores        = 2
    type         = "host"
    architecture = "x86_64"
  }

  memory {
    dedicated = 4096
    floating  = 4096
  }

  disk {
    datastore_id = "local-lvm"
    file_id      = proxmox_virtual_environment_file.ubuntu_cloud_image_noble.id
    interface    = "virtio0"
    iothread     = true
    discard      = "on"
    size         = 24
  }

  network_device {
    bridge      = "vmbr0"
    vlan_id     = 10
    mac_address = "02:00:00:00:01:05"
  }

  provisioner "local-exec" {
    command = "ansible-playbook -u ${var.default_user} --private-key ${var.private_key_file} ansible/barbie.yml"
  }
}
