resource "proxmox_virtual_environment_vm" "jessie_data" {
  name      = "jessie-data"
  tags      = ["data-only"]
  
  node_name = "pve"
  vm_id     = 5100

  started   = false
  on_boot   = false
  template  = true
  
  disk {
    datastore_id = "local-lvm"
    interface    = "virtio0"
    file_format  = "raw"
    size         = 64
  }

  lifecycle {
    ignore_changes = [ startup, cpu, memory ]
  }
}

resource "proxmox_virtual_environment_vm" "jessie" {
  name        = "jessie"
  tags        = ["internal", "jammy", "ubuntu"]

  node_name = "pve"
  vm_id     = 100
  bios      = "ovmf"

  clone {
    vm_id = proxmox_virtual_environment_vm.ubuntu_jammy_template.id
  }

  startup {
    order      = "2"
    up_delay   = "60"
    down_delay = "60"
  }

  cpu {
    cores = 8
    type  = "host"
  }

  memory {
    dedicated = 24576
    floating  = 24576
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
    mac_address = "02:00:00:00:01:00"
  }

  provisioner "local-exec" {
    command = "ansible-playbook -u ${var.default_user} --private-key ${var.private_key_file} ansible/jessie.yml"
  }

  depends_on = [ proxmox_virtual_environment_vm.barbie ]
}
