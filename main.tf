variable "droplet_ids" {}
variable "name" {
  default = "k8s-lb"
}
variable "region" {
  default = "fra1"
}

resource "digitalocean_loadbalancer" "lb" {
  name = var.name
  region = var.region

  droplet_ids = var.droplet_ids

  healthcheck {
    port = 30001
    protocol = "tcp"
  }

  forwarding_rule {
    entry_port  = 80
    target_port = 30001
    entry_protocol = "tcp"
    target_protocol = "tcp"
  }

  forwarding_rule {
    entry_port  = 443
    target_port = 30002
    entry_protocol = "tcp"
    target_protocol = "tcp"
  }

  forwarding_rule {
    entry_port  = 8080
    target_port = 30003
    entry_protocol = "tcp"
    target_protocol = "tcp"
  }
}

output "ip" {
  value = digitalocean_loadbalancer.lb.ip
}
