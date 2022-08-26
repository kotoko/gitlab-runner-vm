# gitlab-runner-vm

This repo contains script that creates virtual machine disk image using packer. Packer installs non-interactively Ubuntu Server 22.04, latest gitlab-runner and commonly used tools in CI. This repo also contains script for creating secondary disk that will be used as build directory and other directories for temporary files: /tmp, /var/tmp, /var/lib/docker.

Idea is you can have virtual machine with gitlab-runner and programs already installed and the only thing left to do is to register gitlab-runner to the gitlab.com server.

## Requirements

Creating virtual machine image:

* internet access
* installed programs (here ubuntu packages):
  - ansible
  - libvirt-daemon
  - virt-manager
  - libguestfs-tools
  - qemu
  - qemu-utils
  - qemu-kvm
  - [packer](https://www.packer.io/)
  - e2fsprogs
* 4 GB or more RAM
* 20 GB or more free space on disk

Virtual machine:

* 1 GB or more RAM
* 2 CPU cores or more
* CPU architecture: amd64 (x86_64)
* internet access

## Generate virtual machine image

Generate primary disk image with virtual machine:

```
packer build gitlab-runner.pkr.hcl
```

Image will be `out/vm/gitlab-runner`. It is `qcow2` file format. Virtual disk size is 10 GB.

Generate secondary disk image used for building in CI:

```
chmod +x gitlab-runner-create-disk-builds.sh
sudo ./gitlab-runner-create-disk-builds.sh 50
```

Parameter `50` means disk size is 50 GB. Image will be `out/gr-disk-builds-50G.qcow2`. It is `qcow2` file format. Disk is empty in the beginning so even if virtual size is 50 GB file will be only few megabytes. Size of file will grow over time.

## Run virtual machine

There are 2 user accounts configured: `root` (administrator) and `user1` (normal account with ability to sudo as root). Password is the same as login.

Create virtual machine in virt-manager and import two generated disks. Run the machine. Login as root. Register gitlab-runner to gitlab server by running script:

```
/root/register-gitlab-runner.sh REGISTRATION_TOKEN
```

Script will register three tagged runners to gitlab.com server:
* linux, amd64, shell
* linux, amd64, docker
* linux, amd64, docker-privileged
