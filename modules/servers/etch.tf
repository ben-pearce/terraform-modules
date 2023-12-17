resource "proxmox_virtual_environment_vm" "etch" {
  name        = "etch"
  tags        = ["internal", "jammy", "ubuntu"]

  node_name = "pve"
  vm_id     = 102

  clone {
    vm_id = proxmox_virtual_environment_vm.ubuntu_jammy_template.id
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
    file_id      = proxmox_virtual_environment_file.ubuntu_cloud_image.id
    interface    = "virtio0"
    iothread     = true
    discard      = "on"
    size         = 10
  }

  network_device {
    bridge      = "vmbr0"
    vlan_id     = 10
    mac_address = "02:00:00:00:01:02"
  }

  provisioner "local-exec" {
    command = "ansible-playbook -u ${var.default_user} --private-key ${var.private_key_file} ansible-playbooks/etch.yml"
  }

  depends_on = [ proxmox_virtual_environment_vm.barbie ]
}
