resource "proxmox_lxc" "jellyfin-ffmpeg" {
  count    = 1
  hostname = "jellyfin-ffmpeg"
  vmid     = 1000
  tags     = "internal;jammy;lxc;ubuntu"

  target_node = "pve"

  clone = 9003

  onboot = true
  start  = true
  memory = 12288

  password = "jellyfin"

  rootfs {
    storage = "local-lvm"
    size    = "8G"
  }

  network {
    name   = "eth0"
    bridge = "vmbr0"
    tag    = 10
    hwaddr = "02:00:00:00:10:00"
    ip     = "dhcp"
  }

  provisioner "local-exec" {
    command = "sleep 10; ansible-playbook ansible-playbooks/jellyfin_ffmpeg.yml"
  }

}