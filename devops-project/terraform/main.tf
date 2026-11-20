terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

provider "docker" {}

# Base image used by every server
resource "docker_image" "base" {
  name = "devops-node:latest"
  build {
    context = "${path.module}/docker"
  }
  triggers = {
    dockerfile = filemd5("${path.module}/docker/Dockerfile")
  }
}

# Private network (like a VPC)
resource "docker_network" "net" {
  name = "devops-net"
}

# Web servers (web1, web2)
resource "docker_container" "web" {
  count    = var.web_count
  name     = "web${count.index + 1}"
  hostname = "web${count.index + 1}"
  image    = docker_image.base.image_id
  command  = ["sleep", "infinity"]
  must_run = true
  ports {
    internal = 80
    external = 8081 + count.index
  }
  networks_advanced {
    name = docker_network.net.name
  }
}

# Monitoring server (Nagios)
resource "docker_container" "monitor" {
  name     = "monitor"
  hostname = "monitor"
  image    = docker_image.base.image_id
  command  = ["sleep", "infinity"]
  must_run = true
  ports {
    internal = 80
    external = 8080
  }
  networks_advanced {
    name = docker_network.net.name
  }
}
