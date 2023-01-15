source "qemu" "gitlab-runner" {
  iso_url           = "https://releases.ubuntu.com/22.04.1/ubuntu-22.04.1-live-server-amd64.iso"
  iso_checksum      = "sha256:10f19c5b2b8d6db711582e0e27f5116296c34fe4b313ba45f9b201a5007056cb"
  output_directory  = "out/vm"
  shutdown_command  = "echo 'user1' | sudo -S shutdown -P now"
  disk_size         = "10G"
  format            = "qcow2"
  accelerator       = "kvm"
  http_content      = {
    "/meta-data" = file("${path.root}/http/ubuntu-server-autoinstall/meta-data")
    "/user-data" = file("${path.root}/http/ubuntu-server-autoinstall/user-data")
  }
  communicator      = "ssh"
  ssh_username      = "user1"
  ssh_password      = "user1"
  ssh_timeout       = "90m"
  vm_name           = "gitlab-runner"
  cpus              = 2
  memory            = 2048
  net_device        = "virtio-net"
  disk_interface    = "virtio"
  headless          = true
  boot_key_interval = "5ms"
  boot_wait         = "4s"
  boot_command      = ["c",
                       "linux /casper/vmlinuz --- autoinstall 'ds=nocloud-net;s=http://{{ .HTTPIP }}:{{ .HTTPPort }}/'",
                       "<enter><wait10s>",
                       "initrd /casper/initrd<enter><wait10s>",
                       "boot<enter>"]
}

build {
  sources = ["source.qemu.gitlab-runner"]

  # Wait until cloud-init finish configuring system
  provisioner "shell" {
    inline = [
      "while [ ! -f /var/lib/cloud/instance/boot-finished ]; do echo 'Waiting for cloud-init...'; sleep 2; done"
    ]
  }

  provisioner "ansible" {
    user = "user1"
    playbook_file = "./provision.yml"

    extra_arguments = [
      "--extra-vars", "ansible_sudo_pass=user1"
    ]

    # Temporary workaround for packer ssh connection
    #   https://github.com/hashicorp/packer-plugin-ansible/issues/69
    #ansible_ssh_extra_args = [
    #  "-oHostKeyAlgorithms=+ssh-rsa -oPubkeyAcceptedKeyTypes=+ssh-rsa"
    #]
  }
}
