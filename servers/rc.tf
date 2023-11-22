resource "proxmox_vm_qemu" "rc" {
  count = 1
  name  = "rc"
  vmid  = 201

  tags = "external;jammy;ubuntu"

  target_node = "pve"

  clone = var.template_name

  agent     = 1
  bios      = "ovmf"
  cores     = 2
  sockets   = 1
  cpu       = "host"
  memory    = 8192
  scsihw    = "virtio-scsi-pci"
  bootdisk  = "scsi0"
  numa      = false
  qemu_os   = "other"
  ipconfig0 = "ip=dhcp"
  onboot    = true

  disk {
    size     = "64G"
    type     = "virtio"
    storage  = "local-lvm"
    iothread = 1
    discard  = "on"
  }

  network {
    model   = "virtio"
    bridge  = "vmbr0"
    tag     = 20
    macaddr = "02:00:00:00:02:01"
  }

  vga {
    memory = 0
    type   = "std"
  }

  provisioner "local-exec" {
    command = "sleep 10; ansible-playbook ansible-playbooks/rc.yml"
  }

  lifecycle {
    ignore_changes = [
      ciuser, sshkeys, network, bootdisk, disk
    ]
  }

  depends_on = [proxmox_vm_qemu.barbie]

}
