terraform {
  required_providers {
    libvirt = {
      source = "dmacvicar/libvirt"
    }
  }
}

provider "libvirt" {
  uri = "qemu:///system" 
}

resource "libvirt_pool" "jenkins-slave-pool" {
  name = "jenkins-slave-pool"
  type = "dir"
  path = "/opt/jenkins-slave-pool"
}
resource "libvirt_volume" "jenkins-slave-volume" {
  name   = "jenkins-slave-volume"
  source = "/var/lib/libvirt/packer-jenkins-slave"
  pool   = libvirt_pool.jenkins-slave-pool.name
  format = "qcow2"
}

resource "libvirt_domain" "jenkins-slave-domain" {
  name      = "jenkins-slave"
  memory    = "1024"
  vcpu      = 1
  cpu {
    mode = "host-passthrough"
  }
  network_interface {
    network_name   = "default"
    wait_for_lease = true
  }
  disk {
    volume_id = libvirt_volume.jenkins-slave-volume.id
  }
}

output "ip" {
  value = libvirt_domain.jenkins-slave-domain.network_interface[0].addresses[0]
}
