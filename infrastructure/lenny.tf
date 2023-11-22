resource "proxmox_vm_qemu" "lenny" {
  count = 1
  name  = "lenny"
  vmid  = 103
  tags  = "internal;"

  target_node = "pve"

  iso = "local:iso/truenas.iso"

  agent    = 1
  bios     = "ovmf"
  cores    = 4
  sockets  = 1
  cpu      = "host"
  memory   = 16384
  scsihw   = "virtio-scsi-pci"
  bootdisk = "scsi0"
  numa     = false
  qemu_os  = "other"
  onboot   = true
  oncreate = false

  disk {
    size     = "32G"
    type     = "virtio"
    storage  = "local-lvm"
    iothread = 1
    discard  = "on"
  }

  # # Unsupported :(
  # dynamic "disk" {
  #   for_each = var.disk_ids
  #   content {
  #     type = "virtio"
  #     storage = ""
  #     volume = "/dev/disk/by-id/${disk.value}"
  #     size = "9314G"
  #     backup = false
  #   }
  # }

  network {
    model   = "virtio"
    bridge  = "vmbr0"
    tag     = 10
    macaddr = "02:00:00:00:01:03"
  }

  vga {
    memory = 0
    type   = "std"
  }

  lifecycle {
    ignore_changes = [
      network, disk
    ]
  }

}
