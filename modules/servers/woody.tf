resource "proxmox_virtual_environment_vm" "woody" {
  name        = "woody"
  tags        = ["external", "noble", "ubuntu"]

  node_name = "pve"
  vm_id     = 200
  bios      = "ovmf"

  clone {
    vm_id = proxmox_virtual_environment_vm.ubuntu_noble_template.id
  }

  cpu {
    cores = 6
    type  = "host"
  }

  memory {
    dedicated = 20480
    floating  = 20480
  }

  disk {
    datastore_id = "local-lvm"
    file_id      = proxmox_virtual_environment_file.ubuntu_cloud_image.id
    interface    = "virtio0"
    iothread     = true
    discard      = "on"
    size         = 160
  }

  network_device {
    bridge      = "vmbr0"
    vlan_id     = 20
    mac_address = "02:00:00:00:02:00"
  }

  provisioner "local-exec" {
    command = "ansible-playbook -u ${var.default_user} --private-key ${var.private_key_file} ansible-playbooks/woody.yml"
  }

  depends_on = [ proxmox_virtual_environment_vm.barbie ]
}
