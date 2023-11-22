resource "proxmox_vm_qemu" "jessie" {
  count = 1
  name  = "jessie"
  vmid  = 100
  tags  = "internal;jammy;ubuntu"

  target_node = "pve"

  clone = var.template_name

  agent     = 1
  os_type   = "cloud-init"
  bios      = "ovmf"
  cores     = 8
  sockets   = 1
  cpu       = "host"
  memory    = 16384
  scsihw    = "virtio-scsi-pci"
  bootdisk  = "scsi0"
  numa      = false
  qemu_os   = "other"
  ipconfig0 = "ip=dhcp"
  onboot    = true

  disk {
    size     = "120G"
    type     = "virtio"
    storage  = "local-lvm"
    iothread = 1
    discard  = "on"
  }

  network {
    model   = "virtio"
    bridge  = "vmbr0"
    tag     = 10
    macaddr = "02:00:00:00:01:00"
  }

  vga {
    memory = 0
    type   = "std"
  }

  provisioner "local-exec" {
    command = "sleep 10; ansible-playbook ansible-playbooks/jessie.yml"
  }

  lifecycle {
    ignore_changes = [
      ciuser, sshkeys, network, bootdisk, disk
    ]
  }

  depends_on = [proxmox_vm_qemu.barbie]

}
