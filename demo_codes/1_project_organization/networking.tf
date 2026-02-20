/*
Demo 1: Networking primitives

This file creates:
- A subnetwork (subnet) inside the default VPC network
- A firewall rule allowing certain protocols/ports *to instances with specific network tags*
*/

resource "google_compute_subnetwork" "subnet-1" {
  name          = var.subnet-name
  ip_cidr_range = var.subnet-cidr

  network = data.google_compute_network.default.self_link
  region  = var.region

  private_ip_google_access = var.private_google_access
}

resource "google_compute_firewall" "default" {
  name    = "test-firewall"
  network = data.google_compute_network.default.self_link

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = var.firewall-ports
  }

  source_tags = var.compute-source-tags
}