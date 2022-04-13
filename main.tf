resource "proxmox_vm_qemu" "vm" {
  count = var.vm_count
  name = "${var.vm_name_prefix}-${count.index + 1}"

  target_node = var.proxmox_host
  clone = var.proxmox_vm_template

  agent = 1
  os_type = "cloud-init"
  cores = var.vm_cores
  sockets = var.vm_sockets
  cpu = "host"
  memory = var.vm_memory
  scsihw = "virtio-scsi-pci"
  bootdisk = "scsi0"

  disk {
    slot = 0
    size = var.vm_disk
    type = "scsi"
    storage = var.proxmox_storage
    iothread = 1
  }

  network {
    model = "virtio"
    bridge = "vmbr0"
  }

  # TODO: Need to check if ipconfig0, cicustom, ciuser, desc can be overwritten from here
  lifecycle {
    ignore_changes = [
      network,
      ipconfig0,
      cicustom,
      ciuser,
      desc,
    ]
  }

  sshkeys = file(pathexpand(var.ssh_public_key))

  provisioner "remote-exec" {
    connection {
      type     = "ssh"
      user     = var.vm_username
      private_key = file(pathexpand(var.ssh_private_key))
      host     = self.default_ipv4_address
    }

    inline = [
      "sudo curl -L --output /usr/local/bin/gitlab-runner https://gitlab-runner-downloads.s3.amazonaws.com/latest/binaries/gitlab-runner-linux-amd64",
      "sudo chmod +x /usr/local/bin/gitlab-runner",
      "sudo useradd --comment 'GitLab Runner' --create-home gitlab-runner --shell /bin/bash",
      "sudo gitlab-runner install --user=gitlab-runner --working-directory=/home/gitlab-runner",
      "sudo gitlab-runner start",
      "sudo gitlab-runner register --run-untagged=true --docker-image ubuntu --non-interactive --executor docker --url https://gitlab.com/ --registration-token ${var.registration_token}",
      "sudo sed -i 's/concurrent = 1/concurrent = 3/g' /etc/gitlab-runner/config.toml",
      "sudo gitlab-runner restart"
    ]
  }

}

resource "null_resource" "unregister" {
  count = var.vm_count
  triggers = {
    vm_username = var.vm_username
    ssh_private_key = var.ssh_private_key
    ip_address = proxmox_vm_qemu.vm[count.index].default_ipv4_address
  }
  provisioner "remote-exec" {
    connection {
      type     = "ssh"
      user     = self.triggers.vm_username
      private_key = file(pathexpand(self.triggers.ssh_private_key))
      host     = self.triggers.ip_address
    }
    when = destroy
    inline = [
      "sudo gitlab-runner unregister --all-runners"
    ]
  }
}

output "ip_address" {
  value = proxmox_vm_qemu.vm.*.default_ipv4_address
}
