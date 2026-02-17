resource "google_compute_instance" "web-instances" {
  count        = var.instance_count
  name         = "web${count.index}"
  machine_type = var.machine_type
  labels       = var.labels

  boot_disk {
    initialize_params {
      image = var.boot_image
    }
  }

  network_interface {
    network    = var.network_self_link
    subnetwork = var.subnetwork_self_link
  }
}
