resource "proxmox_virtual_environment_vm" "etch" {
  name        = "etch"
  tags        = ["internal", "noble", "ubuntu"]

  node_name = "pve"
  vm_id     = 102
  bios      = "ovmf"

  clone {
    vm_id = proxmox_virtual_environment_vm.ubuntu_noble_template.id
  }

  cpu {
    cores = 2
    type  = "host"
  }

  memory {
    dedicated = 2048
    floating  = 2048
  }

  disk {
    datastore_id = "local-lvm"
    interface    = "virtio0"
    iothread     = true
    discard      = "on"
    size         = 10
  }

  network_device {
    bridge      = "vmbr0"
    mac_address = "02:00:00:00:01:02"
  }

  provisioner "local-exec" {
    command = "ansible-playbook -u ${var.default_user} --private-key ${var.private_key_file} ansible/etch.yml"
  }

  depends_on = [ proxmox_virtual_environment_vm.barbie ]
}
