resource "proxmox_vm_qemu" "barbie" {
  count = 1
  name  = "barbie"
  vmid  = 105
  tags  = "internal;jammy;ubuntu"

  target_node = "pve"

  clone = var.template_name

  agent     = 1
  os_type   = "cloud-init"
  bios      = "ovmf"
  cores     = 2
  sockets   = 1
  cpu       = "host"
  memory    = 2048
  scsihw    = "virtio-scsi-pci"
  bootdisk  = "scsi0"
  numa      = false
  qemu_os   = "other"
  ipconfig0 = "ip=dhcp"
  onboot    = true

  disk {
    size     = "10G"
    type     = "virtio"
    storage  = "local-lvm"
    iothread = 1
    discard  = "on"
  }

  network {
    model   = "virtio"
    bridge  = "vmbr0"
    tag     = 10
    macaddr = "02:00:00:00:01:05"
  }

  vga {
    memory = 0
    type   = "std"
  }

  provisioner "local-exec" {
    command = "sleep 10; ansible-playbook ansible-playbooks/barbie.yml"
  }

  lifecycle {
    ignore_changes = [
      ciuser, sshkeys, network, bootdisk, disk
    ]
  }

}
