# resource "proxmox_vm_qemu" "trixie" {
#   count = 1
#   name = "trixie"
#   vmid = 202
#   tags = "external;jammy;ubuntu"

#   target_node = "pve"

#   clone = var.template_name

#   agent = 1
#   bios = "ovmf"
#   cores = 6
#   sockets = 1
#   cpu = "host"
#   memory = 6144
#   scsihw = "virtio-scsi-pci"
#   bootdisk = "scsi0"
#   numa = false
#   qemu_os = "other"
#   ipconfig0 = "ip=dhcp"
#   onboot = true

#   disk {
#     slot = 0
#     size = "32G"
#     type = "virtio"
#     storage = "local-lvm"
#     iothread = 1
#     discard = "on"
#   }

#   network {
#     model = "virtio"
#     bridge = "vmbr0"
#     tag = 20
#     macaddr = "02:00:00:00:02:02"
#   }

#   vga {
#     memory = 0
#     type = "std"
#   }

#   provisioner "local-exec" {
#     command = "sleep 10; ansible-playbook ansible-playbooks/trixie.yml"
#   }

#   lifecycle {
#     ignore_changes = [
#       ciuser, sshkeys, network, disk
#     ]
#   }

#   depends_on = [  proxmox_vm_qemu.barbie ]

# }
