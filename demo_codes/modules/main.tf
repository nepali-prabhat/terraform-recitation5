provider "google" {
  project     = var.project-id
  region      = var.region
  zone        = var.zone
  credentials = file("key.json")
}

# Nginx proxy instance (single instance with external IP)
resource "google_compute_instance" "nginx_instance" {
  name         = "nginx-proxy"
  machine_type = var.environment_machine_type[var.target_environment]
  labels = {
    environment = var.environment_map[var.target_environment]
  }
  tags = var.compute-source-tags

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
    network    = data.google_compute_network.default.self_link
    subnetwork = google_compute_subnetwork.subnet-1.self_link
    access_config {}
  }
}

# Web instances - deployed via reusable module
module "web_instances" {
  source = "./web-server"

  instance_count       = 3
  machine_type         = var.environment_machine_type[var.target_environment]
  labels               = { environment = var.environment_map[var.target_environment] }
  network_self_link    = data.google_compute_network.default.self_link
  subnetwork_self_link = google_compute_subnetwork.subnet-1.self_link
}

# Web instances per environment (for_each)
resource "google_compute_instance" "web-map-instances" {
  for_each     = var.environment_instance_settings
  name         = "${lower(each.key)}-web"
  machine_type = each.value.machine_type
  labels       = each.value.labels

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
    network    = data.google_compute_network.default.self_link
    subnetwork = google_compute_subnetwork.subnet-1.self_link
  }
}

# Database instance
resource "google_compute_instance" "mysqldb" {
  name         = "mysqldb"
  machine_type = var.environment_machine_type[var.target_environment]
  labels = {
    environment = var.environment_map[var.target_environment]
  }

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
    network    = data.google_compute_network.default.self_link
    subnetwork = google_compute_subnetwork.subnet-1.self_link
  }
}
