variable "do_token" {}
variable "cloudflare_email" {}
variable "cloudflare_token" {}

variable "name" {
  default = "k8s-lb"
}
variable "region" {
  default = "fra1"
}

provider "digitalocean" {
  token = var.do_token
}

provider "cloudflare" {
  version = "~> 1.0"
  email   = var.cloudflare_email
  token   = var.cloudflare_token
}

data "digitalocean_ssh_key" "ondrejsika" {
  name = "ondrejsika"
}

resource "digitalocean_droplet" "demo" {
  count  = 3
  image  = "rancheros"
  name   = "demo${count.index}"
  region = "fra1"
  size   = "s-1vcpu-1gb"
  ssh_keys = [
    data.digitalocean_ssh_key.ondrejsika.id
  ]

  connection {
    type = "ssh"
    user = "rancher"
    host = self.ipv4_address
  }

  provisioner "remote-exec" {
    inline = [
      "docker pull -q ondrejsika/go-hello-world:3",
      "docker run --name hello -d -p 30001:80 --hostname ${self.name} ondrejsika/go-hello-world:3",
    ]
  }
}

module "k8l-lb-example" {
  source = "./.."

  name = "k8l-lb-example"
  droplet_ids = [
    for droplet in digitalocean_droplet.demo:
    droplet.id
  ]
}


resource "cloudflare_record" "k8s-lb-example" {
  domain  = "sikademo.com"
  name    = "k8l-lb-example"
  value   = module.k8l-lb-example.ip
  type    = "A"
  proxied = false
}
