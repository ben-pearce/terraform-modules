# resource "proxmox_vm_qemu" "sparks" {
#   count = 1
#   name = "sparks"
#   vmid = 104
#   tags = "internal;jammy;ubuntu"

#   target_node = "pve"

#   clone = var.template_name

#   agent = 1
#   bios = "ovmf"
#   cores = 16
#   sockets = 1
#   cpu = "host"
#   memory = 32768
#   scsihw = "virtio-scsi-pci"
#   bootdisk = "scsi0"
#   numa = false
#   qemu_os = "other"
#   ipconfig0 = "ip=dhcp"
#   onboot = true

#   disk {
#     slot = 0
#     size = "120G"
#     type = "virtio"
#     storage = "local-lvm"
#     iothread = 1
#     discard = "on"
#   }

#   network {
#     model = "virtio"
#     bridge = "vmbr0"
#     tag = 10
#     macaddr = "02:00:00:00:01:04"
#   }

#   network {
#     model = "virtio"
#     bridge = "vmbr0"
#     tag = 10
#     macaddr = "02:00:00:01:01:04"
#   }

#   vga {
#     memory = 0
#     type = "std"
#   }

#   provisioner "local-exec" {
#     command = "sleep 10; ansible-playbook ansible-playbooks/sparks.yml"
#   }

#   lifecycle {
#     ignore_changes = [
#       ciuser, sshkeys, network, disk
#     ]
#   }

#   depends_on = [ proxmox_vm_qemu.barbie ]

# }
