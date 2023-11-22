resource "proxmox_vm_qemu" "woody" {
  count = 1
  name  = "woody"
  vmid  = 200
  tags  = "external;jammy;ubuntu"

  target_node = "pve"

  clone = var.template_name

  agent     = 1
  bios      = "ovmf"
  cores     = 6
  sockets   = 1
  cpu       = "host"
  memory    = 20480
  scsihw    = "virtio-scsi-pci"
  bootdisk  = "scsi0"
  numa      = false
  qemu_os   = "other"
  ipconfig0 = "ip=dhcp"
  onboot    = true

  disk {
    size     = "160G"
    type     = "virtio"
    storage  = "local-lvm"
    iothread = 1
    discard  = "on"
  }

  network {
    model   = "virtio"
    bridge  = "vmbr0"
    tag     = 20
    macaddr = "02:00:00:00:02:00"
  }

  vga {
    memory = 0
    type   = "std"
  }

  provisioner "local-exec" {
    command = "sleep 10; ansible-playbook ansible-playbooks/woody.yml"
  }

  lifecycle {
    ignore_changes = [
      ciuser, sshkeys, network, bootdisk, disk
    ]
  }

  depends_on = [proxmox_vm_qemu.barbie]

}
