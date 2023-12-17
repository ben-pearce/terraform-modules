resource "proxmox_virtual_environment_vm" "rc" {
  name        = "rc"
  tags        = ["external", "jammy", "ubuntu"]

  node_name = "pve"
  vm_id     = 201

  clone {
    vm_id = proxmox_virtual_environment_vm.ubuntu_jammy_template.id
  }

  cpu {
    cores = 2
    type  = "host"
  }

  memory {
    dedicated = 8192
    floating  = 8192
  }

  disk {
    datastore_id = "local-lvm"
    file_id      = proxmox_virtual_environment_file.ubuntu_cloud_image.id
    interface    = "virtio0"
    iothread     = true
    discard      = "on"
    size         = 64
  }

  network_device {
    bridge      = "vmbr0"
    vlan_id     = 20
    mac_address = "02:00:00:00:02:01"
  }

  provisioner "local-exec" {
    command = "ansible-playbook -u ${var.default_user} --private-key ${var.private_key_file} ansible-playbooks/rc.yml"
  }

  depends_on = [ proxmox_virtual_environment_vm.barbie ]
}
